# frozen_string_literal: true

require_relative 'meal'
require_relative 'user'
require 'test/unit'

# Test cases for the Meal model.
class TestMeal < Test::Unit::TestCase
  def setup
    @now = Time.now
    @user = User.signup('unit', 'badpass')
    if @user.nil?
      @user = User.find_by_username('unit')
    end

    @meal = Meal.new({
      user_id: @user.id,
      taken: @now,
      text: 'Escargot! My favorite.',
      calories: 600
    })
  end

  def teardown
    @meal.destroy
    @user.destroy
  end

  def test_meal_create
    assert_equal(true, @meal.create)
    assert_not_equal(nil, @meal.id)
  end

  def test_meal_date
    assert_equal(@now.strftime('%Y-%m-%d'), @meal.taken.strftime('%Y-%m-%d'))
  end

  def test_meal_destroy
    @meal.create

    doomed = Meal.get(@meal.id)

    assert_equal(true, doomed.destroy)

    check = Meal.get(@meal.id)

    assert_equal(nil, check)
  end

  def test_meal_calories
    assert_equal(600, @meal.calories)
  end

  def test_meal_read
    @meal.create

    check = Meal.get(@meal.id)

    %w[taken_to_s text calories user_id].each do |attr|
      assert_equal(@meal.send(attr), check.send(attr))
    end
  end

  def test_meal_time
    assert_equal(@now.strftime('%H:%M'), @meal.taken.strftime('%H:%M'))
  end

  def test_meal_text
    assert_equal('Escargot! My favorite.', @meal.text)
  end

  def test_meal_update
    assert_equal(true, @meal.create)

    check = Meal.get(@meal.id)

    check.text = 'Pirate\'s Tears'

    assert_equal(true, check.update)

    check = Meal.get(@meal.id)

    assert_equal('Pirate\'s Tears', check.text)
  end
end
