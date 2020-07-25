module HttpIntegration
  module Hooks
    class IssuesEditHook < Redmine::Hook::Listener
      def controller_issues_bulk_edit_after_save(context={})
        controller_issues_edit_after_save(context)
      end
      def controller_issues_edit_after_save(context={})
        Rails.logger.debug('HTTP_INTEGRATION_PLUGIN: controller_issues_edit_after_save')
        if context[:issue].project.module_enabled?(:http_integration)
          http_integration_settings = HttpIntegrationSetting.for_project(context[:issue].project_id)
      	  if (!context[:params][:format] or http_integration_settings.include_api_updates?) and context[:issue] and context[:journal]
            HttpIntegration.notify(http_integration_settings, context[:issue], context[:journal])
          end
        else
          Rails.logger.debug('HTTP_INTEGRATION_PLUGIN: module disabled')
        end
      end
    end
  end
end
