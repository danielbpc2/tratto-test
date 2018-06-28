require 'csv'
require 'json'

  # all wallets array
WALLETS = []

class Wallet
  attr_reader :client, :currency, :amount
  attr_writer :amount
  def initialize(client, currency, amount)
    @client = client
    @currency = currency
    @amount = amount
    WALLETS << self
  end

  private

  # Method to load CSV wallets.
  def self.load
    #
    filepath = 'resources/wallets.csv'
    #
    csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }
    CSV.foreach(filepath, csv_options) do |row|
    Wallet.new(row['Client'], row['Currency'], row['Amount'])
    end
  end

  # Method to save new csv
  def self.save
    filepath    = 'resources/wallets.csv'
    csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
    CSV.open(filepath, 'wb', csv_options) do |csv|
      csv << ['Client', 'Currency', 'Amount']
      WALLETS.each do |wallet|
        csv << [wallet.client, wallet.currency, wallet.amount]
      end
    end
  end
end

