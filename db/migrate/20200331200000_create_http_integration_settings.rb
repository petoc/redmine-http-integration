if Redmine::VERSION::MAJOR >= 4
  migration = ActiveRecord::Migration[4.2]
else
  migration = ActiveRecord::Migration
end

class CreateHttpIntegrationSettings < migration
  def change
    create_table :http_integration_settings do |t|
      t.integer :project_id
      t.string :url
      t.string :custom_headers
      t.boolean :ignore_ssl_verification
      t.boolean :include_api_updates
    end
  end
end
