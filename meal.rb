# frozen_string_literal: true

require_relative 'model'

# A model of a meal
class Meal < Model
  attr_accessor :id
  attr_accessor :taken
  attr_accessor :text
  attr_accessor :calories
  attr_accessor :user_id
  attr_accessor :created
  attr_accessor :updated

  def self.find_by_user(_user)
    @meals = []
    meals_ref = @@firestore.col 'meals'
    meals_ref.get do |meal|
      @meals << Meal.new(meal).to_json
    end
    @meals
  end

  def self.get(id)
    doc_snap = @@firestore.col('meals').doc(id).get
    meal = Meal.new(doc_snap) if doc_snap.exists?
    meal
  end

  def create
    if id.nil? && valid?
      doc_ref = @@firestore.col('meals').doc
      doc_ref.set(taken: taken, text: text, calories: calories,
                  created: Time.now, updated: Time.now)

      self.id = doc_ref.document_id
    end
    true if id
  end

  def date
    @taken.strftime('%Y-%m-%d')
  end

  def destroy
    doc_ref = @@firestore.col('meals').doc(id)
    true if doc_ref.delete
  end

  def init_from_snap(snap)
    @id = snap.document_id
    @taken = snap.get('taken')
    @text = snap.get('text')
    @calories = snap.get('calories')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_string(str)
    vars = JSON.parse(str)
    @taken = Time.parse(vars['taken'])
    @text = vars['text']
    @calories = vars['calories']
  end

  def init_from_hash(params)
    @taken = params[:taken]
    @text = params[:text]
    @calories = params[:calories]
  end

  def initialize(params)
    if params.class == Google::Cloud::Firestore::DocumentSnapshot
      init_from_snap(params)
    elsif params.class == String
      init_from_string(params)
    elsif params.class == Hash
      init_from_hash(params)
    end
  end

  def num_calories
    calories
  end

  def time
    @taken.strftime('%H:%M')
  end

  def to_json(*_args)
    {
      id: id,
      taken: taken,
      text: text,
      calories: calories,
      created: created,
      updated: updated
    }.to_json
  end

  def update
    if id && valid?
      resp = @@firestore.col('meals').doc(id).set(
        taken: taken,
        text: text,
        calories: calories,
        updated: Time.now
      )
    end
    true if resp
  end

  def user; end

  def valid?
    taken && text && calories
  end
end
