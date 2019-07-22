# frozen_string_literal: true

require_relative 'model'

# A model of a task
class Task < Model
  attr_accessor :id
  attr_accessor :description
  attr_accessor :date
  attr_accessor :duration
  attr_accessor :user_id
  attr_accessor :created
  attr_accessor :updated

  def self.all
    tasks = []
    tasks_ref = @@firestore.col('tasks')
    tasks_ref.get do |task|
      tasks << task.new(task)
    end
    tasks
  end

  def self.find_by_user(user_id)
    tasks = []
    tasks_ref = @@firestore.col('tasks').where('user_id', '==', user_id)
    tasks_ref.get do |task|
      tasks << task.new(task)
    end
    tasks
  end

  def self.get(id)
    doc_snap = @@firestore.col('tasks').doc(id).get
    return Task.new(doc_snap) if doc_snap.exists?

    nil
  end

  def create
    if @id.nil? && valid? == true
      doc_ref = @@firestore.col('tasks').doc
      doc_ref.set(description: @description, date: @date, duration: @duration,
                  user_id: @user_id, created: Time.now, updated: Time.now)
      initialize(doc_ref.get)
    end
    true if @id
  end

  def destroy
    doc_ref = @@firestore.col('tasks').doc(id)
    true if doc_ref.delete
  end

  def init_from_snap(snap)
    @id = snap.document_id
    @description = snap.get('description')
    @date = snap.get('date')
    @duration = snap.get('duration')
    @user_id = snap.get('user_id')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_string(str)
    vars = JSON.parse(str)
    @description = vars['description']
    @date = Time.parse(vars['date'])
    @duration = vars['duration']
    @user_id = vars['user_id']
  end

  def init_from_hash(params)
    @description = params[:description]
    @date = params[:date]
    @duration = params[:duration]
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
      id: @id, description: @description, date: @date, duration: @duration,
      user_id: @user_id, created: @created, updated: @updated
    }.to_json
  end

  def date_to_s
    @date.to_s
  end

  def update
    if @id && valid?
      resp = @@firestore.col('tasks').doc(@id).set(
        date: @date, description: @description, duration: @duration,
        user_id: @user_id, created: @created, updated: Time.now
      )
    end
    true if resp
  end

  def user
    User.get(@user_id)
  end

  def valid?
    (!@description.nil? && !@date.nil? && !duration.nil? && !@user_id.nil?)
  end
end
