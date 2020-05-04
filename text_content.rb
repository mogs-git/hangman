module TextContent
	def template
		<<~HEREDOC

			text

		HEREDOC
	end

	def game_intro_text
		<<~HEREDOC

			Welcome to hangman. Type letters to try and guess the secret word!

			Would you like to:
			[1] start a new game...
			[2] load a saved game...

		HEREDOC
	end

	def bad_choice_text
		<<~HEREDOC

			Please choose a valid option

		HEREDOC
	end

	def make_guess_text
		<<~HEREDOC
		
			Guess a letter. Or type 'save' or 'load'.
		HEREDOC
	end

	def redundant_guess_text (guess)
		<<~HEREDOC

			You already guessed #{guess}. Make another guess...
		HEREDOC
	end

	def play_again_text
		<<~HEREDOC

			Would you like to play again? [y/n]
		HEREDOC
	end

	def saved_files_text (current_save_files)
		<<~HEREDOC

			Current save files: 

			#{current_save_files.join(" ")}


		HEREDOC
	end

	def win_text
		<<~HEREDOC

			Congratulations!!!

			You guessed the word!

		HEREDOC
	end

	def lose_text
		<<~HEREDOC
			Player loses, the word was #{gamestate.secret_word}
		HEREDOC
	end
end