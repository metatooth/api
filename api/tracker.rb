# frozen_string_literal: true

require_relative 'model'

# A model of a time tracker
class Tracker < Model
  attr_accessor :id
  attr_accessor :user_id
  attr_accessor :created
  attr_accessor :updated

  def self.all
    trackers = []
    trackers_ref = @@firestore.col('trackers')
    trackers_ref.get do |tracker|
      trackers << Tracker.new(tracker)
    end
    trackers
  end

  def self.find_by_user(user_id)
    trackers = []
    trackers_ref = @@firestore.col('trackers').where('user_id', '==', user_id)
    trackers_ref.get do |tracker|
      trackers << Tracker.new(tracker)
    end
    trackers
  end

  def self.get(id)
    doc_snap = @@firestore.col('trackers').doc(id).get
    return Tracker.new(doc_snap) if doc_snap.exists?

    nil
  end

  def create
    if @id.nil? && valid?
      @created = @updated = Time.now
      doc_ref = @@firestore.col('trackers').doc
      doc_ref.set(user_id: @user_id, created: @created, updated: @updated)
      initialize(doc_ref.get)
    end
    true if @id
  end

  def destroy
    doc_ref = @@firestore.col('trackers').doc(id)
    true if doc_ref.delete
  end

  def init_from_snap(snap)
    @id = snap.document_id
    @user_id = snap.get('user_id')
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def init_from_string(str)
    vars = JSON.parse(str)
    @user_id = vars['user_id']
  end

  def init_from_hash(params)
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
      id: @id, user_id: @user_id, created: @created, updated: @updated
    }.to_json
  end

  def update
    if @id && valid?
      @updated = Time.now
      resp = @@firestore.col('trackers').doc(@id).set(
        user_id: @user_id, created: @created, updated: @updated
      )
    end
    true if resp
  end

  def valid?
    !@user_id.nil?
  end
end
