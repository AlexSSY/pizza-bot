require 'telegram/bot'
require 'dotenv/load'
require 'nokogiri'
require 'open-uri'
require 'debug'


Telegram::Bot::Client.run ENV["BOT_TOKEN"] do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
      max_page = 25
      page = rand max_page
      pizza_url = "https://www.russianfood.com/search/simple/index.php?sskw_title=%EF%E8%F6%F6%E0&sskw_iplus=&sskw_iminus=&sskw_iminus=&ssfolder=5&sort=abc&page=#{page}#rcp_list"
      document = Nokogiri::HTML.parse(URI.open(pizza_url))
      dom_pizza_elements = document.css('.in_seen')
      dom_selected_receipt = dom_pizza_elements.to_ary.sample
      receipt_url = "https://www.russianfood.com#{dom_selected_receipt.css("a")[0][:href]}"
      # bot.api.send_message(chat_id: message.chat.id, text: receipt_url)
      document = Nokogiri::HTML.parse(URI.open(receipt_url))
      title = document.css("h1.title").text.strip
      how = document.css("#how").text
      bot.api.send_message(chat_id: message.chat.id, text: "<b>#{title}</b>\n\n#{how}", parse_mode: 'html')
      dom_ingredients = document.xpath('//tr[contains(@class, "ingr_tr_")]')
      bot.api.send_message(chat_id: message.chat.id, text: "<b>Ингредиенты:</b>\n\n#{dom_ingredients.map { |i| i.text.strip }.join("\n")}", parse_mode: 'html')
    end
  end
end