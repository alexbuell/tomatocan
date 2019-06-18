require 'test_helper'
require 'capybara-screenshot/minitest'
require 'capybara/apparition'
require 'stripe'
#require 'selenium-webdriver'
#options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless']) don't use this
#@driver = Selenium::WebDriver.for :firefox
#@driver.navigate.to 'http://localhost:3000/'
class UsersTest < ActionDispatch::IntegrationTest

  setup do
    @purchases = purchases(:one)
    @purchaser = users(:two) #user 2 is the customer 
    @seller = users(:one)
  end

    include Capybara::DSL
    include Capybara::Minitest::Assertions
    Capybara::Screenshot.autosave_on_failure = false
    setup do
    visit ('http://localhost:3000/')

  def signUpPurchaser()
      visit ('http://localhost:3000/')
      click_on('Sign Up', match: :first)
      fill_in(id:'user_name', with: 'purchaser')
      fill_in(id:'user_email', with: 'pur@gmail.com')
      fill_in(id:'user_permalink', with:'purchaser')
      fill_in(id:'user_password', with: 'password', :match => :prefer_exact)
      fill_in(id:'user_password_confirmation', with:'password')
      click_on(class: 'form-control btn-primary')
      click_on('Sign out')
  end
  def signInPurchaser()
      visit ('http://localhost:3000/')
      click_on('Sign In', match: :first)
      fill_in(id:'user_email', with: 'pur@gmail.com')
      fill_in(id:'user_password', with: 'password')
      click_on(class: 'form-control btn-primary')
  end

  def signUpFixture()
    visit ('http://localhost:3000/')
    click_on('Sign Up', match: :first)
    fill_in(id:'user_name', with: @purchaser.name)
    fill_in(id:'user_email', with: @purchaser.email)
    fill_in(id:'user_permalink', with: @purchaser.permalink)
    fill_in(id:'user_password', with: 'password' , :match => :prefer_exact)
    fill_in(id:'user_password_confirmation', with:'password')
    click_on(class: 'form-control btn-primary')
    #click_on('Sign out')
end
def signInFixture()
    visit ('http://localhost:3000/')
    click_on('Sign In', match: :first)
    fill_in(id:'user_email', with: @purchaser.email)
    fill_in(id:'user_password', with: 'password')
    click_on(class: 'form-control btn-primary')
end
        
        @time=Time.now
    end

    test 'Should_buy_from_user' do
        signUpPurchaser() #signing up a new user

        cardToken = Stripe::Token.create({  #create Stripe account for new user
          card: {
            number: "4242424242424242",
            exp_month: 1,
            exp_year: 2023,
            cvc: "123"
          }
        })
        customer = Stripe::Customer.create(
                                          :source => cardToken,
                                          :description => 'purchaser',
                                          :email => 'pur@gmail.com'
                                          )
        customer.save

        signInPurchaser() #sign in purchaser  

        click_on('Discover Talk Show Hosts')
        click_link(@seller.name)
        puts(@seller.name + " seller name")
        click_on('Buy for $1.50!')
        puts ("clicked")
        fill_in(id:'card_number', with:'4242 4242 4242 4242')
        fill_in(id:'card_code', with:'123')
        select("1 - January", from: 'card_month')
        select("2023", from: 'card_year')
        click_on('Purchase')

        assert_text 'Your have successfully completed the purchase!'
    end

    test 'signing up a fixture' do
      puts @purchaser.encrypted_password
      signUpFixture()
      assert_text('Email has already been taken')
    end

  #   test 'Testing purchase created by a fixture' do
        
  #     cardToken = Stripe::Token.create({
  #       card: {
  #         number: "4242424242424242",
  #         exp_month: 8,
  #         exp_year: 2060,
  #         cvc: "123"
  #       }
  #     })
  #     customer = Stripe::Customer.create( 
  #                                       :source => cardToken,
  #                                       :description => @purchaser.name,
  #                                       :email => @purchaser.email
  #                                       )
  #     customer.save
  #     @purchaser.update_column(:stripe_customer_token, customer.id)
  #     puts (@purchaser.stripe_customer_token)
      
  #     signInFixture()

  #     assert_text 'Signed in successfully.'

  #     # puts("signed in")
  #     # click_on('Discover Talk Show Hosts')
  #     # click_link(@seller.name)
  #     # puts(@seller.name + " seller name")
  #     # click_on('Buy for $1.50')
  #     # puts ("clicked")
  #     # fill_in(id:'card_number', with:'4242424242424242')
  #     # click_on('Purchase')

  #     # assert_text 'Your have successfully completed the purchase!'
  # end

  end