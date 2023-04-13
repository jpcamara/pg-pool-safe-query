require "rails/railtie"

module PgPoolSafeQuery
  def self.enabled?(config, key)
    # Not being set to false explicitly is the same as being set to true
    config.fetch(key, true)
  end

  class Railtie < Rails::Railtie
    config.after_initialize do
      db_configuration = ActiveRecord::Base.connection_pool.db_config.config.with_indifferent_access
      next unless db_configuration[:pgbouncer_transaction_mode_check]

      # raise an error if we have set the flag, but still have advisory locks and prepared statements turned on
      if PgPoolSafeQuery.enabled?(db_configuration, :prepared_statements) || PgPoolSafeQuery.enabled?(db_configuration, :advisory_locks)
        raise PgPoolSafeQuery::Error, "You have enabled PgPoolSafeQuery, but still have prepared statements or advisory locks turned on. This will cause errors."
      end

      ActiveRecord::Base.connection.class.prepend(PgPoolSafeQuery::QueryChecker)
    end
  end
end