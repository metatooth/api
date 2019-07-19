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

  def self.all
    meals = []
    meals_ref = @@firestore.col('meals')
    meals_ref.get do |meal|
      meals << Meal.new(meal)
    end
    meals
  end

  def self.find_by_user(user_id)
    meals = []
    meals_ref = @@firestore.col('meals').where('user_id', '==', user_id)
    meals_ref.get do |meal|
      meals << Meal.new(meal)
    end
    meals
  end

  def self.get(id)
    doc_snap = @@firestore.col('meals').doc(id).get
    return Meal.new(doc_snap) if doc_snap.exists?

    nil
  end

  def create
    if @id.nil? && valid? == true
      doc_ref = @@firestore.col('meals').doc
      doc_ref.set(taken: @taken, text: @text, calories: @calories,
                  user_id: @user_id, created: Time.now, updated: Time.now)
      initialize(doc_ref.get)
    end
    true if @id
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
    @user_id = snap.get('user_id')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_string(str)
    vars = JSON.parse(str)
    @taken = Time.parse(vars['taken'])
    @text = vars['text']
    @calories = vars['calories']
    @user_id = vars['user_id']
  end

  def init_from_hash(params)
    @taken = params[:taken]
    @text = params[:text]
    @calories = params[:calories]
    @user_id = params[:user_id]
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

  def to_json(*_args)
    {
      id: @id, taken: @taken, text: @text, calories: @calories,
      user_id: @user_id, created: @created, updated: @updated
    }.to_json
  end

  def taken_to_s
    @taken.to_s
  end

  def update
    if @id && valid?
      resp = @@firestore.col('meals').doc(@id).set(
        taken: @taken, text: @text, calories: @calories,
        user_id: @user_id, created: @created, updated: Time.now
      )
    end
    true if resp
  end

  def user
    User.get(@user_id)
  end

  def valid?
    (!@taken.nil? && !@text.nil? && !@calories.nil? && !@user_id.nil?)
  end
end
