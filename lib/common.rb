module Heroku::OAuth
  module Common
    def encode_json(data)
      Heroku::API::OkJson.encode(stringify_keys(data))
    end

    def headers
      { "Accept" => "application/vnd.heroku+json; version=3" }
    end

    def request
      yield
    rescue Heroku::API::Errors::RequestFailed => e
      payload = Heroku::API::OkJson.decode(e.response.body)
      raise(Heroku::Command::CommandFailed, payload["message"])
    end

    def stringify_keys(data)
      Hash[data.map{ |k, v| [k.to_s, v] }]
    end
  end
end
