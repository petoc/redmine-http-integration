if Redmine::VERSION::MAJOR >= 4
  migration = ActiveRecord::Migration[4.2]
else
  migration = ActiveRecord::Migration
end

class ChangeHeaderColumnType < migration
  def change
    change_column :http_integration_settings, :custom_headers, :text
  end
end
