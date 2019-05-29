require_relative 'meal'

# Handles display of a Meal model.
class MealAdapter
    attr_accessor :meal

    def date
        @meal.taken.strftime('%Y-%m-%d')
    end

    def num_calories
        @meal.calories
    end

    def time
        @meal.taken.strftime('%H:%M')
    end

    def text
        @meal.text
    end
    
    def initialize(params)
        if params.class == Meal
            @meal = meal
        else
            throw "MealAdapter initialize must have a Meal!"
        end
    end 
end