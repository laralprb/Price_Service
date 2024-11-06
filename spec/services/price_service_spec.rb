require 'rspec'
require 'timecop'

require_relative '../../app/services/price_service'

RSpec.describe PriceService do
  subject(:call) { PriceService.new(product: product, user: user).call }

  let(:product) { { id: 1, base_price: 100, tax_percentage: 0 } }
  let(:user) { { id: 1, birthday_month: 5 } }

  it 'calculates the total price' do
    PriceService.new(product: product, user: user)
    expect(call).to eq(100.0)
  end

  context 'when product has tax' do
    let(:product) { { id: 1, base_price: 100, tax_percentage: 10 } }

    it 'ignores the taxes' do
      expect(call).to eq(110.0)
    end
  end

  context 'when the product is in a discountable category' do
    let(:tax_percentage) { 10 }

    context 'and the category is "food"' do
      let(:product) { { id: 1, base_price: 100, tax_percentage: tax_percentage, category: 'food' } }

      it 'applies a 5% discount for "food" category' do
        expect(call).to eq(104.5)
      end
    end

    context 'and the category is "beverages"' do
      let(:product) { { id: 1, base_price: 100, tax_percentage: tax_percentage, category: 'beverages' } }

      it 'applies a 5% discount for "beverages" category' do
        expect(call).to eq(104.5)
      end
    end

    context 'and the category is "electronics"' do
      let(:product) { { id: 1, base_price: 100, tax_percentage: tax_percentage, category: 'electronics' } }

      it 'does not apply a discount for this category' do
        expect(call).to eq(110.0)
      end
    end
  end

  context 'when the user is eligible for a birthday discount' do
    let(:tax_percentage) { 10 }
    let(:product) { { id: 1, base_price: 100, tax_percentage: tax_percentage } }

    context 'and the users birthday is this month' do
      before do
        Timecop.freeze(Time.local(1985, 5, 1))
      end

      let(:user) { { id: 1, birthday_month: 5 } }

      it 'applies a 10% discount for birthday month' do
        expect(call).to eq(99.0)
      end
    end

    context 'and the users birthday is not this month' do
      let(:user) { { id: 1, birthday_month: 6 } }

      it 'does not apply a birthday discount' do
        expect(call).to eq(110.0)
      end
    end
  end

  context 'when both birthday and category discounts apply' do
    let(:tax_percentage) { 10 }
    let(:product) { { id: 1, base_price: 100, tax_percentage: tax_percentage, category: 'food' } }

    before do
      Timecop.freeze(Time.local(2010, 5, 1))
    end

    let(:user) { { id: 1, birthday_month: 5 } }

    #The value of each discount is calculated on the value of the product with tax
    it 'applies both a 5% category discount and a 10% birthday discount' do 
      expect(call).to eq(93.5)
    end
  end
end
