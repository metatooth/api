# frozen_string_literal: true

require_relative 'model'

# A model of a note
class Note < Model
  attr_accessor :id
  attr_accessor :text
  attr_accessor :task_id
  attr_accessor :created
  attr_accessor :updated

  def self.all
    notes = []
    notes_ref = @@firestore.col('notes')
    notes_ref.get do |note|
      notes << note.new(note)
    end
    notes
  end

  def self.find_by_task(task_id)
    notes = []
    notes_ref = @@firestore.col('notes').where('task_id', '==', task_id)
    notes_ref.get do |note|
      notes << Note.new(note)
    end
    notes
  end

  def self.get(id)
    doc_snap = @@firestore.col('notes').doc(id).get
    return Note.new(doc_snap) if doc_snap.exists?

    nil
  end

  def create
    if @id.nil? && valid? == true
      doc_ref = @@firestore.col('notes').doc
      doc_ref.set(text: @text, task_id: @task_id,
                  created: Time.now, updated: Time.now)
      initialize(doc_ref.get)
    end
    true if @id
  end

  def destroy
    doc_ref = @@firestore.col('notes').doc(id)
    true if doc_ref.delete
  end

  def init_from_snap(snap)
    @id = snap.document_id
    @text = snap.get('text')
    @task_id = snap.get('task_id')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_string(str)
    vars = JSON.parse(str)
    @text = vars['text']
    @task_id = vars['task_id']
  end

  def init_from_hash(params)
    @text = params[:text]
    @task_id = params[:task_id]
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
      id: @id, text: @text, task_id: @task_id,
      created: @created, updated: @updated
    }.to_json
  end

  def update
    if @id && valid?
      resp = @@firestore.col('notes').doc(@id).set(
        text: @text, task_id: @task_id,
        created: @created, updated: Time.now
      )
    end
    true if resp
  end

  def task
    Task.get(@task_id)
  end

  def valid?
    (!@text.nil? && !@task_id.nil?)
  end
end
