require_relative "meal"
require "test/unit"
 
class TestMeal < Test::Unit::TestCase
 
  def setup
    @now = Time.now
    @meal = Meal.new(@now, 'Escargot! My favorite.', 120)
  end

  def test_meal_date
    assert_equal(@now.strftime('%Y-%m-%d'), @meal.date)
  end

  def test_meal_time
    assert_equal(@now.strftime('%H:%M'), @meal.time)    
  end

  def test_meal_text
    assert_equal('Escargot! My favorite.', @meal.text)    
  end

  def test_meal_num_calories
    assert_equal(120, @meal.num_calories)
  end

end