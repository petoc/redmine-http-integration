class HttpIntegrationSetting < ActiveRecord::Base
  def self.for_project(project)
    proj_id = project.is_a?(Class) ? project.id : project
    where(:project_id => proj_id).first_or_initialize
  end
end
