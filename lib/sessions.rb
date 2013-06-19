# manage currently logged in OAuth sessions
#
class Heroku::Command::Sessions < Heroku::Command::Base
  include Heroku::OAuth::Common

  # sessions
  #
  # List active sessions for your account
  #
  def index
    sessions = api.request(
      :expects => 200,
      :headers => headers,
      :method  => :get,
      :path    => "/oauth/sessions"
    ).body
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
    session = api.request(
      :expects => 200,
      :headers => headers,
      :method  => :delete,
      :path    => "/oauth/sessions/#{CGI.escape(id)}"
    ).body
    puts "Destroyed '#{session["description"]}'"
  end
end
