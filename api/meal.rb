class Meal

    attr_accessor :id
    attr_accessor :taken
    attr_accessor :text
    attr_accessor :calories
    attr_accessor :user_id
    attr_accessor :created
    attr_accessor :updated

    def self.find_by_user(user)
    end

    def self.get(id)
    end

    def create
    end

    def date
        @taken.strftime('%Y-%m-%d')
    end

    def delete
    end

    def initialize(taken, text, calories)
        @taken = taken
        @text = text
        @calories = calories
        @created = Time.now
        @updated = Time.now
    end

    def num_calories
        self.calories
    end

    def time
        @taken.strftime('%H:%M')
    end

    def update
    end

    def user
    end

end