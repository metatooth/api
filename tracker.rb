# frozen_string_literal: true

require_relative 'model'

# A model of a time tracker
class Tracker < Model
  attr_accessor :id
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

  def self.get(id)
    doc_snap = @@firestore.col('trackers').doc(id).get
    return Tracker.new(doc_snap) if doc_snap.exists?

    nil
  end

  def create
    if @id.nil?
      doc_ref = @@firestore.col('trackers').doc
      doc_ref.set(created: Time.now, updated: Time.now)
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
    @created = snap.get('created')
    @updated = snap.get('updated')
  end

  def initialize(params = nil)
    if params.class == Google::Cloud::Firestore::DocumentSnapshot
      init_from_snap(params)
    end
  end

  def to_json(*_args)
    {
      id: @id, created: @created, updated: @updated
    }.to_json
  end

  def update
    if @id
      resp = @@firestore.col('trackers').doc(@id).set(
        created: @created, updated: Time.now
      )
    end
    true if resp
  end

end
