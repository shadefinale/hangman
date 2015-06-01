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

  # After each test, we reset the dummy game or regenerate it if it's been deleted.
  after(:each) do
    if Game.get(1)
      Game.get(1).update(:guesses => 5)
      Game.get(1).update(:letters => "")
    else
      ng = Game.new
      ng.attributes = {:id => 1, :word => 'test'}
      ng.save
    end
  end

  describe "Routes" do
    it "should redirect / to /game/new" do
      get '/'
      follow_redirect!
      expect(last_request.url).to include("/game/new")
    end

    it "should show new game page" do
      get '/game/new'
      expect(last_request.url).to include("/game/new")
    end

    it "should start a new game if post to /game/new" do
      post '/game/new', {:difficulty => 4}
      follow_redirect!
      expect(last_request.url).to include("/game/2")
    end

    it "should redirect to /game/new/ if game does not exist" do
      get '/game/920482'
      follow_redirect!
      expect(last_request.url).to include("/game/new")
    end

    it "should have game 1 show correct amount of underscores" do
      get 'game/1'
      expect(last_response.body).to include("_ _ _ _")
    end

    it "should accept T as a correct guess to game 1" do
      get '/game/1'
      post '/game/1', {:guess => "T"}
      follow_redirect!
      expect(last_response.body).to include("T _ _ T")
    end

    it "should show that W is an incorrect guess to game 1." do
      get '/game/1'
      post '/game/1', {:guess => "W"}
      follow_redirect!
      expect(last_response.body).to include("_ _ _ _")
      expect(last_response.body).to include("Wrong Letters: W")
      expect(Game.get(1).guesses).to eq(4)
    end

    it "should game over when too many wrong inputs guessed" do
      get '/game/1'
      post '/game/1', {:guess => "A"}
      follow_redirect!
      post '/game/1', {:guess => "B"}
      follow_redirect!
      post '/game/1', {:guess => "C"}
      follow_redirect!
      post '/game/1', {:guess => "D"}
      follow_redirect!
      post '/game/1', {:guess => "F"}
      expect(last_response.body).to include("out of guesses")
    end

    it "should show a congratulation screen when guessed correctly" do
      get '/game/1'
      post '/game/1', {:guess => "T"}
      follow_redirect!
      post '/game/1', {:guess => "E"}
      follow_redirect!
      post '/game/1', {:guess => "S"}
      expect(last_response.body).to include("did it!")
    end
  end
end