# manage OAuth clients on the platform
#
class Heroku::Command::Clients < Heroku::Command::Base
  include Heroku::OAuth::Common

  # clients
  #
  # List clients under your account
  #
  def index
    clients = api.request(
      :expects => 200,
      :headers => headers,
      :method  => :get,
      :path    => "/oauth/clients"
    ).body
    styled_header("OAuth Clients")
    styled_array(clients.map { |client|
      [client["name"], client["id"], client["redirect_uri"]]
    })
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
    client = api.request(
      :body    => encode_json(
        { :name => name, :redirect_uri => url }),
      :expects => 201,
      :headers => headers,
      :method  => :post,
      :path    => "/oauth/clients"
    ).body

    if options[:shell]
      puts "HEROKU_OAUTH_ID=#{client["id"]}"
      puts "HEROKU_OAUTH_SECRET=#{client["secret"]}"
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

    client = api.request(
      :expects => 200,
      :headers => headers,
      :method  => :get,
      :path    => "/oauth/clients/#{CGI.escape(id)}"
    ).body

    if options[:shell]
      puts "HEROKU_OAUTH_ID=#{client["id"]}"
      puts "HEROKU_OAUTH_SECRET=#{client["secret"]}"
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
  # -s, --shell      # output config vars in shell format
  #     --url  URL   # change the client redirect URL
  #
  def update
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:destroy [ID] [options]")

    if options.empty?
      raise(Heroku::Command::CommandFailed, "Missing options")
    end

    validate!(options[:url]) if options[:url]
    shell = options.delete(:shell)
    options[:redirect_uri] = options.delete(:url)

    client = api.request(
      :body    => encode_json(options),
      :expects => 200,
      :headers => headers,
      :method  => :patch,
      :path    => "/oauth/clients/#{CGI.escape(id)}"
    ).body

    if shell
      puts "HEROKU_OAUTH_ID=#{client["id"]}"
      puts "HEROKU_OAUTH_SECRET=#{client["secret"]}"
    else
      styled_header("Client #{client["name"]}")
      styled_hash(client)
    end
  end

  # clients:destroy [ID]
  #
  # delete client identified by the ID
  #
  def destroy
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:destroy [ID]")
    client = api.request(
      :expects => 200,
      :headers => headers,
      :method  => :delete,
      :path    => "/oauth/clients/#{CGI.escape(id)}"
    ).body
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
