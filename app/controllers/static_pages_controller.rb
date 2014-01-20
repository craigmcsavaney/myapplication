class StaticPagesController < ApplicationController
	layout false, only: :landing

  	def home
      # create new message object for the contact_message form on the home page
      @message = ContactMessage.new
      # check to see if message params were passed in and if they were, use the values
      # in the newly created message object.  These get passed in for all failed
      # contact_message creations.  Successful creations pass back blank params.
      if params[:first_name]
        @message.first_name = params[:first_name]
      end
      if params[:last_name]
        @message.last_name = params[:last_name]
      end
      if params[:phone]
        @message.phone = params[:phone]
      end
      if params[:email]
        @message.email = params[:email]
      end
      if params[:message]
        @message.message = params[:message]
      end
  	end

  	def help
  	end

  	def about
  	#TestMailer.welcome_email2.deliver
  	end

  	def contact
  	end

    def landing
    end

end
