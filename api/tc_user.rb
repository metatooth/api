# frozen_string_literal: true

require_relative 'user'
require 'test/unit'

# Test cases for the User model.
class TestUser < Test::Unit::TestCase
  def setup
    @user = User.signup('terry@example.com', 'badpass')
    assert_not_equal(nil, @user.id)
  end

  def teardown
    @user.destroy
  end

  def test_user_authenticate
    user = User.authenticate('terry@example.com', 'badpass')
    assert_equal(@user.id, user.id)
  end
end
