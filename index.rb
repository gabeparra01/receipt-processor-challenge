# frozen_string_literal: true

require 'securerandom'
require 'socket'
require_relative 'processor_helpers'
require 'json'

SECRET = SecureRandom.hex(32)

server = TCPServer.new(1337)

# Non-persistent database
receipts = {}

loop do
  client = server.accept

  request_line = client.readline
  method_token, target, version_number = request_line.split
  response_message = ''
  path_params = target.split('/')

  case [method_token]
  when ['GET']
    if path_params[1] && path_params[1].to_s == 'receipts' && path_params[3] && path_params[3] == 'points'
      response_status_code = '200 OK'
      content_type = 'application/json'
      response_message = receipts[path_params[2]].to_json
    else
      response_status_code = '404 Bad Request'
    end
  when ['POST']
    if path_params[1] && path_params[1].to_s == 'receipts' && path_params[2] && path_params[2] == 'process'
      response_status_code = '200 OK'
      content_type = 'application/json'

      # generate UUID for each receipt
      uuid = SecureRandom.uuid
      response_message = { id: uuid }.to_json

      body = client.read(get_body(client))
      new_receipt = JSON.parse(body)
      points = calculate_points(new_receipt)

      receipts[uuid] = { points: points }
    else
      response_status_code = '404 Bad Request'
    end
  else
    response_status_code = '404 Bad Request'
  end

  # Construct the HTTP Response
  http_response = <<~MSG
    #{version_number} #{response_status_code}
    Content-Type: #{content_type}; charset=#{response_message.encoding.name}

    #{response_message}
  MSG

  client.puts http_response
  client.close
end
