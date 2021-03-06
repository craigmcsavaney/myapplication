class Group < Cause
	include NotDeleteable
    versioned

	attr_accessible :name, :user_ids, :cause_ids, :uid

	has_and_belongs_to_many :causes, join_table: :causes_groups
	# has_many :events
	has_one :event

end