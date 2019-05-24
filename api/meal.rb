require 'json'
require 'google/cloud/firestore'

class Meal

    attr_accessor :id
    attr_accessor :taken
    attr_accessor :text
    attr_accessor :calories
    attr_accessor :user_id
    attr_accessor :created
    attr_accessor :updated

    @@firestore = Google::Cloud::Firestore.new project_id: ENV['PROJECT_ID']

    def self.find_by_user(user)
        @meals = Array.new
        meals_ref = @@firestore.col "meals"
        meals_ref.get do |meal|
          @meals << Meal.new(meal).to_json
        end
        @meals
    end

    def self.get(id)
        doc_snap = @@firestore.col('meals').doc(id).get
        if doc_snap.exists?
            meal = Meal.new(doc_snap)
        end
        meal
    end

    def create
        if self.id.nil? && self.valid?
            doc_ref = @@firestore.col('meals').doc
            doc_ref.set({
              taken: self.taken,
              text: self.text,
              calories: self.calories,
              created: Time.now,
              updated: Time.now  
            })

            self.id = doc_ref.document_id
        end
        true if self.id
    end

    def date
        @taken.strftime('%Y-%m-%d')
    end

    def delete
        doc_ref = @@firestore.col('meals').doc(self.id)
        true if doc_ref.delete
    end

    def initialize(params)
        if params.class == Google::Cloud::Firestore::DocumentSnapshot
            @id = params.document_id
            @taken = params.get('taken')
            @text = params.get('text')
            @calories = params.get('calories')
            @created = params.get('created')
            @updated = params.get('updated')
        elsif params.class == String
            vars = JSON.parse(params)
            @taken = Time.parse(vars['taken'])
            @text = vars['text']
            @calories = vars['calories']
        end 
    end

    def num_calories
        self.calories
    end

    def time
        @taken.strftime('%H:%M')
    end

    def to_json
        {
            id: self.id,
            taken: self.taken,
            text: self.text,
            calories: self.calories,
            created: self.created,
            updated: self.updated 
        }.to_json
    end

    def update
        if self.id && self.valid?
            resp = @@firestore.col('meals').doc(self.id).set({
                taken: self.taken,
                text: self.text,
                calories: self.calories,
                updated: Time.now
            })
        end
        true if resp
    end

    def user
    end

    def valid?
        self.taken && self.text && self.calories
    end
end