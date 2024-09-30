# frozen_string_literal: true

# Helper methods to separate business logic from index.rb
def calculate_points(new_receipt)
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

  points
end

def get_body(client)
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

  all_headers['Content-Length'].to_i
end
