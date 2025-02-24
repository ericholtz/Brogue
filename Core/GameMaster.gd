extends Node

#var rng : RandomNumberGenerator

signal gained_gold(gold_count: int)
signal gained_item(item_name: String)
signal set_name(player_name: String)
signal took_turns(turns: int)
signal damage_player_signal(amount: int)
signal heal_player_signal(amount: int)

# Turn on/off debug statments
var DEBUG_MAP = false

var DISABLE_FOG = true

# seeds
var current_seed
var user_seed

var turnCounter = 0
var can_move = false

enum EntityType {GOLD, MELEE_WEAPON, ARMOR, POTION, MISC}

func collectEntity(entity: Area2D):
	var entityType = entity.get_child(0).type
	match entityType:
		EntityType.GOLD:
			gained_gold.emit(entity.find_child("GoldStats").gold_worth)
		_:
			gained_item.emit(entity)

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
	print("Ending player turn\n")
	took_turns.emit(1)
	await enemyTurn()
	can_move = true

#player and enemy turns are separated out so the player always gets priority over the enemies (unless debuffs change that)
func enemyTurn():
	print("Starting enemy turn")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in range(enemies.size()):
		var enemy = enemies[i]
		print("Enemy [", i,"|",enemy.name, "] at position ", enemy.position, " moving in direction ", enemy.vec_to_cardinal(enemy.position.direction_to(enemy.player.position)) if enemy.player else Vector2.ZERO)
		await enemy.take_turn()
	print("Ending enemy turn\n")

#combat method, this can be changed for balance
func combat(player, enemy):
	var playerName = player.player_name
	var enemyName = enemy.name
	print("-----Initiating combat between ",playerName," and ",enemyName,"!-----")
	
	#take combatant strength - opponent defense as damage, floor to 1. Enemies can do 0 damage to player.
	var playerDamage = max(player.attack - enemy.defense, 1)
	var enemyDamage = max(enemy.strength - player.armor, 1)
	
	#roll for player's chance to hit
	var playerHitChance = calculate_hit_chance(player.attack, enemy.defense)
	var playerRoll = randf()
	print(playerName," needs less than <",playerHitChance,"> to hit, rolled a <",snapped(playerRoll,0.01),">.")
	if playerRoll <= playerHitChance:
		enemy.health -= playerDamage
		can_move = false
		var attackTween = animate_attack(player, enemy)
		await attackTween.finished
		print(playerName," dealt ",playerDamage," damage to ",enemyName,". ",enemyName," has ",enemy.health," health left.\n")
		can_move = true
	else:
		print(playerName," missed ",enemyName,"!\n")
	
	var enemyHitChance = calculate_hit_chance(enemy.strength,player.armor)
	var enemyRoll = randf()
	print(enemyName," needs less than <",enemyHitChance,"> to hit, rolled a <",snapped(enemyRoll,0.01),">.")
	if enemyRoll <= enemyHitChance:
		damage_player_signal.emit(enemyDamage)
		can_move = false
		var attackTween = animate_attack(enemy, player)
		await attackTween.finished
		print(enemyName," dealt ",enemyDamage," damage to ",playerName,". ",playerName," has ",player.health," health left.")
		can_move = true
	else:
		print(enemyName," missed ",playerName,"!")
	
	#if enemy dies, call free
	if enemy.health <= 0:
		print(enemyName," defeated!")
		player.add_xp(enemy.xp)
		print(playerName," gained <",enemy.xp,"> xp!")
		enemy.queue_free()
	
	#if player dies, game over. Need Gabe's game over screen called here.
	if player.health <= 0:
		print(playerName," died!\n")

#calculate chance to hit based on difference between attack and armor
func calculate_hit_chance(attack, defense):
	var baseHit = 0.90
	var minHit = 0.40
	
	var diff = attack - defense
	
	#penalty is applied if diff < 0
	#for example, if the player has 3 defense vs a skeleton with 1 attack
	#diff = -2, penalty = 0.20, chance to hit = 0.75
	var penalty = 0.10 * max(-diff,0)
	#clamp penalty to minHit value so there's always a chance to hit something
	penalty = clamp(penalty, 0.0, baseHit - minHit)
	
	return baseHit - penalty

func animate_attack(attacker, target) -> Tween:
	var distance = -8.0
	var animSpeed = 0.1
	var originPos = attacker.position
	var originColor = attacker.modulate
	var direction = (attacker.position - target.position).normalized()
	var offset = direction * distance
	
	#make an animation tween to do a couple things
	var tween = get_tree().create_tween()
	
	#firstly, we bounce the player off the enemy's tile
	tween.tween_property(attacker, "position", originPos + offset, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(attacker, "position", originPos, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	#then, we flash the attacked party red by modulating
	tween.tween_property(target, "modulate", Color.RED, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate", originColor, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	return tween
