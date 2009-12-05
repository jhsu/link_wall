class Group < ActiveRecord::Base
  has_many :links
  has_many :clicks, :through => :links
  belongs_to :user

  before_create :generate_token
  validates_uniqueness_of :token

  default_scope :order => "created_at DESC"

  def generate_token
    self.token = rand(36**8).to_s(36)
  end

  def viewed
    update_attributes(:views => self.views+=1 )
  end

  def clicks_by_day
    if (ENV['DATABASE_URL'])
      self.clicks.count('clicks.id', :group => "to_char(clicks.created_at, 'YYYY-MM-DD')").map {|date, count| count }
    else
      self.clicks.count('clicks.id', :group => "strftime('%Y-%m-%d', clicks.created_at)").map {|date, count| count }
    end
  end
end
