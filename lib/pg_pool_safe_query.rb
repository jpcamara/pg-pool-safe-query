# frozen_string_literal: true

require_relative "pg_pool_safe_query/version"
require_relative "pg_pool_safe_query/railtie"

module PgPoolSafeQuery
  class Error < StandardError; end
  class IncompatibleQueryError < StandardError; end

  module QueryChecker
    def execute(sql, name = nil)
      if @config[:pgbouncer_transaction_mode_check] && PgPoolSafeQuery.incompatible_query?(sql)
        # raise PgPoolSafeQuery::IncompatibleQueryError, "The query is incompatible with PgBouncer's transaction mode. #{sql}"
        Rails.logger.warn "The query is incompatible with PgBouncer's transaction mode. #{sql}"
      end
      super
    end
  end

  extend ActiveSupport::Concern

  included do
    class_attribute :pgbouncer_transaction_mode_check_enabled, default: true
  end

  module ClassMethods
    def pgbouncer_transaction_mode_check!
      self.pgbouncer_transaction_mode_check_enabled = true
    end
  end

  def exec_query(*args)
    if self.class.pgbouncer_transaction_mode_check_enabled && PgPoolSafeQuery.incompatible_query?(args[0])
      raise IncompatibleQueryError, "The query is incompatible with PgBouncer's transaction mode."
    end
    super
  end

  def self.incompatible_query?(sql)
    # Detect non-LOCAL SET statements
    non_local_set = sql =~ /SET\s+(?!LOCAL)/i

    # Detect LISTEN statements
    listen = sql =~ /\bLISTEN\b/i

    # Detect prepared statements with parameters
    prepared_statements_with_params = sql =~ /\bEXECUTE\b.*\$\d+/i

    non_local_set || listen || prepared_statements_with_params
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.include(PgPoolSafeQuery)
end