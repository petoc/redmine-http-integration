if Redmine::VERSION::MAJOR >= 4
  migration = ActiveRecord::Migration[4.2]
else
  migration = ActiveRecord::Migration
end

class AddedRequestMethod < migration
  def change
    add_column :http_integration_settings, :request_method, :integer, :null => false, :default => 1
  end
end
