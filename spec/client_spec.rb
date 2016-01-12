require 'spec_helper'
require 'set'

describe Stockfighter::Client do
  subject { Stockfighter::Client.new(ENV['STOCKFIGHTER_API_KEY']) }
  let (:order_details) do
    {
      'account' => 'EXB123456',
      'venue' => 'TESTEX',
      'stock' => 'FOOBAR',
      'qty' => 1,
      'direction' => 'buy',
      'orderType' => 'market'
    }
  end

  describe '#heartbeat' do
    it 'returns hash with OK true' do
      expect(subject.heartbeat).to eq('ok' => true, 'error' => '')
    end

    it 'respects venue if specified' do
      expect(subject.heartbeat('TESTEX'))
        .to eq('ok' => true, 'venue' => 'TESTEX')
    end
  end

  describe '#stocks' do
    it 'returns stocks for venue' do
      expect(subject.stocks('TESTEX'))
        .to eq(
          'ok' => true,
          'symbols' => [{
            'name' => 'Foreign Owned Occluded Bridge Architecture Resources',
            'symbol' => 'FOOBAR'
          }])
    end
  end

  describe '#orderbook' do
    it 'returns orderbook for venue' do
      expect(subject.orderbook('TESTEX', 'FOOBAR').keys)
        .to eq(%w(ok venue symbol ts bids asks))
    end
  end

  describe '#new_order' do
    it 'creates an order' do
      result = subject.new_order('TESTEX', 'FOOBAR', order_details)
      expect(result.keys)
        .to eq(%w(ok symbol venue direction originalQty qty price
                  orderType id account ts fills totalFilled open))
    end
  end

  describe '#quote' do
    it 'returns quote for stock' do
      result = subject.quote('TESTEX', 'FOOBAR')
      is_subset = Set['ok', 'symbol', 'venue', 'bidSize', 'askSize',
                      'bidDepth', 'askDepth', 'last', 'lastSize',
                      'lastTrade', 'quoteTime'].subset? result.keys.to_set
      expect(is_subset).to eq(true)
    end
  end

  describe '#order_status' do
    it 'returns status of an order' do
      order = subject.new_order('TESTEX', 'FOOBAR', order_details)
      status = subject.order_status('TESTEX', 'FOOBAR', order['id'])
      expect(status.keys)
        .to eq(%w(ok symbol venue direction originalQty qty price orderType
                  id account ts fills totalFilled open))
    end
  end

  describe '#cancel_order' do
    it 'cancels an order' do
      order = subject.new_order('TESTEX', 'FOOBAR', order_details)
      order = subject.cancel_order('TESTEX', 'FOOBAR', order['id'])
      expect(order['open']).to eq(false)
    end
  end

  describe 'all_orders' do
    it 'gets all orders for an account' do
      orders = subject.all_orders('TESTEX', 'EXB123456')
      expect(orders.keys).to eq(%w(ok venue orders))
    end

    it 'allows stock to be passed' do
      orders = subject.all_orders('TESTEX', 'EXB123456', 'FOOBAR')
      expect(orders.keys).to eq(%w(ok venue orders))
    end
  end
end
