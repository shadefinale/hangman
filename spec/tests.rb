require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe "Main" do 
  def app
  	@app ||= Sinatra::Application
  end

  before(:all) do
    ng = Game.new
    ng.attributes = {:word => 'test'}
    ng.save
  end

  describe "Routes" do
    it "should redirect / to /game/new" do
      get '/'
      follow_redirect!
      expect(last_response.body).to include("Select a difficulty and let's begin!")
    end

    it "should show new game page" do
      get '/game/new'
      expect(last_response.body).to include("Select a difficulty and let's begin!")
    end

    it "should start a new game if post to /game/new" do
      post '/game/new', {:difficulty => 4}
      follow_redirect!
      expect(last_request.url).to include("/game/2")
      expect(last_response.body).to include("Guess a letter!")
    end

    it "should redirect to /game/new/ if game does not exist" do
      get '/game/920482'
      follow_redirect!
      expect(last_request.url).to include("/game/new")
    end

    it "should have a game 1 with the word test in it" do
      get '/game/1'
      expect(last_response.body).to include("Guess a letter!")
    end
  end
end