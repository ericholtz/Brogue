extends Node

signal gained_gold(gold_count: int)
signal gained_item(item_name: String)
signal set_name(player_name: String)
signal took_turns(turns: int)
signal damage_player_signal(amount: int)
signal heal_player_signal(amount: int)

# Turn on/off debug statments
@export var DEBUG_MAP = false

#toggle for verbose combat logs
@export var DEBUG_COMBATLOGS = false

#For monsters
@export var DEBUG_RANDMOVE = false

#Dont Change Look at readme!
var DISABLE_FOG = false

# seeds
var current_seed
var user_seed

@export var turnCounter = 0
var can_move = false
var animSpeed = 0.1

enum EntityType {GOLD, ITEM, ENEMY}
enum ItemType {MELEE_WEAPON, RANGED_WEAPON, ARMOR, POTION, MISC}
enum PotionEffect {HEALING, SPEED, POISON, PSYCHADELIC, INVISIBILITY}

func collect_entity(entity: Area2D):
	match entity.entityType:
		EntityType.GOLD:
			gained_gold.emit(entity.gold_worth)
		EntityType.ITEM:
			gained_item.emit(entity)

func damage_player(amount: int):
	if DEBUG_COMBATLOGS:
		print("Damaging player for "+str(amount)+" points.")
	damage_player_signal.emit(amount)

func heal_player(amount: int):
	if DEBUG_COMBATLOGS:
		print("Healing player for "+str(amount)+" points.")
	heal_player_signal.emit(amount)


func setname(player_name: String):
	if player_name:
		can_move = true
		set_name.emit(player_name)

#function to take a turn, should basically wait for the player signal then handle all the enemies
#made it take any value in case we want faster enemies or slower player debuffs
func takeTurn(turnsTaken: int):
	#if can_move flag is false, do nothing
	if not can_move:
		return
	
	turnCounter += turnsTaken
	if DEBUG_COMBATLOGS:
		print("Current turn: ",turnCounter);
	can_move = false
	
	#apply over-time effects, increment timers, whatever is appropriate here
	
	took_turns.emit(1) #this just sends a signal to the ui turn counter
	await enemyTurn()
	await get_tree().process_frame
	can_move = true

#player and enemy turns are separated out so the player always gets priority over the enemies (unless debuffs change that)
func enemyTurn():
	if DEBUG_COMBATLOGS:
		print("Starting enemy turn")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in range(enemies.size()):
		var enemy = enemies[i]
		if DEBUG_COMBATLOGS == true:
			print("Enemy [", i,"|",enemy.name, "] at position ", enemy.position, " moving in direction ", enemy.vec_to_cardinal(enemy.position.direction_to(enemy.player.position)) if enemy.player else Vector2.ZERO)
		await enemy.take_turn()
	if DEBUG_COMBATLOGS:
		print("Ending enemy turn\n")

#combat method, this can be changed for balance
func melee_attack(attacker, defender):
	#lock player
	can_move = false
	#grab some information about combatants
	var attacker_name = attacker.entity_name
	var defender_name = defender.entity_name
	var enemy_xp
	if defender.is_in_group("enemies"):
		enemy_xp = defender.xp
	
	#take combatant attack - opponent armor as damage, floor player to 1 and enemies to 0 damage to favor player some.
	var attacker_damage = max(attacker.attack - defender.armor, 1)
	var defender_damage = max(defender.attack - attacker.armor, 1)
	
	if DEBUG_COMBATLOGS:
		print("-----Initiating combat between ",attacker_name," and ",defender_name,"!-----")
	#roll for player's chance to hit
	var attacker_hit_chance = calculate_hit_chance(attacker.attack, defender.armor)
	var attacker_roll = randf()
	if DEBUG_COMBATLOGS:
		print(attacker_name," needs less than <",attacker_hit_chance,"> to hit, rolled a <",snapped(attacker_roll,0.01),">.")
	if attacker_roll <= attacker_hit_chance:
		defender.health -= attacker_damage
		var attack_tween = animate_attack(attacker, defender)
		await attack_tween.finished
		if is_instance_valid(defender):
			if DEBUG_COMBATLOGS:
				print(attacker_name," dealt ",attacker_damage," damage to ",defender_name,". ",defender_name," has ",defender.health," health left.\n")
	else:
		var miss_tween = animate_miss(attacker)
		await miss_tween.finished
		if DEBUG_COMBATLOGS:
			print(attacker_name," missed ",defender_name,"!\n")
	
	#after player attacks, check if enemy is dead
	var defender_defeated
	if is_instance_valid(defender):
		defender_defeated = defender.health <= 0
	else:
		defender_defeated = true
	
	#if it's alive, roll combat
	if not defender_defeated:
		var defender_hit_chance = calculate_hit_chance(defender.attack,attacker.armor)
		var defender_roll = randf()
		if DEBUG_COMBATLOGS:
			print(defender_name," needs less than <",defender_hit_chance,"> to hit, rolled a <",snapped(defender_roll,0.01),">.")
		if defender_roll <= defender_hit_chance:
			attacker.health -= defender_damage
			var attack_tween = animate_attack(defender, attacker)
			await attack_tween.finished
			if DEBUG_COMBATLOGS:
				print(defender_name," dealt ",defender_damage," damage to ",attacker_name,". ",attacker_name," has ",attacker.health," health left.")
		else:
			var miss_tween = animate_miss(defender)
			await miss_tween.finished
			if DEBUG_COMBATLOGS:
				print(defender_name," missed ",attacker_name,"!")
	
	#if enemy dies, call free and give player xp
	if defender_defeated:
		var death_tween = animate_death(defender)
		await death_tween.finished
		if DEBUG_COMBATLOGS:
			print(defender_name," defeated!")
		if is_instance_valid(attacker) && attacker.is_in_group("player"):
			attacker.add_xp(enemy_xp)
			if DEBUG_COMBATLOGS:
				print(attacker_name," gained <",enemy_xp,"> xp!")
		if is_instance_valid(defender) && defender.is_in_group("enemies"):
			defender.queue_free()
	
	#if player dies, game over.
	if attacker.health <= 0:
		var death_tween = animate_death(attacker)
		await death_tween.finished
		if DEBUG_COMBATLOGS:
			print(attacker_name," died!\n")
	
	await get_tree().process_frame
	can_move = true;

#calculate chance to hit based on difference between attack and armor
func calculate_hit_chance(attack, armor):
	var baseHit = 0.90
	var minHit = 0.40
	var diff = armor - attack
	#penalty is applied if diff > 0
	#for example, if the player has 3 armor vs a skeleton with 1 attack
	#diff = 2, penalty = 0.20, chance to hit = 0.70
	var penalty = 0.10 * diff
	#clamp penalty to minHit value so there's always a chance to hit something
	penalty = clamp(penalty, 0.0, baseHit - minHit)
	#returns a value from 0.4-0.9, the player must roll below that to hit.
	return baseHit - penalty

func animate_attack(attacker, target) -> Tween:
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return get_tree().create_tween()
	var distance = -8.0
	var originPos = attacker.position.snapped(Vector2.ONE * -distance)
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
	tween.tween_callback(func():
			attacker.position = originPos.snapped(Vector2.ONE * -distance)
	)
	return tween

func animate_miss(attacker) -> Tween:
	if not is_instance_valid(attacker):
		return get_tree().create_tween()
	var offset = 4.0
	var originPos = attacker.position
	
	var tween = get_tree().create_tween()
	
	for n in range (2):
		tween.tween_property(attacker, "position", originPos + Vector2(offset, 0), animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(attacker, "position", originPos - Vector2(offset, 0), animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		attacker.position = originPos.snapped(Vector2.ONE * -8)
	)
	return tween

func animate_death(target) -> Tween:
	if not is_instance_valid(target):
		return get_tree().create_tween()
		
	var tween = get_tree().create_tween()
	
	tween.tween_property(target, "modulate", Color.RED, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "scale", Vector2(), animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	return tween
