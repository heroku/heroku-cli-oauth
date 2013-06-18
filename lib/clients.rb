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
  # -s, --shell  # output config vars in shell format
  #
  def create
    name = shift_argument
    url  = shift_argument

    unless name && url
      raise(Heroku::Command::CommandFailed, "Usage: clients:create [NAME] [CALLBACK_URL]")
    end

    validate!(url)

    raw = heroku.post("/oauth/clients",
      { :name => name, :redirect_uri => url })
    client = json_decode(raw)

    if options[:shell]
      puts
      puts "HEROKU_KEY=#{client["id"]}"
      puts "HEROKU_SECRET=#{client["secret"]}"
    else
      styled_header("Created client #{name}")
      styled_hash(client)
    end
  end

  # clients:show [ID]
  #
  # show details for an OAuth client
  #
  # -s, --shell # output config vars in shell format
  #
  def show
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:show [ID]")

    raw = api.request(
      :expects => 200,
      :method  => :get,
      :path    => "/oauth/clients/#{id}")

    client = raw.body

    if options[:shell]
      puts
      puts "HEROKU_KEY=#{client["id"]}"
      puts "HEROKU_SECRET=#{client["secret"]}"
    else
      styled_header("Client #{client["name"]}")
      styled_hash(client)
    end
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
    options[:redirect_uri] = options.delete(:url)

    raw = api.request(
      :expects => 200,
      :method  => :patch,
      :path    => "/oauth/clients/#{id}",
      :query   => options)

    client = raw.body
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
    if insecure_url?(uri)
      raise(Heroku::Command::CommandFailed, "Unsupported callback URL. Clients have to use HTTPS")
    end
  rescue URI::InvalidURIError
    raise(Heroku::Command::CommandFailed, "Invalid callback URL. Make sure it's a valid, HTTPS URL")
  end

  def insecure_url?(uri)
    return false if uri.scheme == "https"
    # allow localhost, 10.* and 192.* clients for testing
    return false if uri.host == "localhost"
    return false if uri.host =~ /\A(10\.|192\.)/
    true
  end
end
