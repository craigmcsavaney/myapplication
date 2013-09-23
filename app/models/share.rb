class Share < ActiveRecord::Base
	include NotDeleteable
	versioned

	attr_accessible :serve_id, :channel_id, :link_id, :confirmed, :cause_id, :deleted
	
  before_validation :get_awesome_path

  belongs_to :serve, counter_cache: true
	belongs_to :channel
  belongs_to :cause
  has_many :serves
  has_many :sales
  delegate :promotion, :to => :serve, :allow_nil => true


	validates :serve, presence: true
	validates :channel, presence: true
	validates :link_id, presence: true, uniqueness: { case_sensitive: true }
	validates :serve_id, presence: true
	validates :channel_id, presence: true
	validate :selected_channel

  private
  def get_awesome_path
    if self.link_id == "" or self.link_id.nil?
      landing_page = Serve.find(self.serve_id).promotion.landing_page
      channel = Channel.find(self.channel_id).name
      self.link_id = Awesome.get_new_link_path(channel,landing_page)
    end
  end

	private
  def selected_channel
    if !Promotion.find(Serve.find(self.serve_id).promotion_id).channel_ids.include?(self.channel_id)
      errors.add(:channel_id," :: The channel_id associated with this share is not one selected for the promotion")
    end
  end

  def self.not_exists?(id)
      self.find(id)
      false
    rescue
      true
  end

  def self.path_valid?(path)
    if path == nil
      false
    elsif path == ""
      false
    elsif self.find_by_link_id(path) == nil
      false
    else
      true
    end
  end

  def self.path_valid_for_this_serve?(path,serve)
    # the path is not valid for the given serve if the path is nil, the path is null (or blank), the path does not exist for any share, the serve associated with the path is different than the serve passed in, or the path is associated with an already confirmed share (meaning that a new share and new path have already been created).
    if path == nil
      false
    elsif path == ""
      false
    elsif self.find_by_link_id(path) == nil
      false
    elsif
      self.find_by_link_id(path).serve != serve
        false
    elsif 
      self.find_by_link_id(path).confirmed?
        false
    else
      true
    end
  end

  def self.path_valid_for_this_merchant?(path,merchant)
    # the path is not valid for the given merchant if the path is nil, the path is null (or blank), the path does not exist for any share, or the merchant associated with the path is different than the merchant passed in.
    if path == nil
      false
    elsif path == ""
      false
    elsif self.find_by_link_id(path) == nil
      false
    elsif
      self.find_by_link_id(path).serve.merchant != merchant
        false
    else
      true
    end
  end


  def self.create_all_shares(serve)
    # Create a new set of shares for a serve when a serve is created.
    serve.promotion.channels.each do |channel|
      self.create_share(serve,channel)
    end
  end

  def self.create_share(serve,channel)
    # create a share for the given serve and channel
    landing_page = serve.promotion.landing_page
    path = Awesome.get_new_link_path(channel.name,landing_page)
#    path = SecureRandom.urlsafe_base64(4)  # use this only for offline testing
    Share.create(serve_id: serve.id, channel_id: channel.id, link_id: path)
  end

  # get_cause finds the cause asociated with an input share by checking for the presence of a cause_id first at the share (which will be present if the share was confirmed), then at the serve (which could have been updated by a CB Widget viewer), then at the promotion level (which will be the merchant's preferred cause for this promotion.)
  def self.get_cause(share)
    if !share.cause.nil?
      cause = share.cause
    elsif !share.serve.cause.nil?
      cause = share.serve.cause
    else
      cause = share.promotion.cause
    end
  end


end