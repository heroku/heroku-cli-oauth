# manage OAuth authorizations under your account
#
class Heroku::Command::Authorizations < Heroku::Command::Base
  include Heroku::OAuth::Common

  # authorizations
  #
  # List authorizations
  #
  def index
    authorizations = request do
      api.request(
        :expects => 200,
        :headers => headers,
        :method  => :get,
        :path    => "/oauth/authorizations"
      ).body
    end
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
  # -s, --scope SCOPE             # set custom OAuth scopes
  #
  def create
    options[:scope] = options[:scope].split(",") if options[:scope]
    token = request do
      api.request(
        :body    => encode_json(options),
        :expects => 201,
        :headers => headers,
        :method  => :post,
        :path    => "/oauth/authorizations"
      ).body
    end
    puts "Created OAuth authorization."
    puts "  Client:      #{token["client"] ? token["client"]["name"] : "<none>"}"
    puts "  ID:          #{token["id"]}"
    puts "  Description: #{token["description"]}"
    puts "  Scope:       #{token["scope"].join(", ")}"
    puts "  Token:       #{token["access_token"]["token"]}"
  end

  # authorizations:update
  #
  # Create a new authorization giving access to your Heroku account
  #
  # -d, --description DESCRIPTION       # set a custom authorization description
  #     --client-id CLIENT_ID           # identifier of OAuth client to set
  #     --client-secret CLIENT_SECRET   # secret of OAuth client to set
  #
  def update
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: authorizations:update [ID] [options]")
    params = {
      client: options[:client_id] ?
        { id: options[:client_id], secret: options[:client_secret] } :
        nil,
      description: options[:description]
    }
    token = request do
      api.request(
        :body    => encode_json(options),
        :expects => 200,
        :headers => headers,
        :method  => :patch,
        :path    => "/oauth/authorizations/#{CGI.escape(id)}"
      ).body
    end
    puts "Updated OAuth authorization."
    puts "  Client:      #{token["client"] ? token["client"]["name"] : "<none>"}"
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
    authorization = request do
      api.request(
        :expects => 200,
        :headers => headers,
        :method  => :delete,
        :path    => "/oauth/authorizations/#{CGI.escape(id)}"
      ).body
    end
    puts %{Revoked authorization from "#{authorization["description"]}".}
  end
end
