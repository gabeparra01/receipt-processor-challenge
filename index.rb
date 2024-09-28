# frozen_string_literal: true

require 'securerandom'
require 'socket'
require_relative 'create_receipt'
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

      # Break apart header fields to get the
      # Content-Length which will help us get the body
      # of the message
      all_headers = {}

      loop do
        line = client.readline
        break if line == "\r\n"

        header_name, value = line.split(': ')
        all_headers[header_name] = value
      end

      body = client.read(all_headers['Content-Length'].to_i)
      new_receipt = JSON.parse(body)
      points = 0
      points += new_receipt['retailer'].gsub(/[^0-9a-z]/i, '').size
      points += 5 * (new_receipt['items'].size / 2)
      points += 25 if new_receipt['total'].to_f % 0.25 == 0.0
      points += 50 if new_receipt['total'].to_f % 1.00 == 0.0
      points += 6 if new_receipt['purchaseDate'].split('-')[2].to_i.odd?
      if new_receipt['purchaseTime'].split(':')[0].to_i >= 14 && new_receipt['purchaseTime'].split(':')[1].to_i.positive? && new_receipt['purchaseTime'].split(':')[0].to_i < 16
        points += 10
      end

      new_receipt['items'].each do |item|
        points += (item['price'].to_f * 0.2).ceil if (item['shortDescription'].strip.size % 3).zero?
      end

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
