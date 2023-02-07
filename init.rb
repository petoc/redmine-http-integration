require 'redmine'
require File.dirname(__FILE__) + '/lib/http_integration'

Redmine::Plugin.register :http_integration do
  name 'HTTP Integration'
  author 'Peter C.'
  description 'Sending notifications about issue updates to external URL.'
  version 'master'
  requires_redmine :version_or_higher => '2.3.0'
  project_module :http_integration do
    permission :http_integration_settings, {:projects => [:http_integration_settings]}, :require => :member
  end
end

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  Rails.application.config.after_initialize do
    HttpIntegration.apply_patches
  end
else
  Rails.configuration.to_prepare do
    HttpIntegration.apply_patches
  end
end