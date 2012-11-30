# manage OAuth tokens under your account
#
class Heroku::Command::Tokens < Heroku::Command::Base
  # tokens:create
  #
  # Create a new token giving access to your Heroku account
  #
  # -s, --scope SCOPE  # set a custom OAuth scope
  #
  def create
    options.merge! :grant_type => "authorization_code"
    token = json_decode(heroku.post("/oauth/token", options))
    puts "Created OAuth token"
    puts "  Scope:   #{token["scope"]}"
    puts "  Access:  #{token["access_token"]}"
    puts "  Refresh: #{token["refresh_token"]}"
    puts "  Expires: #{token["expires_in"]}"
  end
end
