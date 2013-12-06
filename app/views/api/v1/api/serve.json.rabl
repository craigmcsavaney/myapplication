object @serve
attributes :id => :serve_id
attributes :email, :session_id, :created_at, :viewed

node :current_cause_id do |serve|
	serve.cause.uid
end	

node do |serve|
	if serve.cause.type == 'Single'
		{ :current_cause_type => "single", 
		  :current_fg_uuid => serve.cause.fg_uuid, 
		  :current_event_uid => "" }
	else
		{ :current_cause_type => "event", 
		  :current_fg_uuid => "", 
		  :current_event_uid => serve.cause.event.uid }
	end
end

node :cookie_life do |serve|
	Setting.first.cookie_life
end

node do |serve|
 { :merchant => partial("api/v1/api/merchant", :object => serve.promotion.merchant) }
end

node do |serve|
 { :paths => partial("api/v1/api/share_links", :object => serve) }
end

node :display_order do |serve|
	serve.promotion.channels.where("active = ? and visible = ?", true, true).order('name').pluck(:name)
end

node do |serve|
 { :promotion => partial("api/v1/api/promotions", :object => serve.promotion) }
end

node do |serve|
 { :channels => partial("api/v1/api/channels", :object => serve.promotion) }
end

# Unused Stuff:

#node :promotion do |serve|
#	serve.promotion
#end

#node :merchant do |serve|
#	serve.promotion.merchant
#end

#node :channels do |channels|
#	serve.promotion.channel_ids do |channel_id|
#		Channel.find(channel_id).name
#	end
#end

#node :promotion_name do |serve|
#	Promotion.find(serve.promotion_id)
#end

#node :channels do |serve|
# { :channels => partial("api/channels", :object => serve.promotion.channels) }
#end

#node :merchant_name do |serve|
#	serve.promotion.merchant.name
#end

#node :merchant_id do |serve|
#	serve.promotion.merchant.id
#end

#child :shares  do 
#	attributes :link_id,  if: lambda { |m| m.channel_id == Channel.find_by_name('Purchase').id } 
#end

