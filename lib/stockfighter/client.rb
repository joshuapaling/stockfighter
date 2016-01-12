require 'httparty'
require 'json'

module Stockfighter
  class Client
    BASE_URL = 'https://api.stockfighter.io/ob/api/'

    def initialize(api_key)
      @api_key = api_key
    end

    def heartbeat(venue = nil)
      return get("venues/#{venue}/heartbeat") if venue
      get('heartbeat')
    end

    def stocks(venue)
      get("venues/#{venue}/stocks")
    end

    def orderbook(venue, stock)
      get("venues/#{venue}/stocks/#{stock}")
    end

    def new_order(venue, stock, body)
      post("#{BASE_URL}venues/#{venue}/stocks/#{stock}/orders", body)
    end

    def quote(venue, stock)
      get("venues/#{venue}/stocks/#{stock}/quote")
    end

    def order_status(venue, stock, order_id)
      get("venues/#{venue}/stocks/#{stock}/orders/#{order_id}")
    end

    def cancel_order(venue, stock, order_id)
      delete("venues/#{venue}/stocks/#{stock}/orders/#{order_id}")
    end

    def all_orders(venue, account, stock = nil)
      if stock
        return get("venues/#{venue}/accounts/#{account}/stocks/#{stock}/orders")
      end
      get("venues/#{venue}/accounts/#{account}/orders")
    end

    private

    def get(path)
      HTTParty.get("#{BASE_URL}#{path}", headers: headers).parsed_response
    end

    def delete(path)
      HTTParty.delete("#{BASE_URL}#{path}", headers: headers).parsed_response
    end

    def post(path, body)
      HTTParty.post(path, body: JSON.dump(body), headers: headers)
        .parsed_response
    end

    def headers
      return {} if @api_key.nil?
      { 'X-Starfighter-Authorization' => @api_key }
    end
  end
end