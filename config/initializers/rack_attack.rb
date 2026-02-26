Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.test?

class Rack::Attack
  throttle("rsvp/ip", limit: 10, period: 1.hour) do |req|
    req.ip if req.path == "/api/v1/rsvp" && req.post?
  end

  throttle("gift_select/ip", limit: 20, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{^/api/v1/gifts/\d+/select$}) && req.post?
  end

  self.throttled_responder = lambda do |_env|
    [
      429,
      { "Content-Type" => "application/json" },
      [{ error: "Muitas tentativas. Tente novamente em instantes." }.to_json]
    ]
  end
end
