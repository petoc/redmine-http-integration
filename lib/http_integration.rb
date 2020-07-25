require 'net/https'
require 'uri'
require 'json'
require 'http_integration/hooks/issues_edit_hook'

module HttpIntegration
  REQUEST_METHOD_POST = 1
  REQUEST_METHOD_GET = 2
  def self.request_methods()
    return [
      ["POST", self::REQUEST_METHOD_POST],
      ["GET", self::REQUEST_METHOD_GET]
    ]
  end
  def self.macros(issue)
    return [
      ["{%issue.id%}", (issue.id.to_s unless issue.nil?)],
      ["{%issue.project_id%}", (issue.project_id.to_s unless issue.nil?)],
      ["{%issue.status_id%}", (issue.status_id.to_s unless issue.nil?)],
      ["{%issue.tracker_id%}", (issue.tracker_id.to_s unless issue.nil?)],
      ["{%redmine.version%}", Redmine::VERSION.to_s],
    ]
  end
  def self.available_macros()
    return self.macros(nil).map {|a| a[0] }.join(", ")
  end
  def self.notify(settings, issue, journal)
    Thread.new do
      if settings.url.length == 0
        return
      end
      begin
        macros = self::macros(issue)
        macros.push([/[\%\{\}]/, ''])
        url = self.replace_macros(settings.url, macros)
        Rails.logger.debug('HTTP_INTEGRATION_PLUGIN: url: ' + url)
        uri = URI.parse(url)
        request = nil
        if self::REQUEST_METHOD_GET == settings.request_method
          request = Net::HTTP::Get.new(uri.path)
        else
          request = Net::HTTP::Post.new(uri.path)
        end
        request['User-Agent'] = 'HttpIntegration/' + Redmine::Plugin::find('http_integration').version + ' (Redmine ' + Redmine::VERSION.to_s + ')'
        request['Content-Type'] = 'application/json; charset=utf-8'
        custom_headers = self.replace_macros(settings.custom_headers, macros)
        if custom_headers.length > 0
          custom_headers.split("|").map(&:strip).each do |header|
            header_parts = header.split(":").map(&:strip)
            if header_parts.length == 2
              request[header_parts[0].gsub(/[^\da-zA-Z\-]/, '')] = header_parts[1]
            end
          end
        end
        if self::REQUEST_METHOD_POST == settings.request_method
          data = {
            "type" => "issue",
            "issue" => Redmine::VERSION::MAJOR < 3 ? JSON.parse(issue.to_json)["issue"] : issue,
            "journal" => Redmine::VERSION::MAJOR < 3 ? JSON.parse(journal.to_json)["journal"] : journal,
          }
          request.body = data.to_json
          Rails.logger.info('HTTP_INTEGRATION_PLUGIN: request.body: ' + data.to_json)
        end
        Rails.logger.debug('HTTP_INTEGRATION_PLUGIN: request: ' + request.to_json)
        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = 2
        if uri.scheme == 'https'
          http.use_ssl = true
          if settings.ignore_ssl_verification?
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end
        response = http.start do |http|
          http.request(request)
        end
        Rails.logger.debug('HTTP_INTEGRATION_PLUGIN: response: ' + response.body)
      rescue StandardError => e
        Rails.logger.error("HTTP_INTEGRATION_PLUGIN: error: " + e.message)
        Thread.current.exit
      end
    end
  end
  private
  def self.replace_macros(str, macros)
    macros.each do |s|
      str = str.gsub(s[0], s[1])
    end
    return str
  end
end
