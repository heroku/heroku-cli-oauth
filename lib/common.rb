module Heroku::OAuth
  module Common
    def encode_json(data)
      Heroku::Helpers.json_encode(stringify_keys(data))
    end

    def headers
      { "Accept" => "application/vnd.heroku+json; version=3" }
    end

    def request
      yield
    rescue Heroku::API::Errors::RequestFailed, Heroku::API::Errors::ErrorWithResponse => e
      payload = Heroku::Helpers.json_decode(e.response.body)
      raise(Heroku::Command::CommandFailed, payload["message"])
    end

    def stringify_keys(data)
      Hash[data.map{ |k, v| [k.to_s, v] }]
    end
  end
end
