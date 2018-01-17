require 'open3'
require_relative 'missing_attribute_error'

module Ski
  class Project
    attr_reader :title
    attr_reader :description
    attr_reader :pipelines
    attr_reader :credentials

    def initialize(config)
      @title = config.dig('title')
      @description = config.dig('description')
      @pipelines = config.dig('pipelines')
      @credentials = config.dig('pipelines')
      @fail = false
      puts "PROJECT: #{@title}"
      puts "DESCRIPTION: #{@description}"
      puts "PIPELINES:"
      @pipelines.each do |pipeline|
        puts "  ID: #{pipeline.dig('pipeline', 'id')}"
        puts "  DESCRIPTION: #{pipeline.dig('pipeline', 'description')}"
        puts "  TASKS: #{pipeline.dig('pipeline', 'tasks').count}"
      end
    end

    def kick_off(pipeline_id)
      @pipeline = @pipelines.find { |pipeline| pipeline.dig('pipeline', 'id') == pipeline_id }
      run(tasks, 'TASK:')
      if @fail
        run(error_tasks, 'ERROR:')
      else
        run(success_tasks, 'SUCCESS:')
      end
    end

    private

    def error_tasks
      @pipeline.dig('pipeline','on-error', 'tasks') || []
    end

    def success_tasks
      @pipeline.dig('pipeline','on-success', 'tasks') || []
    end

    def tasks
      @pipeline.dig('pipeline', 'tasks') || []
    end

    def ff
      @pipeline.dig('pipeline', 'fail-fast') || true
    end

    def run(tasks, prefix)
      tasks.each_with_index do |task, index|
        puts "************ #{prefix} Running: #{index+1}/#{tasks.count} #{task.dig('task', 'name')} ************"
        stdout, stderr, status = Open3.capture3(task.dig('task', 'command').to_s)
        if status.exitstatus != 0
          @fail = true
          puts "ERROR: #{stderr}"
          break if ff
        end
        puts stdout
      end
    end

  end
end