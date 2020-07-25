require_dependency 'projects_controller'

module HttpIntegration
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end
      module InstanceMethods
        def http_integration_settings
          if params[:http_integration_url].present?
            @http_integration_settings = HttpIntegrationSetting.for_project(@project)
            @http_integration_settings.url = params[:http_integration_url]
            @http_integration_settings.custom_headers = params[:http_integration_custom_headers]
            @http_integration_settings.request_method = params[:http_integration_request_method].to_i
            @http_integration_settings.ignore_ssl_verification = params[:http_integration_ignore_ssl_verification]
            @http_integration_settings.include_api_updates = params[:http_integration_include_api_updates]
            if @http_integration_settings.save
              flash[:notice] = l(:notice_successful_update)
            else
              flash[:error] = l('http_integration.error_update_not_successful')
            end
          end
          redirect_to settings_project_path(@project, :tab => 'http_integration_settings')
        end
      end
    end
  end
end
