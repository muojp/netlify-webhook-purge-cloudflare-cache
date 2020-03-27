require 'digest'
require 'json'
require 'jwt'
require 'net/http'
require 'sinatra'

def signed(request, body)
  puts request.env.to_json
  puts body
  signature = request.env["HTTP_X_WEBHOOK_SIGNATURE"]
  return unless signature

  options = {iss: "netlify", verify_iss: true, algorithm: "HS256"}
  decoded = JWT.decode(signature, ENV['NETLIFY_PRESHARED_KEY'], true, options)

  ## decoded :
  ## [
  ##   { sha256: "..." }, # this is the data in the token
  ##   { alg: "..." } # this is the header in the token
  ## ]
  decoded.first['sha256'] == Digest::SHA256.hexdigest(body)
rescue JWT::DecodeError
  puts '### Signature verification failed.'
  false
end

post "/netlify-hook" do
  request.body.rewind
  body = request.body.read
  halt 403 unless signed(request, body)

  uri = URI.parse("https://api.cloudflare.com/client/v4/zones/#{ENV['ZONE_ID']}/purge_cache")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme === "https"

  params = { purge_everything: true }
  headers = { "Content-Type" => "application/json", "Authorization" => "Bearer #{ENV['CLOUDFLARE_API_TOKEN']}" }
  response = http.post(uri.path, params.to_json, headers)

  ret = { :Output => response.code }.to_json
  puts ret
  ret
end
