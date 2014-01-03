require_relative 'creature_classes'
require_relative 'missions'
require_relative 'loading_saving_characters'

require 'yaml'

	$number_of_elements = 4
	$characters_file = "characters.txt"

class LoadingSavingCharacters

	def self.findCharacterIndexInFile(name, obj_or_index)
		character_info_arr = nil
		 
		character_info_arr = loadAllCharactersFromFile() # load all character information

	  #if $characters_file.size != 0
		counter = 0
		character_info_arr.each do |character|			# for each Person object saved in YAML file
			if character.name == name
				if obj_or_index == "obj"
					return character
				elsif obj_or_index == "index"
					return counter
				else
					puts "Don't understand what you want from me!? OBJ OR INDEX?"
					return
				end
			end
			counter += 1  # increment index
		end

		# character not saved. return either (nil for object) or (-1 for index)
		if obj_or_index == "obj"
			puts "Character Doesn't Exist. Returning NIL"
			return nil
		else
			puts "Character Doesn't Exist. No index found. Returning -1"
			return -1
		end
	end

	# takes >= 1 characters to save as an array. Loads the all previously saved characters. save all people in team previously saved in memory. Remove those characters from the array of characters to save. Any remaining characters are newly created characters and should be    
	def self.saveCharactersInfo(characters_to_save_array)
		puts "#{characters_to_save_array.size} characters to save"

		characters_to_save_array = characters_to_save_array.uniq		# remove duplicates of people to save. Can't use uniq! or sort! for some reason. 

		loaded_saved_characters_arr = []														# declare the variable to hold character information loaded from file  

		if (File.size($characters_file) < 5 || File.size?($characters_file) == nil)			# if file is empty or doesn't exist
			overwriteCharactersFile(characters_to_save_array)	# save characters_to_save_array to file
		
		else						# file has saved characters in it
			
			loaded_saved_characters_arr = loadAllCharactersFromFile()
			printPeopleInArray(loaded_saved_characters_arr)							# check who we have previously saved
			printPeopleInArray(characters_to_save_array)								# check who we have to save
			should_keep = true
			
			loaded_saved_characters_arr.keep_if do |loaded_character| 	# if a member to save is in the file then delete it from the loaded_saved_characters_arr 
				should_keep = true
				characters_to_save_array.each do |to_save_character| 
					 if loaded_character.name == to_save_character.name 		# loaded character name was found in to_save array. Don't keep previous information of character
					 	 should_keep = false
					 end
				end
				should_keep																								
			end

			overwriteCharactersFile(loaded_saved_characters_arr + characters_to_save_array) # save previously saved people that haven't been deleted and the new team 
		end
	end

	private 
	def self.printPeopleInArray(arr)					# array to test who is 
		puts "[]" if arr.size == 0 
		puts "size = #{arr.size}"
		print "["
		arr.each{|person| print " #{person.to_s} "} 
		puts "]"

	end
		
	def self.overwriteCharactersFile(allCharacters)
		# save back to file
		File.open($characters_file, 'w') do |f| 
			f.puts(YAML::dump(allCharacters))
		end
	end

	def self.loadAllCharactersFromFile()
		character_info_arr = []
		File.open($characters_file, 'r') do |f| # load all character information
			 character_info_arr = YAML::load(f)
		end
		character_info_arr
	end

	public

	# take a few bits of info from file
	def self.printAttributesOfSavedCharacters()
		loadAllCharactersFromFile.each{|i| puts "#{i.name}\t#{i.element} #{self.class.to_s}\tmission lvl #{i.mission_completed}"}
	end

	def self.requestMoreCharactersDuringGame()
		$characters_file = 'characters.txt'
		puts "Do you wish to start a NEW character or LOAD previous character?"
		response = gets.chomp.downcase

		character = nil # use for loading each character
		team = []		# use if loading multiple characters

		if response == 'load'
			if File.size($characters_file) < 10 									# no characters saved previously
				puts "There are no saved characters. Now creating a new character."
			else																# try to find saved characters
				print "previously saved characters are ..." 
				printAttributesOfSavedCharacters()

				puts "How many characters would you like to load?"
				num_to_load = gets.chomp.to_i

				done_loading = false

				while !done_loading 		 # while user still wants to load more team members. Must have at least one member 
					load_successful = false

					while ! load_successful # trying to load a single character to add to team
						puts "What is the name character you want to load?"
						name = gets.chomp
						character = loadCharacter(name, 'obj')

						if character != nil
							if team.includes?(character)
								puts "#{character.class.to_s} #{character.name} is already on your team"
							else
								team << character
								puts "#{character.class.to_s} #{character.name} joined your team"
								load_successful = true
							end
						else 
							puts "Couldn't load #{name}."
						end
						puts "would you like to load another team member? \"yes\" or \"no\""
						temp_input = gets.chomp

						if temp_input == 'no'
							done_loading = true
						end
					end
				end
			end
			if team.size == 0
			puts " No team members = no missions. You currently have no characters on your team." +
				  " Would you like to create one or more characters? Enter \"yes\" or \"no\"" 

			 	if gets.chomp == 'yes'
			 		team << createNewCharacter
			 	else
			 		puts "You can't play without a team. Good Bye."
			 		return 
			 	end
			end
		elsif response == 'new'		# add new characters to the team
			team << createNewCharacter
		end

		return team				# return shortly created character 
	end


	# Step by Step asking user to construct a new character
	# returns a character object
	def self.createNewCharacter()
		$number_of_elements = 4

		CHARACTER_CLASS_TYPES[Wizard.class,Warrior.class, Medic.class]

		while true
			puts "Is your character better on attack or defense?  Enter \"att\" or \"def\""
			att_def_affinity = gets.chomp.downcase
			if att_def_affinity == 'att' || att_def_affinity == 'def'
				break
			end
		end

		while true
			puts "\nWhat is your characters type?  Enter \"wizard\" or \"warrior\" or \"medic\""
			type = gets.chomp.downcase
			break if type == 'wizard' || type == 'warrior' || type == 'medic'
		end

		while true
			puts "What element can your character control?  Enter \"0\" = earth, \"1\" = fire, \"2\" = water, or \"3\" = wind"
			element = gets.chomp.to_i
			break if 0.upto($number_of_elements).include?(element)
		end

		while true
			puts "What is your characters name?"
			name = gets.chomp.downcase.capitalize
			break if name != ""
		end

		puts "type = #{type}"
		character = nil # holder for character object
		puts "#{name} #{element} #{att_def_affinity}"

		character = nil
		case type
			when 'wizard'    then  character = CHARACTER_CLASS_TYPES[0].new(name, element, att_def_affinity)
			when 'warrior'   then  character = CHARACTER_CLASS_TYPES[1].new(name, element, att_def_affinity)
			when 'medic'     then  character = CHARACTER_CLASS_TYPES[2].new(name, element, att_def_affinity)
			else             raise "Create Class Trying To Create Doesn't Exist."
		end

		puts "My name is #{character.name}! Here me roar"
		puts

		return character
	end
end
