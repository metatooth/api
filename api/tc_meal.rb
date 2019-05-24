require_relative "meal"
require "test/unit"
 
class TestMeal < Test::Unit::TestCase
 
  def setup
    @now = Time.now
    @meal = Meal.new(@now, 'Escargot! My favorite.', 120)
  end

  def teardown
    @meal.delete
  end

  def test_meal_create
    @meal.create
    assert_not_equal(nil, @meal.id)
  end
  
  def test_meal_date
    assert_equal(@now.strftime('%Y-%m-%d'), @meal.date)
  end

  def test_meal_delete
    @meal.create

    doomed = Meal.get(@meal.id)

    assert_equal(true, doomed.delete)

    check = Meal.get(@meal.id)

    assert_equal(nil, check)
  end

  def test_meal_num_calories
    assert_equal(120, @meal.num_calories)
  end
  
  def test_meal_read
    @meal.create

    check = Meal.get(@meal.id)

    assert_equal(@meal.date, check.date)
    assert_equal(@meal.time, check.time)
    assert_equal(@meal.text, check.text)
    assert_equal(@meal.calories, check.calories)
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