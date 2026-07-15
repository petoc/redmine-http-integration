module HttpIntegration
  module Hooks
    class IssuesEditHook < Redmine::Hook::Listener
      def controller_issues_bulk_edit_after_save(context={})
        controller_issues_edit_after_save(context)
      end
      def controller_issues_edit_after_save(context={})
        Rails.logger.debug('HttpIntegration: controller_issues_edit_after_save')
        if context[:issue].project.module_enabled?(:http_integration)
          http_integration_settings = HttpIntegrationSetting.for_project(context[:issue].project_id)
      	  if (!context[:params][:format] or http_integration_settings.include_api_updates?) and context[:issue] and context[:journal]
            settings = http_integration_settings.attributes
            issue = context[:issue].attributes
            journal = context[:journal].attributes
            if defined?(ActiveJob)
              HttpIntegrationJob.perform_later(settings, issue, journal)
            else
              Thread.new do
                begin
                  HttpIntegrationJob.new.perform(settings, issue, journal)
                rescue Exception => e
                  Rails.logger.error("#{e.class}: #{e.message}")
                  Rails.logger.error(e.backtrace.join("\n"))
                end
              end
            end
          end
        else
          Rails.logger.debug('HttpIntegration: module disabled')
        end
      end
    end
  end
end
