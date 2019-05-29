require_relative "user"
require "test/unit"
 
class TestUser < Test::Unit::TestCase

  def setup
    @user = User.signup('terry', 'badpass')
    puts "@USER #{@user.to_s}"
    assert_not_equal(nil, @user.id)
  end
  
  def teardown
    @user.destroy
  end

  def test_user_authenticate
    user = User.authenticate('terry', 'badpass')
    assert_equal(@user.id, user.id)
  end

end