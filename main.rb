require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

# Our class that will be used by the ORM to keep track of different play sessions.
class Game
  include DataMapper::Resource
  property :id, Serial
  property :word, String, :required => true
  property :guesses, Integer, :default => 5
  property :letters, String, :default => ""
end

DataMapper.finalize

# Takes the large amount of words from enable.txt and puts them into an array.
def generate_words
  ret = []

  File.open('enable.txt').each do |line|
    new_line = line
    # We don't care for the new line character in the game of hangman.
    new_line = new_line.delete("\n")
    ret << new_line
  end

  return ret
end

WORDS = generate_words

# Since my domain doesn't really have any other use, for now I'll just redirect it to the game page.
get '/' do
  redirect to('/game/new')
end

get '/game/new' do
  erb :newgame
end

post '/game/new' do
  difficulty = params['difficulty']
  new_word = get_word(difficulty.to_i)
  new_game = Game.create(:word => new_word)
  redirect to("/game/#{new_game.id}")
end

get '/game/:id' do
  @game = Game.get(params['id'])
  if @game
    # We take the guessed letters and the word and fill in 
    # the appropriate blanks.
    display = create_display(@game.word, @game.letters)
    erb :game, :locals => {:id => @game.id, :display => display,
     :guesses => @game.guesses, 
     :letters => get_letters(@game)}
  else
    # If the game doesn't exist, we bring the player
    # to the new game page.
    redirect to('/game/new')
  end
end

post '/game/:id' do
  @game = Game.get(params['id'])
  if @game
    # Get the guessed letter.
    guess = params['guess'].to_s.upcase
    # If they guess wrong, subrtact one of their remaining guesses.
    if !@game.word.include?(guess.downcase)
      updated_guesses = @game.guesses - 1
      @game.update(:guesses => updated_guesses)

      # If they have guessed wrong too many times, delete the game and
      # return to the game over screen.
      if updated_guesses == 0
        the_word = @game.word
        @game.destroy
        return erb :gameover, :locals => {:word => the_word}
      end
    end
    @game.update(:letters => (@game.letters + guess))
    # If letters has all of the letters in words we've won!
    if (@game.word.upcase.split("") - @game.letters.upcase.split("")).empty?
      the_word = @game.word
      @game.destroy
      return erb :gamewon, :locals => {:word => the_word}
    end
  else
    # If they somehow try to POST to a non-existent game
    # just redirect them to the new game page.
    redirect to("/game/new")
  end

  # Return to the game page.
  redirect to("/game/#{@game.id}")
end

# Takes the words and letters, and fills in any blanks where the player has guessed the
# corresponding letter.
def create_display(word, letters)
  print word.upcase.split("")
  word.upcase.split("").map{|letter| letters.include?(letter) ? letter : "_"}.join(" ")
end

# Returns a random word of given length.
def get_word(difficulty)
  WORDS.select{|word| word.length == difficulty}.sample
end

# We only want to show missed guesses. Correct guesses fill in blanks.
def get_letters(game)
  game.letters.split("").reject{|letter| game.word.upcase.include?(letter)}.join(" ")
end