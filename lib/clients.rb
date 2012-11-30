# manage OAuth clients on the platform
#
class Heroku::Command::Clients < Heroku::Command::Base
  # clients
  #
  # List clients under your account
  #
  def index
    clients = json_decode(heroku.get("/oauth/clients"))
    styled_header("OAuth Clients")
    styled_array(clients.map { |client| [client["name"], client["id"], client["redirect_uri"]] })
  end

  # clients:create [NAME] [CALLBACK_URL]
  #
  # create a new OAuth client
  #
  def create
    name = shift_argument
    url  = shift_argument

    unless name && url
      raise(Heroku::Command::CommandFailed, "Usage: clients:create [NAME] [CALLBACK_URL]")
    end

    validate!(url)

    raw = heroku.post("/oauth/clients", :client => {
      :name => name,
      :redirect_uri => url,
    })
    client = json_decode(raw)
    puts "Created client #{name}"
    puts "  ID:     #{client["id"]}"
    puts "  Secret: #{client["secret"]}"
  end

  # clients:update [ID]
  #
  # create a new OAuth client
  #
  # -n, --name NAME  # change the client name
  #     --url  URL   # change the client redirect URL
  #
  def update
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:destroy [ID] [options]")

    if options.empty?
      raise(Heroku::Command::CommandFailed, "Missing options")
    end

    validate!(options[:url]) if options[:url]

    raw = heroku.put("/oauth/clients/#{id}", :client => options)
    client = json_decode(raw)
    puts "Updated client #{client["name"]}"
  end

  # clients:destroy [ID]
  #
  # delete client identified by the ID
  #
  def destroy
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:destroy [ID]")
    client = json_decode(heroku.delete("/oauth/clients/#{id}"))
    puts "Deleted client #{client["name"]}"
  end

  protected

  def validate!(url)
    uri = URI.parse(url)
    if uri.scheme != "https"
      raise(Heroku::Command::CommandFailed, "Unsupported callback URL. Clients have to use HTTPS")
    end
  rescue URI::InvalidURIError
    raise(Heroku::Command::CommandFailed, "Invalid callback URL. Make sure it's a valid, HTTPS URL")
  end

end
