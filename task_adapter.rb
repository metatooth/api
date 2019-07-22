# frozen_string_literal: true

require_relative 'task'

# Handles display of a Task model.
class TaskAdapter
  attr_accessor :task

  def date
    @task.taken.strftime('%Y-%m-%d')
  end

  def num_calories
    @task.calories
  end

  def time
    @task.taken.strftime('%H:%M')
  end

  def text
    @task.text
  end

  def initialize(params)
    if params.class == Task
      @task = Task
    else
      throw 'TaskAdapter initialize must have a Task!'
    end
  end
end
