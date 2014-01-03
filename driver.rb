require_relative 'creature_classes'
require_relative 'missions'
#require_relative 'New_Game_Introduction'
require_relative 'loading_saving_characters'

#GetACharacter

a = LoadingSavingCharacters.findCharacterIndexInFile("Alab", 'obj')
b = LoadingSavingCharacters.findCharacterIndexInFile("Buster", 'obj')
c = LoadingSavingCharacters.findCharacterIndexInFile("Cru", 'obj')

team = [a,b,c]

for level in 7..8
  Missions.startMission!(level,team)
end

LoadingSavingCharacters.saveCharactersInfo(team)



#LoadingSavingCharacters.saveCharactersInfo([a,b,c])
