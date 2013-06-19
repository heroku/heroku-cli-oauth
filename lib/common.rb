module Heroku::OAuth
  module Common
    def headers
      { "Accept" => "application/vnd.heroku+json; version=3" }
    end
  end
end
