require 'net/https'
require 'uri'
require 'json'

class HttpIntegrationJobBase
end

if defined?(ActiveJob::Base)
  HttpIntegrationJobBase = ActiveJob::Base
end

class HttpIntegrationJob < HttpIntegrationJobBase
  def perform(settings, issue, journal)
    if (settings["url"] || "").length == 0 or issue.nil? or journal.nil?
      Rails.logger.warn('HttpIntegration: invalid data')
      return
    end
    begin
      macros = HttpIntegration::macros(issue)
      macros.push([/[\%\{\}]/, ''])
      url = HttpIntegration::replace_macros(settings["url"], macros)
      uri = URI.parse(url)
      request = nil
      if HttpIntegration::REQUEST_METHOD_GET == settings["request_method"]
        request = Net::HTTP::Get.new(uri.path)
      elsif HttpIntegration::REQUEST_METHOD_POST == settings["request_method"]
        request = Net::HTTP::Post.new(uri.path)
      else
        Rails.logger.warn('HttpIntegration: unknown request method')
        return
      end
      request['User-Agent'] = 'HttpIntegration/' + Redmine::Plugin::find('http_integration').version + ' (Redmine ' + Redmine::VERSION.to_s + ')'
      request['Content-Type'] = 'application/json; charset=utf-8'
      custom_headers = HttpIntegration::replace_macros(settings["custom_headers"], macros)
      if custom_headers.length > 0
        custom_headers.split("|").map(&:strip).each do |header|
          header_parts = header.split(":").map(&:strip)
          if header_parts.length == 2
            request[header_parts[0].gsub(/[^\da-zA-Z\-]/, '')] = header_parts[1]
          end
        end
      end
      if request.method == Net::HTTP::Post::METHOD
        data = {
          "type" => "issue",
          "issue" => issue,
          "journal" => journal,
        }
        request.body = data.to_json
      end
      Rails.logger.debug('HttpIntegration: ' + request.method + ' ' + url + ' ' + request.to_json + ' ' + request.body.to_s)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      if uri.scheme == 'https'
        http.use_ssl = true
        if settings["ignore_ssl_verification"]
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
      response = http.start do |http|
        http.request(request)
      end
      Rails.logger.debug('HttpIntegration: response ' + response.body)
    rescue StandardError => e
      Rails.logger.error('HttpIntegration: error ' + e.message)
    end
  end
end
