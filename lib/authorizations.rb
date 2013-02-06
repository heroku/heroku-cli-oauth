# manage OAuth authorizations under your account
#
class Heroku::Command::Authorizations < Heroku::Command::Base
  # authorizations
  #
  # List authorizations
  #
  def index
    authorizations = json_decode(heroku.get("/oauth/authorizations"))
    styled_header("Authorizations")
    styled_array(authorizations.map do |auth|
      [auth["description"], auth["id"], auth["scopes"].join(", ")]
    end)
  end

  # authorizations:create
  #
  # Create a new authorization giving access to your Heroku account
  #
  # -d, --description DESCRIPTION # set a custom authorization description
  # -s, --scope SCOPE             # set a custom OAuth scope
  #
  def create
    token = json_decode(heroku.post("/oauth/authorizations", options))
    puts "Created OAuth authorization"
    puts "  ID:          #{token["id"]}"
    puts "  Description: #{token["description"]}"
    puts "  Scope:       #{token["scopes"].join(", ")}"
    puts "  Token:       #{token["access_tokens"][0]["token"]}"
  end

  # authorizations:revoke [ID]
  #
  # Revoke authorization
  #
  def revoke
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: authorizations:revoke [ID] [options]")
    auth = json_decode(heroku.delete("/oauth/authorizations/#{CGI.escape(id)}"))
    puts "Revoked authorization from '#{auth["description"]}'"
  end
end
