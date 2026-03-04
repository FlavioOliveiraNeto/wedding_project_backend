Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.test?

class Rack::Attack
  throttle("rsvp/show", limit: 30, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{^/api/v1/rsvp/}) && req.get?
  end

  throttle("rsvp/update", limit: 5, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{^/api/v1/rsvp/}) && req.patch?
  end

  throttle("gift_select/ip", limit: 20, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{^/api/v1/gifts/\d+/select$}) && req.post?
  end

  throttle("guests/search", limit: 60, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/guests/search" && req.get?
  end

  self.throttled_responder = lambda do |_env|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { error: "Muitas tentativas. Tente novamente em instantes." }.to_json ]
    ]
  end
end
