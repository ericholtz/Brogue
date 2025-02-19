extends Node

signal gained_gold(gold_count: int)
signal gained_item(item_name: String)
signal set_name(player_name: String)
signal took_turns(turns: int)
signal damage_player_signal(amount: int)
signal heal_player_signal(amount: int)

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
	print("Damaging player for "+str(amount)+" points.")
	damage_player_signal.emit(amount)

func heal_player(amount: int):
	print("Healing player for "+str(amount)+" points.")
	heal_player_signal.emit(amount)


func setname(player_name: String):
	if player_name:
		can_move = true
		set_name.emit(player_name)

#function to take a turn, should basically wait for the player signal then handle all the enemies
#made it take any value in case we want faster enemies or slower player debuffs
func takeTurn(turnsTaken: int):
	var player = get_tree().get_first_node_in_group("player")
	if not can_move:
		return
	print("Starting player turn")
	turnCounter += turnsTaken
	print("Current turn: ",turnCounter);
	can_move = false
	#apply over-time effects, increment timers, whatever is appropriate here
	print("Ending player turn")
	took_turns.emit(1)
	await enemyTurn()
	can_move = true

#player and enemy turns are separated out so the player always gets priority over the enemies (unless debuffs change that)
func enemyTurn():
	print("Starting enemy turn")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in range(enemies.size()):
		var enemy = enemies[i]
		print("Enemy [", i, "] at position ", enemy.position, " moving in direction ", enemy.vec_to_cardinal(enemy.position.direction_to(enemy.player.position)) if enemy.player else Vector2.ZERO)
		await enemy.take_turn()
	print("Ending enemy turn")
