require_relative 'creature_classes'
require 'pry'
require 'yaml' # uses it

	$number_of_elements = 4

class Missions
	def self.missionReady?(level, character_array)
		is_ready = false
		character_array.each{|i| is_ready = true  if i.mission_completed >= level - 1} 
		is_ready
	end

	# MISSIONS GO FROM 0->Size-1
	def self.startMission!(level, character_array)
		require_relative 'creature_classes'
		if !missionReady?(level, character_array)							# Prevent them from accessing mission if no one leveled high enough to access
			puts "No member of the group are ready for level #{level}"
			return
		end 

		arr = nil
		File.open("mission_enemy_layout.txt", 'r') do |f| # load enemies file 
		  arr = YAML::load(f)
		end
		
		minion_arr = Array.new(arr[level - 1][0].to_i){ Minion.new("minion", rand($number_of_elements)) }	# put number of minions loaded from file into an array
		boss_arr   = Array.new(arr[level - 1][1].to_i){ Boss.new("boss", rand($number_of_elements)) }		# put number of bossess loaded from file into an array

		character_array.each{|i| print "#{i.name} "}

		puts "\nPrepare for battle against\n" + "#{minion_arr.length} minions\n" + "#{boss_arr.length} bosses"
		num_players_alive = character_array.size       # remember how many characters are alive
		while (minion_arr.size + boss_arr.size != 0) && (num_players_alive > 0) # while there are still enemies alive

			#heros attack first
			character_array.each do |character| 
				View.DisplayScreen(character_array, minion_arr, boss_arr)
				next if character.health_current <= 0  							# If player is dead then skip them
				break if boss_arr.size + minion_arr.size == 0				# Mission over if all enemies are dead
				puts "#{character.name} is up." 
				
				while true 
					print "Attack : "
					/^(m|b)\s+(\d+)$/.match(gets.chomp)
					#binding.pry
					if $1 == 'm' 
						if 0 < $2.to_i && $2.to_i <= minion_arr.size  											# if minion to attack is a possible position to target
							attacking_minion_position = $2.to_i		
							 minion_arr[attacking_minion_position - 1].attacked_by(character)	# Character to attack minion at index $2.to_i

							 if minion_arr[attacking_minion_position - 1].health_current <= 0		# if character died
							 		puts "Minion #{minion_arr[attacking_minion_position - 1]} Died"			# Declare he died and 
							 		minion_arr.delete_at(attacking_minion_position - 1)
							 	else																														# If minion still alive
							 		puts character_array[rand(character_array.size)]
							 	end			
							 break
						else
							puts "minion position doesn't exist"
						end

					elsif $1 == 'b'
						if 0 < $2.to_i && $2.to_i <= boss_arr.size  									# if boss to attack is a possible position to target
							attacking_boss_position = $2.to_i		
							 boss_arr[attacking_boss_position - 1].attacked_by(character)	# 
							 if boss_arr[attacking_boss_position - 1].health_current <= 0
							 		puts "Boss #{boss_arr[attacking_boss_position - 1]} Died"
							 		boss_arr.delete_at(attacking_boss_position - 1)						
							 else																														# If boss still alive
							 		puts character_array[rand(character_array.size)]
							 end			
							 break
						else
							puts "Boss position doesn't exist"
						end
					else
						puts "DON'T KNOW WHO TO ATTACK?"
					end
				end
			end

			#bosses attack next
			boss_arr.each{|boss| r = rand(character_array.size); puts "Boss #{boss.name} attacked #{character_array[r]}"; character_array[r].attacked_by(boss)} 

			#enemies attack next
		  minion_arr.each{|minion| r = rand(character_array.size); puts "minion #{minion.name} attacked #{character_array[r]}"; character_array[r].attacked_by(minion)} 

		end	

		if num_players_alive != 0
			 missionSucceeded(level, character_array) 
		else
			 puts "Your team was defeated."
		end
	end 

private
	def self.missionSucceeded(level_completed, hero_team_arr)
		
		puts;puts 
		award_pts_per_minion = 1
		award_pts_per_boss   = 3

		enemies = nil
		File.open("mission_enemy_layout.txt", 'r') do |f| # load all character information
		  enemies = YAML::load(f)
		end

		puts "You beat level #{level_completed}! containing #{enemies[level_completed - 1][0]} minions and #{enemies[level_completed - 1][1]} bosses"
		
		hero_team_arr.map! do |character| 
			if character.health_current > 0					# if character survived the mission
				new_points = enemies[level_completed - 1][0] * award_pts_per_minion + enemies[level_completed - 1][1] * award_pts_per_boss # award the characters for surviving the mission
				character.award_points += new_points
				puts "#{character.name} #{new_points} award points received"
			end

			if level_completed > character.mission_completed 
				character.mission_completed = level_completed 
			end
			character 	# return the character just mapped into the hero
		end
	end

	def self.restoreCharacterHealth(team)
		team.each{|character| character.health_current = character.health_max}
	end
end
$ELEMENT_TO_WORDS =	{0 => "Earth", 1 =>"Fire", 2 => "Water", 3 =>"Wind"}							
$ELEMENT_COLORS = ["\033[92m", "\033[91m", "\033[94m", "\033[98m", "\[\033[0;30m\]"]#{:earth => "\033[92m", :fire =>"\033[91m", :water => "\033[94m", :wind => "\033[94m", :unwind => "\[\033[0;30m\]"}
#$STAGE_ELEMENTS = [ "\033[100m", "", "\033[106m", "\033[107m"]
$PLAYER_HEALTH_DANGER = "\[\033[0;30m\]"#"\033[5m"
$STOP_COLOR = "\033[0m"
		#earch , wind, 

class View
	def self.DisplayScreen(team_arr, minions_arr, bosses_arr)
	
			#print $STAGE_ELEMENTS[3]


		  creature_string = ""
			bosses_arr.each do |boss| 
				creature_string += $ELEMENT_COLORS[boss.element] + (boss.health_current.to_f/boss.health_max < 0.25 ? $PLAYER_HEALTH_DANGER : "") + 
															$ELEMENT_TO_WORDS[boss.element] + "_Boss_" + boss.att_def_affinity.capitalize + "(a:#{boss.attack_str},d:#{boss.defense_str}){#{((boss.health_current.to_f/boss.health_max) * 100).floor}%}"+ $STOP_COLOR + "\t\t"
			end
			puts creature_string
			puts

		  creature_string = "\t"
			minions_arr.each do |minion| 
				creature_string += $ELEMENT_COLORS[minion.element] + (minion.health_current.to_f/minion.health_max < 0.25 ? $PLAYER_HEALTH_DANGER : "") + 
															$ELEMENT_TO_WORDS[minion.element] + "_Minion_" + minion.att_def_affinity.capitalize + "(a:#{minion.attack_str},d:#{minion.defense_str}){#{((minion.health_current.to_f/minion.health_max) * 100).floor}%}" + $STOP_COLOR + "\t\t"
			end
			puts creature_string
			puts;puts;puts

			creature_string = ""
			team_arr.each do |character| 
				creature_string += $ELEMENT_COLORS[character.element] + (character.health_current.to_f/character.health_max < 0.25 ? $PLAYER_HEALTH_DANGER : "") + 
															$ELEMENT_TO_WORDS[character.element] + "_#{character.class.to_s}_" + "#{character.name}_" + character.att_def_affinity.capitalize + "(a:#{character.attack_str},d:#{character.defense_str}){#{((character.health_current.to_f/character.health_max) * 100).floor}%}" + $STOP_COLOR + "\t\t"
			end
			puts creature_string

	end
end
