if Redmine::VERSION::MAJOR >= 4
  migration = ActiveRecord::Migration[4.2]
else
  migration = ActiveRecord::Migration
end

class FixMigrationName < migration
  def change
    if Redmine::VERSION::MAJOR < 3
      execute "UPDATE schema_migrations SET version=REPLACE(version, '1', '20200331200000') WHERE version LIKE '%http_integration%'"
    else
      execute "UPDATE schema_migrations SET version='20200331200000_create_http_integration_settings' WHERE version LIKE '100_create_http_integration_settings%'"
    end
  end
end
