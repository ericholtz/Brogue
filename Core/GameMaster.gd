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
	#var player = get_tree().get_first_node_in_group("player")
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

#combat method, this can be changed for balance
func combat(player, enemy):
	var playerName = player.player_name
	var enemyName = enemy.name
	#take combatant strength - opponent defense as damage, floor to 1. Enemies can do 0 damage to player if they roll badly.
	var playerDamage = max(player.strength - enemy.defense, 1)
	var enemyDamage = max(enemy.strength - player.defense, 1)
	if enemyDamage == 1:
		enemyDamage = randi_range(0,1)
	
	#I don't love that this doesn't use signals both ways but I wrote it and it works
	enemy.health -= playerDamage
	print(playerName," dealt ",playerDamage," damage to ",enemyName,". ",enemyName," has ",enemy.health," health left.")
	damage_player_signal.emit(enemyDamage)
	if enemyDamage >= 1:
		print(enemyName," dealt ",enemyDamage," damage to ",playerName,". ",playerName," has ",player.health," health left.")
	else:
		print(enemyName," missed!")
	
	#if enemy dies, call free
	if enemy.health <= 0:
		print(enemyName," defeated!")
		enemy.queue_free()
	
	#if player dies, game over. Need Gabe's game over screen called here.
	if player.health <= 0:
		print(playerName," died!")
		pass
