require_relative 'loading_saving_characters'

characters_file = "characters.txt"

number_of_elements = 4

$element_chart = [ [1,1,1.5,0.5],
                  [1,1,0.5,1.5],
                  [0.5,1.5,1,1],
                  [1.5,0.5,1,1] ]

class Creature

  attr_accessor     :attack_str
  attr_reader       :att_def_affinity     # does your element help your attack or defense
  attr_accessor     :defense_str
  attr_reader	  	  :element
  attr_accessor	  	:health_current
  attr_accessor     :health_max
  attr_accessor   	:name
  attr_reader 	  	:type

  def initialize(name, element, att_def_affinity, health_max, health_current, attack_str, defense_str, type)
    @attack_str   	   = attack_str
    @att_def_affinity  = att_def_affinity
    @defense_str  	   = defense_str
    @element           = element
    @health_current    = health_current
    @health_max   	   = health_max
    @name       	     = name
    @type			         = type
  end

  def speak
    print "#{@name} says \"" 
    yield
    print "\"\n"
  end

  def to_s
    if @health_current > 0
      "#{@type} #{@name}\'s health is #{@health_current}/#{@health_max} = #{((@health_current.to_f/@health_max) * 100).floor}%"
    else
      "#{@type} #{@name}\ is Dead."
    end
  end

  # returns -1 if person being attacked is dead
  def attacked_by(attacking_creature, att_or_spell="att")
    if @health_current <= 0 
        puts "#{@name} is already dead. You can't attack them"
  	    return -1
    end

     att_or_spell_damage = 0                          # hold whatever type of damage they are 
  	if(att_or_spell == "att")                          # find out if 
  		att_or_spell_damage = attacking_creature.attack_str 
  	elsif (att_or_spell == "spell")
  		att_or_spell_damage = attacking_creature.spell_str 
  	else
  		puts "Your offensive move doesn't exist"
  		return
  	end

  	damage = ((att_or_spell_damage - defense_str) * ($element_chart[attacking_creature.element][element] + 
      (attacking_creature.att_def_affinity == "att" ? 0.5 : 0) - (att_def_affinity == "def" ? - 0.5 : 0))).round     # Damage Formula
  	
    if damage > 0 
      puts "#{attacking_creature.type} #{attacking_creature.name} attacked name.\n #{damage} damage done."
      @health_current = (@health_current - damage > 0) ? @health_current - damage : 0 # subtract creatures health by the damage done 
    else
      puts "#{attacking_creature.name} couldn't penetrate #{name}'s defense strength. No Damage Done!"
    end
  	

  	puts "#{@type} #{@name} DIED!" if @health_current <= 0
   end
end

class Minion < Creature
	def initialize(name="no-name", element=0, health_max=30, health_current=30, attack_str=3, defense_str=3, type="Minion")
		super(name, element, rand(2) ? "att" : "def", health_max, health_current, attack_str, defense_str, type)
	end
end

class Boss < Creature
	def initialize(name="no-name", element=0, health_max=70, health_current=70, attack_str=6, defense_str=4, type="Boss")
		super(name, element, rand(2) ? "att" : "def", health_max, health_current, attack_str, defense_str, type)
	end
end

class Person < Creature

  attr_accessor     :heal_str
  attr_accessor     :mission_completed
  attr_accessor     :award_points
 
  @@team_size = 0

  def initialize(name="no-name", element=0, att_def_affinity="def", health_max=10, health_current=10, attack_str=1, defense_str=1, heal_str=0, mission_completed=0, award_points=0, type="person")
    super(name, element, att_def_affinity, health_max, health_current, attack_str, defense_str, type)
    @attack_str     	  = attack_str
    @award_points     	= award_points
    @heal_str       	  = heal_str
    @mission_completed  = mission_completed
    @@team_size        += 1                   # increment team size tracker
  end
end

class Warrior < Person
  def initialize(name="no-name", element=1, att_def_affinity="att", health_max=100, health_current=100, attack_str=15, defense_str=5, heal_str=5, mission_completed=0, award_points=0, type=self.class.to_s )
    super(name, element, att_def_affinity, health_max, health_current, attack_str, defense_str, heal_str, mission_completed, award_points, type)
  end
end

class Wizard < Person
  attr_accessor  :spell_str

  def initialize(name="no-name", element=2, att_def_affinity="att", health_max=100, health_current=100, attack_str=5, defense_str=10, heal_str=5, spell_str=20, mission_completed=0, award_points=0, type=self.class.to_s)
    super(name, element, att_def_affinity, health_max, health_current, attack_str, defense_str, heal_str, mission_completed, award_points, type)
    @spell_str = spell_str
  end
end
 
class Medic < Person
  def initialize(name="no-name", element=0, att_def_affinity="def", health_max=120, health_current=120, attack_str=5, defense_str=10, heal_str=20, mission_completed=0, award_points=0, type=self.class.to_s)
    super(name, element, att_def_affinity, health_max, health_current, attack_str, defense_str, heal_str, mission_completed, award_points, type)
  end
end
