# frozen_string_literal: true

require_relative 'meal'
require 'test/unit'

# Test cases for the Meal model.
class TestMeal < Test::Unit::TestCase
  def setup
    @now = Time.now
    @meal = Meal.new(taken: @now, text: 'Escargot! My favorite.', calories: 600)
  end

  def teardown
    @meal.destroy
  end

  def test_meal_create
    assert_equal(true, @meal.create)
    assert_not_equal(nil, @meal.id)
  end

  def test_meal_date
    assert_equal(@now.strftime('%Y-%m-%d'), @meal.date)
  end

  def test_meal_destroy
    @meal.create

    doomed = Meal.get(@meal.id)

    assert_equal(true, doomed.destroy)

    check = Meal.get(@meal.id)

    assert_equal(nil, check)
  end

  def test_meal_num_calories
    assert_equal(600, @meal.num_calories)
  end

  def test_meal_read
    @meal.create

    check = Meal.get(@meal.id)

    %w[date time text calories].each do |attr|
      assert_equal(@meal.send(attr), check.send(attr))
    end
  end

  def test_meal_time
    assert_equal(@now.strftime('%H:%M'), @meal.time)
  end

  def test_meal_text
    assert_equal('Escargot! My favorite.', @meal.text)
  end

  def test_meal_update
    @meal.create

    check = Meal.get(@meal.id)

    check.text = 'Pirate\'s Tears'

    assert_equal(true, check.update)

    check = Meal.get(@meal.id)

    assert_equal('Pirate\'s Tears', check.text)
  end
end
