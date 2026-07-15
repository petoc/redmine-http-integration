require File.dirname(__FILE__) + '/http_integration/hooks/issues_edit_hook'

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
      ["{%issue.id%}", (issue["id"].to_s unless issue.nil?)],
      ["{%issue.project_id%}", (issue["project_id"].to_s unless issue.nil?)],
      ["{%issue.status_id%}", (issue["status_id"].to_s unless issue.nil?)],
      ["{%issue.tracker_id%}", (issue["tracker_id"].to_s unless issue.nil?)],
      ["{%redmine.version%}", Redmine::VERSION.to_s],
    ]
  end
  def self.available_macros()
    return self.macros(nil).map {|a| a[0] }.join(", ")
  end
  def self.apply_patches
    [
      [ProjectsController, HttpIntegration::Patches::ProjectsControllerPatch],
      [ProjectsHelper, HttpIntegration::Patches::ProjectsHelperPatch],
    ].each do |classname, modulename|
      unless classname.included_modules.include?(modulename)
        classname.send(:include, modulename)
      end
    end
  end
  def self.replace_macros(str, macros)
    macros.each do |s|
      str = str.gsub(s[0], s[1])
    end
    return str
  end
end
