# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :baskets, only: %i[create index show]
  resources :line_items, only: %i[create]
  resources :offers, only: %i[create index show]
  resources :products, only: %i[create index show]
end
