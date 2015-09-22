# manage OAuth authorizations under your account
#
class Heroku::Command::Authorizations < Heroku::Command::Base
  include Heroku::OAuth::Common

  DEFAULT_OUTPUT_FORMAT = 'long'

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
  # -e, --expires_in SECONDS      # set expiration in seconds
  # -f, --output_format FORMAT    # output format of the oauth information.  A value of short only outputs the token.
  #
  def create
    payload = {
      "description" => options[:description],
      "scope"       => options[:scope] ? options[:scope].split(",") : nil,
      "expires_in" => options[:expires_in]
    }
    token = request do
      api.request(
        :body    => encode_json(payload),
        :expects => 201,
        :headers => headers,
        :method  => :post,
        :path    => "/oauth/authorizations"
      ).body
    end
    output_format = options[:output_format] || DEFAULT_OUTPUT_FORMAT
    puts "Created OAuth authorization." unless output_format == 'short'
    show_authorization(token, output_format: output_format)
  end

  # authorizations:info
  #
  # Shows an existing authorization that gives access to your Heroku account
  #
  def info
    id = shift_argument || raise(Heroku::Command::CommandFailed, "Usage: authorizations:update [ID] [options]")
    token = request do
      api.request(
        :expects => 200,
        :headers => headers,
        :method  => :get,
        :path    => "/oauth/authorizations/#{CGI.escape(id)}"
      ).body
    end
    puts "Showing OAuth authorization."
    show_authorization(token)
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
    payload = {
      "client" => options[:client_id] ?
      {
        "id"     => options[:client_id],
        "secret" => options[:client_secret]
      } :
      nil,
      "description" => options[:description]
    }
    token = request do
      api.request(
        :body    => encode_json(payload),
        :expects => 200,
        :headers => headers,
        :method  => :patch,
        :path    => "/oauth/authorizations/#{CGI.escape(id)}"
      ).body
    end
    puts "Updated OAuth authorization."
    show_authorization(token)
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

  private

  def show_authorization(authorization, options = {})
    output_format = options[:output_format] || DEFAULT_OUTPUT_FORMAT
    if output_format ==  DEFAULT_OUTPUT_FORMAT
      puts "  Client:      #{authorization["client"] ? authorization["client"]["name"] : "<none>"}"
      puts "  ID:          #{authorization["id"]}"
      puts "  Description: #{authorization["description"]}"
      puts "  Scope:       #{authorization["scope"].join(", ")}"
      puts "  Token:       #{authorization["access_token"]["token"]}"
    else
      puts authorization["access_token"]["token"]
    end
  end
end
