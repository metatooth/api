# frozen_string_literal: true

require_relative 'tracker'
require_relative 'user'
require 'test/unit'

# Test cases for the tracker model.
class TestTracker < Test::Unit::TestCase
  def setup
    @now = Time.now
    @user = User.signup('unit', 'badpass')
    @user = User.find_by_email('unit') if @user.nil?
    @tracker = Tracker.new(user_id: @user.id)
  end

  def teardown
    @tracker.destroy
    @user.destroy
  end

  def test_tracker_create
    assert_equal(true, @tracker.create)
    assert_not_equal(nil, @tracker.id)
  end

  def test_tracker_destroy
    @tracker.create

    doomed = Tracker.get(@tracker.id)

    assert_equal(true, doomed.destroy)

    check = Tracker.get(@tracker.id)

    assert_equal(nil, check)
  end

  def test_tracker_read
    @tracker.create

    check = Tracker.get(@tracker.id)

    %w[id created updated].each do |attr|
      assert_equal(@tracker.send(attr), check.send(attr))
    end
  end

  def test_tracker_update
    assert_equal(true, @tracker.create)

    check = Tracker.get(@tracker.id)

    sleep(6)

    assert_equal(true, check.update)

    check = Tracker.get(@tracker.id)

    assert_in_delta(Time.now.to_i, check.updated.to_i, 1)
    assert_not_equal(check.created.to_i, check.updated.to_i)
  end
end
