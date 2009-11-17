class Link < ActiveRecord::Base
  belongs_to :user

  before_save :parse_url, :generate_token
  validates_uniqueness_of :token

  default_scope :order => "created_at DESC"

  class << self
    def find_or_create(options={})
      url = "http://#{options[:url]}" unless !options[:url] || options[:url] =~ /^http/
      if url && link = find_by_url(url)
        link
      else
        create(options)
      end
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

  def generate_token
    self.token = rand(36**8).to_s(36)
  end
end
