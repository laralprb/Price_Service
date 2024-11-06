require 'date'

class PriceService
  attr_reader :product, :user

  def initialize(product:, user:)
    @product = product
    @user = user
  end

  def call
    final_price
  end

  private

  def base_price
    product[:base_price]
  end

  def final_price
    price = base_price + tax_amount
    price -= discount_food_or_beverages if eligible_for_food_or_beverages_discount?
    price -= discount_birthday if eligible_for_birthday_discount?
    price
  end

  def discount_food_or_beverages
    price = base_price + tax_amount
    price * 0.05
  end

  def discount_birthday
    price = base_price + tax_amount
    price * 0.10
  end

  def eligible_for_food_or_beverages_discount?
    product[:category] == 'food' || product[:category] == 'beverages'
  end

  def eligible_for_birthday_discount?
    user[:birthday_month] == Date.today.month
  end

  def tax_amount
    base_price * (product[:tax_percentage] / 100.0)
  end
end
