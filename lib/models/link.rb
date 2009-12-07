class Link < ActiveRecord::Base
  include HTTParty
  base_uri "http://jhsu.no-ip.org:5545"
  format :json

  belongs_to :group
  has_many :clicks
  delegate :user, :to => :group

# before_save :get_title
  before_save :get_thumbnail

  default_scope :order => "created_at DESC"


  class << self
    def find_or_create(options={})
      user_id = options.delete(:user_id) if options[:user_id]
      group = Group.new(:user_id => user_id)
      links = []
      urls_str = options.delete(:url)
      urls = urls_str.split(',').map do |url|
        url.strip!
        url = "http://#{url}" unless url =~ /^http/
        links << new(options.merge({:url => url}))
      end
      group.links = links
      group.save
      group
    end
  end

  def clicked(ip)
    clicks.create(:ip_address => ip)
  end

  def get_thumbnail
    response = self.class.post("/snap", :query => {:url => self.url})
    self.thumbnail_url = response['url']
  end

  protected

  def get_title
    url = URI.parse(self.url)
  end
end
