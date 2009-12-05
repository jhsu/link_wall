class Click < ActiveRecord::Base
  belongs_to :link

  default_scope :order => "created_at DESC"

  class << self
    def summarize(group_id)
    end
  end
end
