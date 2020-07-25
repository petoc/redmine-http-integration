require_dependency 'projects_helper'

module HttpIntegration
  module Patches
    module ProjectsHelperPatch
      def project_settings_tabs
        tabs = super
        if User.current.allowed_to?(:http_integration_settings, @project)
          tabs.push({
            :name => 'http_integration_settings',
            :action => :http_integration_project_settings,
            :partial => 'projects/http_integration_settings',
            :label => 'label_http_integration'
          })
        end
        tabs
      end
    end
  end
end

ProjectsController.helper(HttpIntegration::Patches::ProjectsHelperPatch)
