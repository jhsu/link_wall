class Link < ActiveRecord::Base
  belongs_to :group
  delegate :user, :to => :group

# before_save :parse_url

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


  protected

  def parse_url
    self.url = "http://#{url}" unless url =~ /^http/
    r = Net::HTTP.get_response(URI.parse(url))
    if r.code =~ /^[23]0[0-9]/
      true
    else
      false
    end
  end
end
