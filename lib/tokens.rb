# manage OAuth tokens
#
class Heroku::Command::Tokens < Heroku::Command::Base
  # tokens
  #
  # List active OAuth tokens
  #
  def index
    tokens = []
    json_decode(heroku.get("/oauth/authorizations")).each do |auth|
      %w( access_tokens refresh_tokens ).each do |type|
        auth[type].each do |token|
          client = auth["client"] || {}
          tokens << token.merge!(
            "authorization" => auth["id"],
            "title"         => client["name"] || auth["description"],
            "expiration"    => format_expiration(token["expires_in"]),
            "type"          => type.sub(/_.*/, "")
          )
        end
      end
    end

    # sort by title, type, expires_in
    tokens.sort_by! { |token| "#{token["title"]} #{token["type"]} #{token["expires_in"]}" }

    columns = %w( title authorization type expiration )
    display_table(
      tokens,
      columns,
      columns.map(&:capitalize)
    )
  end

  protected

  def format_expiration(expires_in)
    return "long-lived" if expires_in.nil?
    return "expired"    if expires_in < 0
    expires_at = Time.now + expires_in
    expires_at.iso8601
  end
end
