# frozen_string_literal: true

require_relative 'note'
require_relative 'user'
require_relative 'task'
require 'test/unit'

# Test cases for the note model.
class TestNote < Test::Unit::TestCase
  def setup
    @now = Time.now
    @user = User.signup('unit', 'badpass')
    @user = User.find_by_username('unit') if @user.nil?
    @task = Task.new(
      user_id: @user.id,
      date: @now,
      description: 'Filing Technique',
      duration: 2.5
    )
    @task.create

    @note = Note.new(
      task_id: @task.id,
      text: 'is unstoppable'
    )
  end

  def teardown
    @note.destroy
    @task.destroy
    @user.destroy
  end

  def test_note_create
    assert_equal(true, @note.create)
    assert_not_equal(nil, @note.id)
  end

  def test_note_destroy
    @note.create

    doomed = Note.get(@note.id)

    assert_equal(true, doomed.destroy)

    check = Note.get(@note.id)

    assert_equal(nil, check)
  end

  def test_note_read
    @note.create

    check = Note.get(@note.id)

    %w[text task_id].each do |attr|
      assert_equal(@note.send(attr), check.send(attr))
    end
  end

  def test_note_text
    assert_equal('is unstoppable', @note.text)
  end

  def test_note_update
    assert_equal(true, @note.create)

    check = Note.get(@note.id)

    check.text = 'mnftiu'

    assert_equal(true, check.update)

    check = Note.get(@note.id)

    assert_equal('mnftiu', check.text)
  end
end
