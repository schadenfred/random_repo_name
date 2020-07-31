require 'byebug'
require 'sequel'

## Original ethod names were descriptive, but because they're 
## descriptive, there's the risk some other piece of code in our app may
## already using them. Let's keep these good method names but move
## them into the DinoTools namespace and then create a re-usable class for the 
## next time we acquire a bunch of cheap dinos. 

module DinoTools
  
  class WelcomeUsers 
    
    ## Original code isn't easy to configure. Let's create an initialize method
    ## in the class. 
    
    def initialize(user_ids, interval=nil, batch_size=nil)
      @total_notices_sent = 0
      @attempts           = 0
      
      ## Next time we acquire a bunch of dinos, let's make it so we can use the 
      ## initizlize the notifier with their owner id's. 
      @user_ids           = user_ids
      
      ## Let's make the interval configurable both for testing
      ## purposes and because we may wisht to try different intervals in  
      ## production.
      @interval           = interval || 3600 

      ## For the same reason, let's make batch_size configurable.
      ## For the same reason, let's make batch_size configurable.
      @bs                 = batch_size  || 59
      
      ## This isn't part of the original behavior, but let's collect 
      ## our failures to handle later.
      @failed_to_notify   = []
    end 
    
    def notify_all
      puts @user_ids.count
      @user_ids.each_slice(@bs).to_a.each { |c| c.each { |u| notify(u) } }
      sleep(@interval)
    end
    
    def notify(user_id)
      begin
        DB.transaction do
          send_welcome_email(user_id)
          @attempts +=1
          @total_notices_sent +=1 
          puts user_id
          puts "Attempt: #{@attempts}"
          puts "Total: #{@total_notices_sent}"
        end
      rescue RuntimeError => ex
        @attempts += 1
        ## Doesn't change behavior, but stores failures.
        @user_ids.delete(user_id)
        @failed_to_notify << { user_id: user_id, exception: ex }  
      end  
    end
    
    def send_welcome_email(user_id)
      
      ## Not really sure about some of this syntax so I'm not going to mess with it.
      user = User[user_id]
      dino = Dinosaur.where(creator_id: user.id).order(Sequel.desc(:created_at)).first

      ## We're only emailing owners of our acquired dinos. If an owner has
      ## no dinos, we have bad data. We have this behavior already, but by 
      ## moving dino up and handling the case of no dinos, we're saving time.
      
      raise "no dinos" unless dino
      
      uuid = SecureRandom.uuid
      bytes = SecureRandom.random_bytes(19)
      token = Base64.urlsafe_encode64( uuid + bytes )
      url = "https://fakewebaddress.com/#/reset/#{token}"
      PasswordResetToken.create(user_id: user.id, token: token)
      dino.emit_notification(user, 'special_welcome', { dino: dino, url: url })
    end
  end 
end 

