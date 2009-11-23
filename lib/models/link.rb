class Link < ActiveRecord::Base
  belongs_to :group
  delegate :user, :to => :group

# before_save :get_title

  default_scope :order => "created_at DESC"

  class << self
    def find_or_create(options={})
      user = options.delete(:user) if options[:user]
      group = Group.new(:user => user)
      links = []
      urls_str = options.delete(:url)
      urls = urls_str.split(',').map do |url|
        url.strip!
        url = "http://#{url}" unless url =~ /^http/
        links << new(options.merge({:url => url})) #if !find_by_url(url)
      end
      group.links = links
      group.save
      group
    end
  end

  def clicked
    update_attributes(:clicks => self.clicks += 1)
  end

  protected

  def get_title
    url = URI.parse(self.url)
  end
end
