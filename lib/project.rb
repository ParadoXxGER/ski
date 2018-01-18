require 'open3'
require_relative 'missing_attribute_error'

module Ski
  class Project
    attr_reader :title
    attr_reader :description
    attr_reader :pipelines
    attr_reader :credentials

    def initialize(config)
      @targets = config.dig('targets')
      @title = config.dig('title')
      @description = config.dig('description')
      @pipelines = config.dig('pipelines')
      @credentials = config.dig('pipelines')
      @fail = false
    end

    def kick_off(pipeline_name)
      @pipeline = @pipelines.dig(pipeline_name) || nil
      if @pipeline.nil?
        puts 'ERROR: Pipeline does not exist!'
        exit 255
      end
      puts "PROJECT: #{@title}"
      puts "DESCRIPTION: #{@description}"
      puts "PIPELINE: #{pipeline_name}"
      puts "DESCRIPTION: #{@pipeline.dig('description')}"
      puts "TASKS: #{@pipeline.dig('tasks').count}"
      run(tasks, 'TASK:')
      if @fail
        run(error_tasks, 'CATCH:')
      else
        run(success_tasks, 'THEN:')
      end
    end

    private

    def error_tasks
      @pipeline.dig('catch') || []
    end

    def success_tasks
      @pipeline.dig('then') || []
    end

    def tasks
      @pipeline.dig('tasks') || []
    end

    def ff
      @pipeline.dig('fail-fast') || true
    end

    def interactive?
      @pipeline.dig('interactive') || true
    end

    def prompt_next
      puts 'Run task? (yes/no)'
      input = $stdin.gets.chomp
      if input != 'yes'
        puts 'INFO: Process aborted by user!'
        exit 255
      end
    end

    def run(tasks, prefix)
      tasks.each do |key, value|
        puts "************ #{prefix} Running: #{key} ************"
        prompt_next if interactive?
        stdout, stderr, status = Open3.capture3(value.dig('command').to_s)
        if status.exitstatus != 0
          @fail = true
          puts "STDERR: #{status.exitstatus} #{ stderr if stderr != ''}"
          break if ff
        end
        puts stdout
      end
    end

  end
end