require 'spec_helper'

describe Merchant do

	it "has a valid factory" do
		FactoryGirl.create(:merchant).should be_valid
	end

  it "has a valid factory with users" do
    FactoryGirl.create(:merchant_with_users).should be_valid
  end

  before  do
    @merchant = FactoryGirl.create(:merchant_with_users)
  end

  subject { @merchant }

  it { should respond_to(:name) }
  it { should respond_to(:user_ids) }

  it { should be_valid }

  describe "when name is not present" do
    before { @merchant.name = nil }
    it { should_not be_valid }
  end

  describe "when name is blank" do
    before { @merchant.name = " " }
    it { should_not be_valid }
  end

  describe "enforce uniqueness" do
    it "should not add a duplicate" do
      merchant_with_same_name = @merchant.dup
      merchant_with_same_name.should_not be_valid
    end
  end

  describe "promotion associations" do

    before { @merchant.save }
    let!(:first_promotion) do 
      FactoryGirl.create(:promotion, merchant: @merchant)
    end

    it "should destroy associated promotions" do
      promotions = @merchant.promotions.dup
      @merchant.destroy
      promotions.should_not be_empty
      promotions.each do |promotion|
        Promotion.find_by_id(promotion.id).should be_nil
      end
    end
  end
end