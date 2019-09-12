# frozen_string_literal: true

require_relative 'task'
require_relative 'user'
require 'test/unit'

# Test cases for the task model.
class TestTask < Test::Unit::TestCase
  def setup
    @now = Time.now
    @user = User.signup('unit', 'badpass')
    @user = User.find_by_email('unit') if @user.nil?

    @task = Task.new(
      user_id: @user.id,
      completed_on: @now,
      description: 'Escargot! My favorite.',
      duration: 7200
    )
  end

  def teardown
    @task.destroy
    @user.destroy
  end

  def test_task_create
    assert_equal(true, @task.create)
    assert_not_equal(nil, @task.id)
  end

  def test_task_completed_on
    assert_equal(@now.strftime('%Y-%m-%d'), @task.completed_on.strftime('%Y-%m-%d'))
  end

  def test_task_destroy
    @task.create

    doomed = Task.get(@task.id)

    assert_equal(true, doomed.destroy)

    check = Task.get(@task.id)

    assert_equal(nil, check)
  end

  def test_task_duration
    assert_equal(7200, @task.duration)
  end

  def test_task_read
    @task.create

    check = Task.get(@task.id)

    %w[completed_on_to_s description duration user_id].each do |attr|
      assert_equal(@task.send(attr), check.send(attr))
    end
  end

  def test_task_description
    assert_equal('Escargot! My favorite.', @task.description)
  end

  def test_task_update
    assert_equal(true, @task.create)

    check = Task.get(@task.id)

    check.description = 'Pirate\'s Tears'

    assert_equal(true, check.update)

    check = Task.get(@task.id)

    assert_equal('Pirate\'s Tears', check.description)
  end
end