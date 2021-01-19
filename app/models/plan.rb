# frozen_string_literal: true

# An Plan model.
class Plan < ROM::Struct
  def new(params)
    params.delete!(:location, :service, :bucket, :etag, :s3key)
  end

  def destroy
    update({ deleted: true, deleted_at: DateTime.now })
  end

  def latest
    latest = 0
    revisions.each do |rev|
      latest = rev.number if rev.number > latest
    end
    latest
  end
end
