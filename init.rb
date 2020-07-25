require 'redmine'
require 'http_integration'

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

Rails.configuration.to_prepare do
  [
    [ProjectsController, HttpIntegration::Patches::ProjectsControllerPatch],
    [ProjectsHelper, HttpIntegration::Patches::ProjectsHelperPatch],
  ].each do |classname, modulename|
    unless classname.included_modules.include?(modulename)
      classname.send(:include, modulename)
    end
  end
end
