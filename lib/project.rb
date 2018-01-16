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
      @ff = config.dig('pipelines')
      @errors = []
    end

    def kick_off(pipeline_id)
      @pipeline = @pipelines.find { |pipeline| pipeline.dig('pipeline', 'id') == pipeline_id }
      run_tasks
      if @errors.count.zero?
        run_on_success
      else
        run_on_error
      end
    end

    private

    def run_on_error
      @pipeline.dig('pipeline','on-error', 'tasks').each_with_index do |task, index|
        puts "************ ON-ERROR: Running error task: #{index+1}/#{number_of_error_tasks} #{task.dig('task', 'name')} ************"
        begin
          output = system task.dig('task', 'command')
        rescue SystemCallError
          puts output
          exit 255
        end
      end
    end

    def run_on_success
      @pipeline.dig('pipeline','on-success', 'tasks').each_with_index do |task, index|
        puts "************ ON-SUCCESS: Running success task: #{index+1}/#{number_of_success_tasks} #{task.dig('task', 'name')} ************"
        begin
          output = system task.dig('task', 'command')
        rescue SystemCallError
          puts output
          exit 255
        end
      end
    end

    def number_of_tasks
      @pipeline.dig('pipeline','tasks').count || 'ERROR'
    end

    def number_of_success_tasks
      @pipeline.dig('pipeline','on-success', 'tasks').count || 'ERROR'
    end

    def number_of_error_tasks
      @pipeline.dig('pipeline','on-error', 'tasks').count || 'ERROR'
    end

    def run_tasks
      @pipeline.dig('pipeline','tasks').each_with_index do |task, index|
        puts "************ INFO: Running task: #{index+1}/#{number_of_tasks} #{task.dig('task', 'name')} ************"
        begin
          output = system task.dig('task', 'command')
        rescue SystemCallError
          @errors << output
          exit 255 if pipeline.dig('pipeline','fail-fast') == 'true'
        end
      end
    end
  end
end