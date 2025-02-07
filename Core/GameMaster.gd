extends Node

signal gained_gold(gold_count: int)
signal gained_item(item_name: String)
signal set_name(player_name: String)
signal health_changed(new_health: int)

var turnCounter = 0
var can_move = false

func collectItem(itemName: String):
	match itemName:
		"SmallGold":
			gained_gold.emit(2)
		"MediumGold":
			gained_gold.emit(5)
		"LargeGold":
			gained_gold.emit(10)
		_:
			gained_item.emit(itemName)

func damage_player(amount: int):
	$Player.health -= amount
	health_changed.emit($Player.health)

func heal_player(amount: int):
	$Player.health += amount
	health_changed.emit($Player.health)

func setname(player_name: String):
	if player_name:
		can_move = true
		set_name.emit(player_name)

#function to take a turn, should basically wait for the player signal then handle all the enemies
#made it take any value in case we want faster enemies or slower player debuffs
func takeTurn(turnsTaken: int):
	#if not GameMaster.can_move:
		#return
	print("Starting player turn")
	turnCounter += turnsTaken
	print("Current turn: ",turnCounter);
	#apply over-time effects, increment timers, whatever is appropriate here
	print("Ending player turn")
	enemyTurn()

#player and enemy turns are separated out so the player always gets priority over the enemies (unless debuffs change that)
func enemyTurn():
	print("Starting enemy turn")
	#handle enemy signals here
	print("Ending enemy turn")
