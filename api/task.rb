# frozen_string_literal: true

require_relative 'model'

# A model of a task
class Task < Model
  attr_accessor :id
  attr_accessor :description
  attr_accessor :completed_on
  attr_accessor :duration
  attr_accessor :user_id
  attr_accessor :created
  attr_accessor :updated

  def self.all
    tasks = []
    tasks_ref = @@firestore.col('tasks')
    tasks_ref.get do |task|
      tasks << Task.new(task)
    end
    tasks
  end

  def self.find_by_user(user_id)
    tasks = []
    tasks_ref = @@firestore.col('tasks').where('user_id', '==', user_id)
    tasks_ref.get do |task|
      tasks << Task.new(task)
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
      @created = @updated = Time.now
      doc_ref.set(description: @description, completed_on: @completed_on, duration: @duration,
                  user_id: @user_id, created: @created, updated: @updated)
      initialize(doc_ref.get)
    end
    true if @id
  end

  def completed_on_to_s
    @completed_on.to_s
  end

  def destroy
    doc_ref = @@firestore.col('tasks').doc(id)
    true if doc_ref.delete
  end

  def init_from_snap(snap)
    @id = snap.document_id
    @description = snap.get('description')
    @completed_on = snap.get('completed_on')
    @duration = snap.get('duration')
    @user_id = snap.get('user_id')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_string(str)
    vars = JSON.parse(str)
    @description = vars['description']
    @completed_on = Time.parse(vars['completed_on'])
    @duration = vars['duration']
    @user_id = vars['user_id']
  end

  def init_from_hash(params)
    @description = params[:description]
    @completed_on = params[:completed_on]
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

  def notes
    enum = @@firestore.col('notes').where('task_id', '==', @id).get
    notes = []
    enum.each do |doc|
      notes << Note.new(doc)
    end
    notes
  end

  def to_json(*_args)
    {
      id: @id, description: @description, completed_on: @completed_on, duration: @duration,
      user_id: @user_id, created: @created, updated: @updated, notes: notes
    }.to_json
  end

  def update
    if @id && valid?
      @updated = Time.now
      resp = @@firestore.col('tasks').doc(@id).set(
        completed_on: @completed_on, description: @description, duration: @duration,
        user_id: @user_id, created: @created, updated: @updated
      )
    end
    true if resp
  end

  def user
    User.get(@user_id)
  end

  def valid?
    (!@completed_on.nil? && !duration.nil? && !@user_id.nil?)
  end
end
