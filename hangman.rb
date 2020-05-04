require 'yaml'
require './text_content.rb'
include TextContent

class Computer
	attr_accessor :lives, :correct_letters, :incorrect_letters, :secret_word, :secret_letters

	def initialize
		@lives = 5
		@correct_letters = []
		@incorrect_letters = []
		@secret_word = word_from_dict.chomp
		@secret_letters = self.secret_word.split("")
	end

	def make_guess
		puts make_guess_text
		guess = gets.chomp.downcase

		while guess.length != 1 || !guess.match(/[a-z]/)
			if guess == 'save' || guess == 'load'
				return guess
			end
			puts make_guess_text
			guess = gets.chomp.downcase
		end

		return guess
	end

	def word_from_dict
		file = File.open("dictionary.txt", "r")
		words = file.readlines
		word = words.sample 
		while word.length < 5 || word.length > 12
			word = words.sample
		end
		# puts word
		file.close
		return word.downcase
	end

	def display
		return "_ " * secret_word.length if correct_letters.empty?
		regex = /[^#{correct_letters.join("")}]/
		return secret_word.gsub(regex, "_").split("").join(" ") + "   " + "Incorrect guesses: #{incorrect_letters.join(", ")}"
	end

	def process_guess game
		guess = self.make_guess
		if guess == "save"
			game.save_game
		elsif guess == "load"
			game.load_game
		end
		return guess
	end

	def play_round game
		guess = process_guess(game)
		if (guess == "save" || guess == "load")
			return 1
		end

		while (correct_letters+incorrect_letters).include? guess
			puts redundant_guess_text(guess)
			guess = self.make_guess
		end

		if secret_letters.include? guess
			correct_letters.push(guess)
		else
			incorrect_letters.push(guess)
			self.lives -= 1
		end
	end
end

class Game
	attr_accessor :gamestate, :in_play
	# https://stackoverflow.com/questions/31307256/ruby-serializing-game-classes
	def initialize 
		@gamestate = Computer.new
		@in_play = true
		play_game
	end

	def serialize 
		YAML::dump(self)
	end

	def deserialize yaml_string
		YAML.load(yaml_string)
	end

	def start_game
		puts game_intro_text

		choice = gets.chomp
		begin
			choice = gets.chomp
			retries ||= 0
			if choice == "1"
				new_game
			elsif choice == "2"
				load_game
			else
				raise
			end
		rescue
			puts bad_choice_text
			retry if (retries += 1) < 3
			puts "Starting new game\n"
			return 1
		end
	end

	def new_game
		self.gamestate = Computer.new
	end

	def play_again
		puts play_again_text
		answer = gets.chomp
		while !["y", "n"].include? answer
			puts play_again_text
			answer = gets.chomp
		end

		if answer == "y"
			self.in_play = true
		else 
			self.in_play = false
		end
	end

	def generate_filename
		dirname = "save_files"
		Dir.mkdir(dirname) unless File.exists? (dirname)

		save_files = Dir["#{dirname}/**/*"]
		id_nums = []
		save_files.each {|file| id_nums.push(file[/(\d+)(?!.*\d)/].to_i)}
		id = id_nums.max + 1
		return "#{dirname}/save_game_#{id}.yml"
	end

	def save_game
		filename = generate_filename
		yaml = serialize
		file = File.open(filename, "w")
		file.puts yaml
		file.close
	end

	def load_game
		current_save_files = Dir["save_files/*"]
		puts saved_files_text(current_save_files)
		choice = ""

		while !current_save_files.include? choice
			choice = gets.chomp
		end

		file = File.open(choice, "r")
		dat = file.read
		self.gamestate = deserialize(dat).gamestate
	end

	def game_loop 
		while gamestate.lives > 0
			puts
			puts gamestate.display
			puts
			gamestate.play_round self
			if gamestate.secret_letters.uniq.sort == gamestate.correct_letters.sort
				puts win_text
				play_again
				return 1
			end
		end

		
		puts lose_text
		play_again

	end

	def play_game
		while self.in_play
			start_game
			game_loop
		end
	end

end
