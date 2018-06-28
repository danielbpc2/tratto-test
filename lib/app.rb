require_relative 'wallet_central'

wallet_central = WalletCentral.new

turned_on = true
  puts `clear`

while turned_on == true
  puts "-----------------"
  puts "Welcome to the Tratto test bank! what do you want to do?"
  puts "1- Check some account?"
  puts "2- Check the name of the users?"
  puts "3- Transfer money between accounts?"
  puts "4- Exit"
  user_input = gets.chomp.to_s

  case user_input
  when "1"
    puts `clear`
    puts "What is the client name?"
    answer = gets.chomp.downcase
    puts `clear`
    puts "Your result:"
    puts wallet_central.output(answer)
  when "2"
    puts `clear`
    wallet_central.show_all_names
  when "3"
    puts `clear`
    puts "Who will transfer? (first name)"
    transferee = gets.chomp.downcase
    puts "Who will receive? (first name)"
    receiver = gets.chomp.downcase
    puts "the currency that will be transfered? (USD, BRL or EUR)"
    currency = gets.chomp.upcase
    while currency.match(/^(brl|usd|eur)$/i).nil?
      puts "not a valid currency"
      currency = gets.chomp.upcase
    end
    puts "The amount to be transfered?"
    amount = gets.chomp
    while amount.match(/^(\d+).?(\d{2})?$/).nil?
    puts "insert a number."
    amount = gets.chomp
    end
    wallet_central.transfer(transferee, receiver, currency, amount)
  when "4"
    turned_on = false
  else
    puts "Not a valid input"
  end
end
