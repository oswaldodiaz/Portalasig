ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :domain               => "www.ciens.ucv.ve/portalasig",
  :user_name            => "portaldesitioswebcienciasucv@gmail.com",
  :password             => "portaldesitiosweb",
  :authentication       => "plain",  
  :enable_starttls_auto => true  
}

ActionMailer::Base.default_url_options[:host] = "www.ciens.ucv.ve/portalasig"