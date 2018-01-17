require_relative 'no_ski_project_error'
require_relative 'project'
require 'yaml'
require 'byebug'

module Ski
  class Ski
    def initialize(project, pipeline)
      raise NoSkiProjectError unless Dir.exists?('.ski')
      raise MissingFileError unless File.exists?(".ski/#{project}.yml")
      @project = Project.new(YAML.load_file(".ski/#{project}.yml"))
      @project.kick_off(pipeline)
    end
  end
end