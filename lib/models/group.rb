class Group < ActiveRecord::Base
  has_many :links
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
end
