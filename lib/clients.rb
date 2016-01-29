# manage OAuth clients on the platform
#
class Heroku::Command::Clients < Heroku::Command::Base
  include Heroku::OAuth::Common

  # clients
  #
  # List clients under your account
  #
  def index
    clients = request do
      api.request(
        :expects => 200,
        :headers => headers,
        :method  => :get,
        :path    => "/oauth/clients"
      ).body
    end
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
      raise(Heroku::Command::CommandFailed, "Usage: clients:register [NAME] [CALLBACK_URL]")
    end

    validate!(url)
    client = request do
      api.request(
        :body    => encode_json(
          { :name => name, :redirect_uri => url }),
        :expects => 201,
        :headers => headers,
        :method  => :post,
        :path    => "/oauth/clients"
      ).body
    end

    if options[:shell]
      puts "HEROKU_OAUTH_ID=#{client["id"]}"
      puts "HEROKU_OAUTH_SECRET=#{client["secret"]}"
    else
      styled_header(%{Registered client "#{name}".})
      styled_hash(client)
    end
  end

  alias_command "clients:register", "clients:create"

  # clients:show [ID]
  #
  # show details for an OAuth client
  #
  # -s, --shell # output config vars in shell format
  # -x, --extended  # Show extended information
  #
  def show
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:show [ID]")

    path = "/oauth/clients/#{CGI.escape(id)}"
    if options[:extended]
      path += '?extended=true'
    end

    client = request do
      api.request(
        :expects => 200,
        :headers => headers,
        :method  => :get,
        :path    => path
      ).body
    end

    if options[:shell]
      puts "HEROKU_OAUTH_ID=#{client["id"]}"
      puts "HEROKU_OAUTH_SECRET=#{client["secret"]}"
    else
      styled_header(%{Client "#{client["name"]}".})
      styled_hash(client)
    end
  end

  alias_command "clients:info", "clients:show"

  # clients:update [ID]
  #
  # update OAuth client
  #
  # -n, --name NAME  # change the client name
  # -s, --shell      # output config vars in shell format
  #     --url  URL   # change the client redirect URL
  #
  def update
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:update [ID] [options]")

    if options.empty?
      raise(Heroku::Command::CommandFailed, "Missing options")
    end

    validate!(options[:url]) if options[:url]
    shell = options.delete(:shell)
    options[:redirect_uri] = options.delete(:url)

    client = request do
      api.request(
        :body    => encode_json(options),
        :expects => 200,
        :headers => headers,
        :method  => :patch,
        :path    => "/oauth/clients/#{CGI.escape(id)}"
      ).body
    end

    if shell
      puts "HEROKU_OAUTH_ID=#{client["id"]}"
      puts "HEROKU_OAUTH_SECRET=#{client["secret"]}"
    else
      styled_header(%{Updated client "#{client["name"]}".})
      styled_hash(client)
    end
  end

  # clients:destroy [ID]
  #
  # delete client identified by the ID
  #
  def destroy
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: clients:destroy [ID]")
    client = request do
      api.request(
        :expects => 200,
        :headers => headers,
        :method  => :delete,
        :path    => "/oauth/clients/#{CGI.escape(id)}"
      ).body
    end
    puts "Deregistered client '#{client["name"]}'."
  end

  alias_command "clients:deregister", "clients:destroy"

  protected

  def validate!(url)
    uri = URI.parse(url)
    if insecure_url?(uri)
      raise(Heroku::Command::CommandFailed, "Unsupported callback URL. Clients have to use HTTPS.")
    end
  rescue URI::InvalidURIError
    raise(Heroku::Command::CommandFailed, "Invalid callback URL. Make sure it's a valid, HTTPS URL.")
  end

  def insecure_url?(uri)
    return false if uri.scheme == "https"
    # allow localhost, 10.* and 192.* clients for testing
    return false if uri.host == "localhost"
    return false if uri.host =~ /\.local\z/
    return false if uri.host =~ /\A(10\.|192\.)/
    true
  end

  def styled_hash(client)
    client.delete("trusted")
    super
  end
end
