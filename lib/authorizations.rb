# manage OAuth authorizations under your account
#
class Heroku::Command::Authorizations < Heroku::Command::Base
  # authorizations
  #
  # list authorizations
  #
  def index
    authorizations = json_decode(heroku.get("/oauth/authorizations"))
    styled_header("Authorizations")
    styled_array(authorizations.map do |auth|
      [auth["id"], auth["client"]["name"], auth["scope"]]
    end)
  end

  # authorizations:revoke [ID]
  #
  # Revoke authorization
  #
  def revoke
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:destroy [ID] [options]")
    auth = json_decode(heroku.delete("/oauth/authorizations/#{id}"))
    puts "Revoked authorization from #{auth["client"]["name"]}"
  end
end
