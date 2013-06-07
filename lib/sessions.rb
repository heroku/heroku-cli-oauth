# manage currently logged in OAuth sessions
#
class Heroku::Command::Sessions < Heroku::Command::Base
  # sessions
  #
  # List active sessions for your account
  #
  def index
    sessions = json_decode(heroku.get("/oauth/sessions"))
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
    session = json_decode(heroku.delete("/oauth/sessions/#{id}"))
    puts "Destroyed #{session["id"]}"
  end
end
