# manage OAuth authorizations under your account
#
class Heroku::Command::Authorizations < Heroku::Command::Base
  include Heroku::OAuth::Common

  # authorizations
  #
  # List authorizations
  #
  def index
    authorizations = json_decode(heroku.get("/oauth/authorizations", headers))
    styled_header("Authorizations")
    styled_array(authorizations.map { |auth|
      [auth["description"] || "", auth["id"], auth["scope"].join(", ")]
    })
  end

  # authorizations:create
  #
  # Create a new authorization giving access to your Heroku account
  #
  # -d, --description DESCRIPTION # set a custom authorization description
  # -s, --scope SCOPE             # set a custom OAuth scope
  #
  def create
    token = json_decode(heroku.post("/oauth/authorizations", options, headers))
    puts "Created OAuth authorization"
    puts "  ID:          #{token["id"]}"
    puts "  Description: #{token["description"]}"
    puts "  Scope:       #{token["scope"].join(", ")}"
    puts "  Token:       #{token["access_token"]["token"]}"
  end

  # authorizations:revoke [ID]
  #
  # Revoke authorization
  #
  def revoke
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: authorizations:revoke [ID] [options]")
    auth = json_decode(heroku.delete("/oauth/authorizations/#{CGI.escape(id)}", headers))
    puts "Revoked authorization from '#{auth["description"]}'"
  end
end
