# PgPoolSafeQuery

- Log warnings for queries that are incompatible with PgBouncer
- Raise an error for `database.yml` settings that are incompatible with PgBouncer

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add pg_pool_safe_query

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install pg_pool_safe_query

## Usage

Queries should automatically warn if the syntax is not compatible with PgBouncer. For instance, on Rails server startup you should see:

```
WARN -- : The query is incompatible with PgBouncer's transaction mode. SET client_min_messages TO 'warning'
WARN -- : The query is incompatible with PgBouncer's transaction mode. SET standard_conforming_strings = on
WARN -- : The query is incompatible with PgBouncer's transaction mode. SET intervalstyle = iso_8601
WARN -- : The query is incompatible with PgBouncer's transaction mode. SET SESSION timezone TO 'UTC'
```

In your `database.yml`, you can turn on configuration checks with the `pgbouncer_transaction_mode_check` flag:

```
production:
  pgbouncer_transaction_mode_check: true
```

When this is enabled, if you do not have `prepared_statements` and `advisory_locks` set to false, it will raise an error. Fix it by setting those options:

```
production:
  pgbouncer_transaction_mode_check: true
  advisory_locks: true
  prepared_statements: false
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jpcamara/pg-pool-safe-query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jpcamara/pg-pool-safe-query/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PgPoolSafeQuery project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jpcamara/pg-pool-safe-query/blob/main/CODE_OF_CONDUCT.md).
