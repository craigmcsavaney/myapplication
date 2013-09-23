class ApiController < ApplicationController
  def serve
    # This is the main api method that serves all the intial widget load information.
    # This call accepts the following inputs: merchant_id, callback, [session_id], 
    # [serve_id], and [path].  merchant_id and callback are required on all calls 
    # and an error message will be returned if either is missing.

    # If a session_id is available (stored in the CB session cookie), it should be
    # passed in as it will significantly speed up processing of the api request.

    # If a serve_id is available (stored in the CB permanent cookie), it should be
    # passed in so any user-supplied data (email, cause, etc.) can be returned.

    # If a path value can be obtained from the referring url, it should be passed in
    # so we can determine who referred this visitor and if they are being referred 
    # by a new referrer.  The path value should never be obtained from the awe.sm
    # cookie as the cookie may or may not contain the path from the current 
    # referring url, depending on execution timing of the CB scripts and the awe.sm
    # script that updates the cookie.

    # Also, the path is checked against share paths for the current serve_id to 
    # determine if the user referred themselves back to the same site using
    # one of their own share links.  If so, we don't treat this as a new
    # referral.

    # The json response will always include a value for the purchase path, 
    # identified as pur_path.  This value must always be used to update the
    # path value in the awe.sm cookie.  The json will also contain a session_id,
    # which should be written to a CB session cookie, and a serve_id, which should
    # be written to the permanent CB cookie.


    # first, verify that a callback parameter was passed
    if params[:callback].nil?
        render 'api/errors/missing_callback'
        return
    end

    # next, check to ensure that the merchant_id is valid and if so, get the merchant
    if Merchant.merchant_valid?(params[:merchant_id])
            merchant = Merchant.find_by_uid(params[:merchant_id])
        else
            render 'api/errors/merchant_invalid'
            return
    end

    # Set the check_date to today.  Used to search for valid promotions
    check_date = Date.today

    # Get merchant's current promotion. If no valid promotion exists, return an error
    @current = Current.get_current_promotion(check_date,merchant)
    if @current[:promotion] == nil
        # No current promotion found
        render 'api/errors/no_valid_promotion'
        return
    end

    # next, check to see if a valid session_id (one that is associated with
    # the current merchant) was passed in.  If so, serve the promotion associated
    # with this session_id
    if Serve.session_valid?(params[:session_id],merchant)
        @serve = Serve.find_by_session_id(params[:session_id])
        render 'serve'
        return
    end

    # Since we made it to this point, this must be a new session, and a valid current
    # promotion has been successfully identified.  Now set the promotion variable
    # equal to the current promotion:
    @promotion = @current[:promotion]
    # Check to see if valid serve_id and path were passed in.
	serve_valid = !Serve.not_exists?(params[:serve_id])
	path_valid = Share.path_valid?(params[:path])
    # Now determine if the current promotion is the same as the old promotion
    if serve_valid && Serve.find(params[:serve_id]).promotion_id == @promotion.id
            promotion_same = true
        else
            promotion_same = false
    end

    # Once a visitor has clicked the cause button and we have created a serve and
    # shares for them, it's possible that they may click one of the share links to 
    # test it out.  In this case, they will appear to be coming from a new referring
    # url.  We need to check the url and see if it's associated with any of the shares 
    # of the current serve.  If it is, we need to ignore it by treating it as
    # an invalid path.
    if serve_valid && path_valid && Serve.find(params[:serve_id]).shares.pluck(:link_id).include?(params[:path])
            path_valid = false
    end

    # Now determine if the referring path has changed for valid serves and valid paths
    if serve_valid && path_valid && Serve.find(params[:serve_id]).share.link_id == params[:path]
            path_same = true
    else
            path_same = false
    end

    # Now, using the serve, path, and promotion variables set above,
    # examine the different cases and take appropriate actions to find, create,
    # update, and serve the correct promotion to this visitor
	case
    	# First case, when serve_id and path weren't passed in or don't match
    	# existing records.  Typically, this is a first time, non-referred visitor 
    	when !serve_valid && !path_valid
    		# create a new serve using the current promotion
    		@serve = Serve.create(promotion_id: @promotion.id)

    	# Second case, when serve_id is invalid and path is valid.
    	# Typically, this is a first time, referred visitor 
    	when !serve_valid && path_valid
    		# create a new serve using the current promotion and the share_id associated with the path
            # first, get the share associated with the referring path
            @referring_share = Share.find_by_link_id(params[:path])
            # now, create the new serve
    		@serve = Serve.create(promotion_id: @promotion.id, referring_share_id: @referring_share.id)

        # Third case, when the serve is valid and the current promotion hasn't changed
        # but either the path is invalid or is the same as the stored referring path
        when serve_valid && promotion_same && (!path_valid || path_same)
            # we're just going to serve up the old promotion here, but with a new session_id
            session_id = Serve.new_session_id
            Serve.find(params[:serve_id]).update_attributes(session_id: session_id)
            @serve = Serve.find(params[:serve_id]) # reload the old serve with the new session_id

        # Fourth case, when the serve is valid but the incoming path is new (and valid)
        # This means the visitor is returning to the same site, but was referred here
        # by someone new.
        when serve_valid && path_valid && !path_same
            # We're going to create a new serve for this visitor and copy over the
            # cause and email info from the previous serve if possible.  Also, if the
            # previous serve wasn't viewed, we'll delete it and all its shares.
            @old = Serve.find(params[:serve_id])
            @referring_share = Share.find_by_link_id(params[:path])
            @serve = Serve.create(promotion_id: @promotion.id, email: @old.email, referring_share_id: @referring_share.id, current_cause_id: @old.current_cause_id)

            #if !@old.viewed?
                # delete the old serve and its associated shares
            #end

        # Fifth case, when the serve is valid, the promotion has changed, and the path is either invalid or is the same as the stored referring path
        when serve_valid && !promotion_same && (!path_valid || path_same)
            # This is basically the case where the promotion has changed, so if the
            # serve hasn't been viewed yet, we'll just update it with the new promotion
            # and a new session_id.
            # If the serve has been viewed, we'll create a new serve and copy over the
            # cause, email, and referring_share info if possible.
            @old = Serve.find(params[:serve_id])
            if @old.viewed?
                @serve = Serve.create(promotion_id: @promotion.id, email: @old.email, referring_share_id: @old.referring_share_id, current_cause_id: @old.current_cause_id)
            else
                session_id = Serve.new_session_id
                Serve.find(params[:serve_id]).update_attributes(promotion_id: @promotion.id, session_id: session_id)
                @serve = Serve.find(params[:serve_id])
            end
        else
            render 'api/errors/unrecognized_case'
            return
	end
    puts @serve.id
    render 'serve'
  end

  def view
    # inputs: merchant_id, session_id, callback
    # first, verify that a callback parameter was passed
    if params[:callback].nil?
        render 'api/errors/missing_callback'
        return
    end

    # next, check to ensure that the merchant_id is valid and if so, get the merchant
    if Merchant.merchant_valid?(params[:merchant_id])
            merchant = Merchant.find_by_uid(params[:merchant_id])
        else
            render 'api/errors/merchant_invalid'
            return
    end

    # next, check to see if a valid session_id (one that is associated with
    # the current merchant) was passed in.  If so, mark the serve as viewed.  If not,
    # return a session_invalid error message
    if Serve.session_valid?(params[:session_id],merchant)
            Serve.find_by_session_id(params[:session_id]).update_attributes(viewed: true)
            render 'success'
            return
        else
            render 'api/errors/session_invalid'
            return
    end
  end

  def update
  	# inputs: merchant_id, session_id, serve_id, email, cause_id, callback
  	# if session_id is blank, render error message
    # first, verify that a callback parameter was passed
    if params[:callback].nil?
        render 'api/errors/missing_callback'
        return
    end

    # next, check to ensure that the merchant_id is valid and if so, get the merchant
    if Merchant.merchant_valid?(params[:merchant_id])
            merchant = Merchant.find_by_uid(params[:merchant_id])
        else
            render 'api/errors/merchant_invalid'
            return
    end

    # next, check to see if a valid session_id (one that is associated with
    # the current merchant) was passed in.  If so, get the subject serve.  If not,
    # return a session_invalid error message
    if Serve.session_valid?(params[:session_id],merchant)
            @serve = Serve.find_by_session_id(params[:session_id])
        else
            render 'api/errors/session_invalid'
            return
    end
  	# add or update email
    if @serve.email != params[:email]
        @serve.update_attributes(email: params[:email])
    end
    # add or update most_recent_cause_id
    if @serve.current_cause_id != params[:cause_id]
        @serve.update_attributes(current_cause_id: params[:cause_id])
        # if cause changed from most recent, return new paths for email and purchase
    end

  	# render success message
  end

  def post
    # inputs: merchant_id, session_id, share path, cause_id, [email]
    # if session_id is blank, render error message
    # mark share as confirmed
    # add cause_id to share
    # add or update most_recent_cause_id
    # add or update email (if present)
    # return new path for this channel
    # if cause changed from most recent, return new paths for email and purchase
    # render success message
  end

end