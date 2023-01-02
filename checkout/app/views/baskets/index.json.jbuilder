json.array! @baskets do |basket|
    json.partial! 'basket', basket: basket
  end
