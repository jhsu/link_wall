class Click < ActiveRecord::Base
  belongs_to :link

  class << self
    def summarize(group_id)
    end
  end
end
