class Serve < ActiveRecord::Base
	include SecureRandom
  #include NotDeleteable
	versioned

	attr_accessible :promotion_id, :referring_share_id, :viewed, :session_id, :current_cause_id, :id, :user_id, :default_cause_id, :serve_count, :session_count

  belongs_to :promotion, counter_cache: true
  belongs_to :share, foreign_key: "referring_share_id"
  belongs_to :cause, foreign_key: "current_cause_id"
  belongs_to :cause, foreign_key: "default_cause_id"
  belongs_to :user
  has_many :shares, dependent: :destroy
  has_many :sales, through: :shares
  delegate :merchant, to: :promotion, allow_nil: true
  delegate :email, to: :user, allow_nil: true


  before_validation :get_current_cause, :get_session_id
  before_validation :initialize_session_count, on: :create
  before_validation :update_session_count, on: :update

	validates :promotion, presence: true
	validates :promotion_id, presence: true
  validates :cause, presence: true
  validates :default_cause_id, presence: true
  validates :current_cause_id, presence: true
  validates :serve_count, presence: true
  validates :session_count, presence: true

  after_validation :replace_nils, :get_current_cause

	after_commit :create_all_shares, on: :create
  after_commit :update_referral_counter, on: :create

  #before_save :get_session_id

  def update_referral_counter
    if !self.referring_share_id.nil?
      referring_serve = Serve.find(self.share.serve)
      old_referral_count = referring_serve.referral_count
      referring_serve.update_attribute(:referral_count, old_referral_count + 1)
    end
  end

  def self.cause_changed?(serve,new_cause_id)
    # check to see if the new cause is different from the current cause value.
    case
      # check to see if both the old current cause and the new cause are nil or blank
      when (serve.current_cause_id.nil? or serve.current_cause_id == "") && (new_cause_id.nil? or new_cause_id == "")
        # This should never happen, as every serve is required to have a cause and the update will fail if no cause is present.
        @cause_changed = false
        @cause_id = serve.current_cause_id
      # check to see if the new current cause is a valid cause
      when Cause.not_exists?(new_cause_id)
        @cause_changed = false
        @cause_id = serve.current_cause_id
      # check to see if the new current cause is the same as the old current cause
      when serve.current_cause_id == new_cause_id 
        @cause_changed = false
        @cause_id = serve.current_cause_id
      # since both are not blank or nil and they are not the same, they must be different
      else
        @cause_changed = true
        @cause_id = Cause.find(new_cause_id).id
    end
    return {cause_changed: @cause_changed, cause_id: @cause_id}
  end

  def self.user_changed?(serve,new_email)
    # Check to see if an email was passed in and if it is different than the email 
    # associated with the user in the current serve record.  If it is different, set the 
    # user_changed flag to true and set the user_id variable to the new user_id.
    case
        # check to see if both the old user and the new user are nil or blank
        when (serve.user.nil? or serve.email == "") && (new_email.nil? or new_email == "")
            @user_changed = false
            @user_id = nil
            @type = nil
        # check to see if the new user is the same as the old user
        when !serve.user.nil? && serve.email == new_email
            @user_changed = false
            @user_id = serve.user_id
            @type = nil
        # check to see if there is a user associated with the current serve but the new email is blank or nil.  If this is the case, the new user should be nil.
        when !serve.user.nil? && (new_email.nil? or new_email == "")
            @user_changed = true
            @user_id = nil
            @type = "new"
        # since a new email is present and either there is no current user associated with the serve or it is a user with a different email than the new email, update the serve with the new user.  The GetUserID will create a new user for this email if needed or will find and return the user.id of the existing user for this email address.  The GetUserID method also returns type: "new" when it creates a new user.  This must be passed back to the API controller to set the user cookie to the new user email value.
        else
            @user_changed = true
            @user = User.GetUserID(new_email)
            @user_id = @user[:user_id]
            @type = @user[:type]
    end
    return {user_changed: @user_changed, user_id: @user_id, type: @type}
  end

  def self.post_to_channel(serve,channel)
    # get the share associated with this serve and channel_id, making sure to only
    # get the not confirmed share as there may be multiple confirmed shares but should
    # only be one not confirmed share per channel per serve
    @share = serve.shares.where("channel_id = ? and confirmed = ?",channel.id,false).first
    # now, mark this share as confirmed.  First, determine if this is a purchase share or not.  If it is, do not update the current_cause_id as the current cause will be added to the new purchase share that will be created later.  However, if this is a non-purchase share, update it with the current_cause_id.
    if channel.name == "Purchase"
        cause = ""
      else
        cause = serve.current_cause_id
    end
    @share.update_attributes(confirmed: true, cause_id: cause)
  end

  def get_current_cause
    if self.current_cause_id.nil?
      self.current_cause_id = self.default_cause_id
    end
  end

  def initialize_session_count
    self.session_count = 1
  end

  def update_session_count
    if self.session_id_changed?
      self.session_count = self.session_count + 1
    end
  end

  def get_session_id
    if self.session_id.nil?
      self.session_id = Serve.new_session_id
    end
  end

  def self.new_session_id
    loop do
      session_id = SecureRandom.urlsafe_base64()
      break session_id unless Serve.where(session_id: session_id).exists?
    end
  end

  def self.not_exists?(id)
  		self.find(id)
  		false
		rescue
  		true
	end

  def self.session_valid?(session_id,merchant)
    if session_id == nil
      false
    elsif session_id == ""
      false
    elsif self.find_by_session_id(session_id) == nil
      false
    elsif
      self.find_by_session_id(session_id).promotion.merchant != merchant
        false
    else
      true
    end
  end

  private
	def create_all_shares
	Share.create_all_shares(self)
	end

  private
  def replace_nils
    if self.viewed.nil?
      self.viewed = false
    end
  end

  def self.shared?(serve)
    serve.shares.where("confirmed = ? and channel_id <> ?", true, Channel.find_by_name("Purchase")).count > 0
  end

  def self.referred?(serve)
    !serve.share.nil?
  end

  def self.servable?(serve)
    if serve.promotion.unservable == nil
      true
    elsif serve.promotion.unservable == false
      true
    elsif serve.promotion.unservable == true
      false
    else
      true
    end
    # If the promotion has been deleted or the serve can't find the promotion for any reason,
    # we will rescue this function and return false so that this serve won't be served again
    rescue
      false
  end


end
