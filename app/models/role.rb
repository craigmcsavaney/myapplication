class Role < ActiveRecord::Base
	include NotDeleteable
	versioned
	
  	attr_accessible :name, :description, :user_ids
  	validates :name, presence: true, uniqueness: { case_sensitive: false }

  	has_and_belongs_to_many :users

end
