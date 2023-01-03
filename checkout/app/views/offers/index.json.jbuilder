json.array! @offers do |offer|
    json.partial! 'offer', offer: offer
  end
