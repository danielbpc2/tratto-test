require_relative 'wallet'
require 'pry'

class WalletCentral

  def initialize
    Wallet.load
  end

  def conversion(currency, amount)

  end

  def transfer(wallet1, wallet2, currency, amount_transfered)
    transferee_wallets = WALLETS.select { |x| wallet1 == x.client}
    receiver_wallets = WALLETS.select { |x| wallet2 == x.client}
    # TODO
    if transferee_wallets.length == 0 || receiver_wallets.length == 0
      return puts "No clients with such name"
    else
    end
    # 1 check if both have the wallet currency, if they do, make transfer
    transferee_wallet = transferee_wallets.select { |x| currency == x.currency}
    receiver_wallet = receiver_wallets.select { |x| currency == x.currency}

    # 2 in the case of the transferee don't have this currency, ask to user which one to use to transfer
    if transferee_wallet.empty?
      puts "there is no wallet from #{wallet1.capitalize} with that currency."
      puts "Which wallet do you want to use from #{wallet1.capitalize} to make the transfer"
      transferee_wallets.each_with_index { |y, index| puts "#{index + 1} #{y.currency} - $#{y.amount}" }
      answer = gets.chomp
      while answer.to_i > transferee_wallets.length || answer.to_i <= 0
        puts "invalid input"
      answer = gets.chomp
      end
      transferee_wallet = [transferee_wallets[answer.to_i - 1]]
    end

    # if the receiver doesn't have a wallet in this currency it will use the dollars one
    if receiver_wallet.empty?
      receiver_wallet = receiver_wallets.select { |x| x.currency == "USD" }
    end

    # if the receiver doesn't have a dollar wallet use the one with the highest amount,
    if receiver_wallet.empty?
      receiver_wallet = receiver_wallets.sort { |x,y| y.amount.to_f <=> x.amount.to_f }
      receiver_wallet = [receiver_wallet[0]]
    end

    # 3 Make transfer

    # same currency on both wallets and same as transfer
    if transferee_wallet[0].currency == currency && receiver_wallet[0].currency == currency

      if transferee_wallet[0].amount.to_f >= amount_transfered.to_f
        transferee_wallet[0].amount = (transferee_wallet[0].amount.to_f - amount_transfered.to_f).round(2)
        receiver_wallet[0].amount = (receiver_wallet[0].amount.to_f + amount_transfered.to_f).round(2)

        else
          puts "Insufficient funds to make this transfer"
      end

      # transferee doesn't have a wallet in this currency
    elsif transferee_wallet[0].currency != currency && receiver_wallet[0].currency == currency
      # make it usd
      transferee_amount_converted = convert_anything_to_usd(transferee_wallet[0].currency, transferee_wallet[0].amount)
      # make it the transfer currency
      transferee_amount_converted = convert_usd_to(currency, transferee_amount_converted)
      # same with the amount to transfer
      amount_transfered_converted = convert_anything_to_usd(currency, amount_transfered)
      amount_transfered_converted = convert_usd_to(transferee_wallet[0].currency, amount_transfered_converted)
      if transferee_amount_converted >= amount_transfered.to_f

        transferee_wallet[0].amount = (transferee_wallet[0].amount.to_f - amount_transfered_converted.to_f).round(2)
        receiver_wallet[0].amount = (receiver_wallet[0].amount.to_f + amount_transfered.to_f).round(2)

        else
          puts "Insufficient funds to make this transfer"
      end

      # receiver doesn't have a wallet in this currecy
    elsif transferee_wallet[0].currency == currency && receiver_wallet[0].currency != currency
      # make it usd
      transferee_amount_converted = convert_anything_to_usd(transferee_wallet[0].currency, transferee_wallet[0].amount)
      # make it the transfer currency
      transferee_amount_converted = convert_usd_to(currency, transferee_amount_converted)
      # same with the amount to transfer
      amount_transfered_converted = convert_anything_to_usd(currency, amount_transfered)
      amount_transfered_converted = convert_usd_to(receiver_wallet[0].currency, amount_transfered_converted)
      if transferee_wallet[0].amount.to_f >= amount_transfered.to_f

        transferee_wallet[0].amount = (transferee_wallet[0].amount.to_f - amount_transfered.to_f).round(2)
        receiver_wallet[0].amount = (receiver_wallet[0].amount.to_f + amount_transfered_converted.to_f).round(2)

        else
          puts "Insufficient funds to make this transfer"
      end

      # both doesn't have the transfer currency
      elsif transferee_wallet[0].currency != currency && receiver_wallet[0].currency != currency
      # make it usd
      transferee_amount_converted = convert_anything_to_usd(transferee_wallet[0].currency, transferee_wallet[0].amount)
      # make it the transfer currency
      transferee_amount_converted = convert_usd_to(currency, transferee_amount_converted)
      # same with the amount to transfer
      amount_transfered_converted = convert_anything_to_usd(currency, amount_transfered)
      amount_transfered_converted = convert_usd_to(transferee_wallet[0].currency, amount_transfered_converted)

      # convert the amount to the receiver as well
      amount_transfered2_converted = convert_anything_to_usd(currency, amount_transfered)
      amount_transfered2_converted = convert_usd_to(receiver_wallet[0].currency, amount_transfered_converted)

      if transferee_amount_converted >= amount_transfered.to_f
        transferee_wallet[0].amount = (transferee_wallet[0].amount.to_f - amount_transfered_converted.to_f).round(2)
        receiver_wallet[0].amount = (receiver_wallet[0].amount.to_f + amount_transfered2_converted.to_f).round(2)
        else
          puts "Insufficient funds to make this transfer"
      end
    end

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

  def convert_usd_to(currency, amount)
    case currency
    when "BRL"
      return (amount.to_f * 3.16).round(2)
    when "EUR"
      return (amount.to_f * 0.80).round(2)
    when "USD"
      return amount.to_f
    end
  end

  def convert_anything_to_usd(currency, amount)
    case currency
    when "BRL"
      return (amount.to_f / 3.16).round(2)
    when "EUR"
      return (amount.to_f / 0.80).round(2)
    when "USD"
      return (amount.to_f)
    end
  end

end
# c = WalletCentral.new
# a = WALLETS.select { |x| 'jon' == x.client }
# b = WALLETS.select { |x| 'aray' == x.client }
# # # puts a
# # a.keep_if { |x| 'USD' == x.currency}
# # puts "------------"
# # puts c.output("jon")
# # puts "------------"
# # puts c.output("littlefinger")
# # puts "------------"
# # # puts a.client

# # puts "------------"
# # c.transfer('jon','littlefinger','BRL', "211")
# # puts "------------"
# # puts c.output("jon")
# # puts "------------"
# # puts c.output("littlefinger")
# puts "------------"
# puts "OTHERWAY"
# puts c.output("tyrion")
# puts "------------"
# puts c.output("daario")
# puts "------------"
# puts a.client

# puts "------------"
# c.transfer('tyrion','daario','BRL', "3.16")
# puts "------------"
# puts c.output("tyrion")
# puts "------------"
# puts c.output("daario")
# puts "------------"
# # puts a.amount
# # a.amount = a.amount.to_i
# # a.amount += 100
# # puts a.amount
# # WALLETS.sort { |x,y| y.amount.to_f <=> x.amount.to_f }
# # receiver_wallet = WALLETS.sort { |x,y| y.amount.to_f <=> x.amount.to_f }
# # puts receiver_wallet
# # puts c.convert_usd_to("BRL", 150)
# # puts c.convert_anything_to_usd("BRL", 474)
