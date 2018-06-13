require_relative 'wallet'

class WalletCentral

  def initialize
    Wallet.load
  end

  def transfer(wallet1, wallet2, currency, amount_transfered)

  end

  def output(client)
    # wallets that will be written in json format
    output_wallet = []

    WALLETS.each_with_index do |wallet, index|
     # separate the wallets with the same client as the one in the current loop
      same_name = WALLETS.select { |x| wallet.client == x.client }
      # save the client name in the output and create a hash wallets
      output_wallet << {
                            name: "#{wallet.client}",
                            "wallets": {}
                          }
      # grab the wallets that has the same client and store their wallets in the empty hash
      same_name.each do |x|
        output_wallet[index][:wallets].store("#{x.currency}", "#{x.amount}")
      end
    end
    # remove duplicates in the output
    output_wallet.uniq!
    # return asked client
    output_wallet.select! {|c| c[:name] == client}

    unless output_wallet.length == 0
      return output_wallet
    else
      return "No client with such name"
    end
  end

private

  def all_output
    # create a json filepath
    filepath = 'resources/wallets_output.json'
    # wallets that will be written in json format
    output_wallets = []

    WALLETS.each_with_index do |wallet, index|
     # separate the wallets with the same client as the one in the current loop
      same_name = WALLETS.select { |x| wallet.client == x.client }
      # save the client name in the output and create a hash wallets
      output_wallets << {
                            name: "#{wallet.client}",
                            "wallets": {}
                          }
      # grab the wallets that has the same client and store their wallets in the empty hash
      same_name.each do |x|
        output_wallets[index][:wallets].store("#{x.currency}", "#{x.amount}")
      end
    end
    # remove duplicates in the output
    output_wallets.uniq!
    # generate json
    File.open(filepath, 'wb') do |file|
      file.write(JSON.generate(output_wallets))
    end
  end

end

a = WalletCentral.new
puts a.output('jon')
