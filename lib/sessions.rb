# manage currently logged in OAuth sessions
#
class Heroku::Command::Sessions < Heroku::Command::Base
  include Heroku::OAuth::Common

  # sessions
  #
  # List active sessions for your account
  #
  def index
    sessions = json_decode(heroku.get("/oauth/sessions", headers))
    styled_header("OAuth Sessions")
    styled_array(sessions.map { |session|
      [session["description"], session["id"]]
    })
  end

  # sessions:destroy [ID]
  #
  # destroy (i.e. log out) session identified by the ID
  #
  def destroy
    id = shift_argument ||
      raise(Heroku::Command::CommandFailed, "Usage: sessions:destroy [ID]")
    session = json_decode(heroku.delete("/oauth/sessions/#{id}", headers))
    puts "Destroyed '#{session["description"]}'"
  end
end
