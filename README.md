# receipt-processor-challenge
- My implementation of the [Fetch](https://fetch.com/) receipt processor web service challenge
- The instructions state that the engineer evaluating submissions may not have an environment setup for every programming language. Also, the development environment should be able to support any operating system.
  - My goal for this implementation is to keep the project setup as simple as possible to achieve the above requirements. That is why I created a pure Ruby project without a Gemfile or bundler (dependency management)

## Setup Instructions
- First, after cloning this project repository, navigate to the root directory of the project with `cd receipt-processor-challenge`
- Next, please follow the instructions based on the operating system
### Mac
- I used the default Ruby version for this operating system.
- Start the server with the following command:
```
ruby index.rb
```
-Troubleshooting: If any issues occur, please follow the Windows/Linux (Docker) setup instructions
### Windows/Linux
- Run the following commands to build and run the Docker image needed for the Ruby environment:
```
docker build -t receipt_processor .
docker run -p 1337:1337 receipt_processor
```

## Testing
- The server has been configured to run on port 1337. Requests can be sent to the server with the following url:
```
http://localhost:1337
```
- Per the requirements of the challenge, the follow endpoints are available:
### Endpoint: Process Receipts
* Path: `/receipts/process`
* Method: `POST`
* Payload: Receipt JSON
* Response: JSON containing an id for the receipt.
### Endpoint: Get Points
* Path: `/receipts/{id}/points`
* Method: `GET`
* Response: A JSON object containing the number of points awarded.


### Example Requests
- For convenience, here are a few example requests that can be sent to the server.
  - Note: These requests are written in Ruby and the setup instructions will need to be completed before running the example code.
- Each request can be saved to its own file and run with:
```
ruby <file_name>.rb
```
- POST request:
```
require 'uri'
require 'json'
require 'net/http'

uri = URI.parse('http://localhost:1337/receipts/process')
request = Net::HTTP::Post.new(uri)
req_options = {
  use_ssl: uri.scheme == 'https',
  content_type: 'application/json'
}
request.body = JSON.dump({
                           "retailer": 'Target',
                           "purchaseDate": '2022-01-01',
                           "purchaseTime": '13:01',
                           "items": [
                             {
                               "shortDescription": 'Mountain Dew 12PK',
                               "price": '6.49'
                             }, {
                               "shortDescription": 'Emils Cheese Pizza',
                               "price": '12.25'
                             }, {
                               "shortDescription": 'Knorr Creamy Chicken',
                               "price": '1.26'
                             }, {
                               "shortDescription": 'Doritos Nacho Cheese',
                               "price": '3.35'
                             }, {
                               "shortDescription": '   Klarbrunn 12-PK 12 FL OZ  ',
                               "price": '12.00'
                             }
                           ],
                           "total": '35.35'
                         })

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

puts JSON.parse(response.body)
```
- GET request:
```
require 'json'
require 'net/http'
require 'uri'


uri = URI.parse('http://localhost:1337/receipts/#{ID}/points')
request = Net::HTTP::Get.new(uri)
req_options = {
  use_ssl: uri.scheme == 'https',
  content_type: 'application/json'
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

data = JSON.parse(response.body)

puts data
```
  - Note: The response from the POST request will contain the value that should be used for ID.
    - Example with an ID value of 123: `uri = URI.parse('http://localhost:1337/receipts/123/points')`