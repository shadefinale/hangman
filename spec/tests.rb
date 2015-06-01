# tests.rb is a simple testing suite used to help prevent regressions in the codebase

require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe "Main" do 
  def app
  	@app ||= Sinatra::Application
  end

  # Before tests are run, define a dummy game whose word is 'test'
  before(:all) do
    ng = Game.new
    ng.attributes = {:word => 'test'}
    ng.save
  end

  # After each test, we reset the guesses to 5 and the guessed letters to "". (The defaults)
  after(:each) do
    Game.get(1).update(:guesses => 5)
    Game.get(1).update(:letters => "")
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

    # Make sure that we can't access a game that doesn't exist
    it "should redirect to /game/new/ if game does not exist" do
      get '/game/920482'
      follow_redirect!
      expect(last_request.url).to include("/game/new")
    end

    # Make sure that we even get a game returned.
    it "should have a game 1 with the word test in it" do
      get '/game/1'
      expect(last_response.body).to include("Guess a letter!")
    end

    # Make sure that our dummy game has four underscores due to 'test' being four letters.
    it "should have game 1 show '_ _ _ _'" do
      get 'game/1'
      expect(last_response.body).to include("_ _ _ _")
    end

    # Correct guesses should fill in the proper blanks.
    it "should accept T as a correct guess to game 1" do
      get '/game/1'
      post '/game/1', {:guess => "T"}
      follow_redirect!
      expect(last_response.body).to include("T _ _ T")
    end

    # A wrong guess should show up in the wrong letters category, and also subtract a guess.
    it "should show that W is an incorrect guess to game 1." do
      get '/game/1'
      post '/game/1', {:guess => "W"}
      follow_redirect!
      expect(last_response.body).to include("_ _ _ _")
      expect(last_response.body).to include("Wrong Letters: W")
      expect(Game.get(1).guesses).to eq(4)
    end
  end
end