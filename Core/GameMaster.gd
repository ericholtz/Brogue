extends Node

# signals
signal gained_gold(gold_count: int)
signal gained_item(item_name: String)
signal set_name(player_name: String)
signal took_turns(turns: int)
signal damage_player_signal(amount: int)
signal heal_player_signal(amount: int)
signal end_status_effect_signal(effect: StatusEffect)

# Turn on/off debug statments
@export var DEBUG_MAP = false

#toggle for verbose combat logs
@export var DEBUG_COMBATLOGS = false

#For monsters
@export var DEBUG_RANDMOVE = false

#For monsters
@export var DEBUG_ENEMY_PRINTS = false

#Dont Change Look at readme!
var DISABLE_FOG = false

# seeds
var current_seed
var user_seed

@export var turnCounter = 0
var can_move = false
var animSpeed = 0.1

enum EntityType {
	GOLD,
	ITEM,
	ENEMY,
	ROOM,
	}
enum ItemType {
	MELEE_WEAPON,
	RANGED_WEAPON,
	ARMOR,
	POTION,
	SCROLL,
	MISC,
	}
enum PotionEffect {
	HEALING,
	SPEED,
	POISON,
	PSYCHEDELIC,
	INVISIBILITY,
	}
enum ScrollEffect {
	RANDOM_TP,
	DARKNESS,
	IDENTIFY,
	GOLD_RUSH,
	}
enum MiscType {
	KEY,
	MAP,
	}

enum StatusEffect {
	SPEEDY,
	POISONED,
	PSYCHEDELIC,
	INVISIBLE,
	}

var status_effects = []

var potion_types = {}
var potion_types_str = {}

var scroll_names = {}
var scroll_sprite_regions = {}

func _ready() -> void:
	status_effects.resize(StatusEffect.size())
	status_effects.fill(0)
	# decide item randomizations
	decide_potions()
	decide_scrolls()

func collect_entity(entity: Area2D):
	if !entity:
		return
	match entity.entity_type:
		EntityType.GOLD:
			gained_gold.emit(entity.gold_worth)
		EntityType.ITEM:
			gained_item.emit(entity)

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
	apply_health_diff()
	apply_effects()
	
	decrement_status_effect_duration()
	
	took_turns.emit(1) #this just sends a signal to the ui turn counter
	await enemyTurn()
	await get_tree().process_frame
	can_move = true

# apply status effect damage, passive regen, etc.
func apply_health_diff():
	var heal_amount = 0
	var damage_amount = 0
	
	# 1 tick of poison damage every other turn
	if status_effects[StatusEffect.POISONED] != 0 and status_effects[StatusEffect.POISONED] % 2 == 0:
		damage_amount += 1
	
	# passive regen every 20 turns
	if turnCounter % 20 == 0:
		heal_amount += 1

	# apply difference of healing and damage to not redundantly do both
	var diff = heal_amount - damage_amount
	if diff > 0:
		heal_player(diff)
	else:
		damage_player(0-diff)

func heal_player(amount: int):
	if DEBUG_COMBATLOGS:
		print("Healing player for "+str(amount)+" points.")
	heal_player_signal.emit(amount)

func damage_player(amount: int):
	if DEBUG_COMBATLOGS:
		print("Damaging player for "+str(amount)+" points.")
	damage_player_signal.emit(amount)

func start_status_effect(effect: StatusEffect, duration: int):
	if status_effects[effect] < duration:
		status_effects[effect] = duration
	match effect:
		StatusEffect.PSYCHEDELIC:
			start_psychedelic()

func start_psychedelic():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var AnimatedSprite
	for i in range(enemies.size()):
		AnimatedSprite = enemies[i].find_child("AnimatedSprite2D")
		AnimatedSprite.animation = &"Random"
		AnimatedSprite.stop()
	cycle_psychedelic()

func apply_effects():
	if status_effects[StatusEffect.PSYCHEDELIC] != 0:
		cycle_psychedelic()

func cycle_psychedelic():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var AnimatedSprite
	var frame_count
	for i in range(enemies.size()):
		AnimatedSprite = enemies[i].find_child("AnimatedSprite2D")
		frame_count = AnimatedSprite.sprite_frames.get_frame_count("Random")
		AnimatedSprite.frame = randi() % frame_count

func decrement_status_effect_duration():
	for i in range(0, status_effects.size()):
		if status_effects[i] == 0:
			continue
		status_effects[i] -= 1
		if status_effects[i] == 0:
			end_status_effect_signal.emit(i)
			end_status_effect(i)

func end_status_effect(effect: int):
	match effect:
		StatusEffect.PSYCHEDELIC:
			end_psychedelic_effect()

func end_psychedelic_effect():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in range(enemies.size()):
		var AnimatedSprite = enemies[i].find_child("AnimatedSprite2D")
		AnimatedSprite.animation = &"default"
		AnimatedSprite.play()

func decide_potions():
	var rng = RandomNumberGenerator.new()
	var potion_names = ["RedPotion", "OrangePotion", "GreenPotion", "PurplePotion", "BluePotion"]
	var healing_weights = [6, 1, 1, 1, 1]
	var speed_weights = [1, 3, 1, 1, 1]
	var poison_weights = [1, 1, 4, 1, 1]
	var psychedelic_weights = [1, 1, 1, 2, 1]
	var invisibility_weights = [1, 1, 1, 1, 1]
	var weights = [healing_weights, speed_weights, poison_weights, psychedelic_weights, invisibility_weights]
	
	for i in potion_names.size():
		var potion_name = potion_names[i]
		var potion_index = rng.rand_weighted(weights[i])
		potion_types[potion_name] = PotionEffect.values()[potion_index]
		potion_types_str[potion_name] = PotionEffect.keys()[potion_index]
		for j in range(i, potion_names.size()):
			weights[j][potion_index] = 0
	
	print(potion_types_str)

func decide_scrolls():
	var horiz = []
	for i in range(1, 7):
		horiz.append(16 * i)
	
	for effect in ScrollEffect.values():
		var name = generate_gibberish_text()
		while name in scroll_names.values():
			name = generate_gibberish_text()
		scroll_names[effect] = name
		
		var index = randi_range(0, horiz.size() - 1)
		scroll_sprite_regions[effect] = Rect2(horiz[index], 208, 16, 16)
		horiz.pop_at(index)

func generate_gibberish_text():
	var alphabet = "bcdfghjklmnpqrstvwxz"
	var full_alphabet = alphabet.split()
	full_alphabet.append_array(alphabet.to_upper().split())
	
	var str = ""
	for word in range(0, randi_range(3, 5)):
		for character in range(0, randi_range(2, 7)):
			str += full_alphabet[randi_range(0, full_alphabet.size()-1)]
		str += " "
	
	return str.left(-1)

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
func combat(player, enemy):
	#lock player
	can_move = false
	#grab some information about combatants
	var playerName = player.player_name
	var enemyName = enemy.name
	var enemyXP = enemy.xp
	#take combatant strength - opponent defense as damage, floor player to 1 and enemies to 0 damage to favor player some.
	var playerDamage = max(player.attack - enemy.defense, 1)
	var enemyDamage = max(enemy.strength - player.armor, 1)
	
	if DEBUG_COMBATLOGS:
		print("-----Initiating combat between ",playerName," and ",enemyName,"!-----")
	#roll for player's chance to hit
	var playerHitChance = calculate_hit_chance(player.attack, enemy.defense)
	var playerRoll = randf()
	if DEBUG_COMBATLOGS:
		print(playerName," needs less than <",playerHitChance,"> to hit, rolled a <",snapped(playerRoll,0.01),">.")
	if playerRoll <= playerHitChance:
		#THIS SHOULD BE A SIGNAL
		enemy.health -= playerDamage
		var attackTween = animate_attack(player, enemy)
		await attackTween.finished
		if is_instance_valid(enemy):
			if DEBUG_COMBATLOGS:
				print(playerName," dealt ",playerDamage," damage to ",enemyName,". ",enemyName," has ",enemy.health," health left.\n")
	else:
		var missTween = animate_miss(player)
		await missTween.finished
		if DEBUG_COMBATLOGS:
			print(playerName," missed ",enemyName,"!\n")
	
	#after player attacks, check if enemy is dead
	var enemyDefeated
	if is_instance_valid(enemy):
		enemyDefeated = enemy.health <= 0
	else:
		enemyDefeated = true
	
	#if it's alive, roll combat
	if not enemyDefeated:
		var enemyHitChance = calculate_hit_chance(enemy.strength,player.armor)
		var enemyRoll = randf()
		if DEBUG_COMBATLOGS:
			print(enemyName," needs less than <",enemyHitChance,"> to hit, rolled a <",snapped(enemyRoll,0.01),">.")
		if enemyRoll <= enemyHitChance:
			damage_player_signal.emit(enemyDamage)
			var attackTween = animate_attack(enemy, player)
			await attackTween.finished
			if DEBUG_COMBATLOGS:
				print(enemyName," dealt ",enemyDamage," damage to ",playerName,". ",playerName," has ",player.health," health left.")
		else:
			var missTween = animate_miss(enemy)
			await missTween.finished
			if DEBUG_COMBATLOGS:
				print(enemyName," missed ",playerName,"!")
	
	#if enemy dies, call free and give player xp
	if enemyDefeated:
		var deathTween = animate_death(enemy)
		await deathTween.finished
		if DEBUG_COMBATLOGS:
			print(enemyName," defeated!")
		player.add_xp(enemyXP)
		if DEBUG_COMBATLOGS:
			print(playerName," gained <",enemyXP,"> xp!")
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	#if player dies, game over.
	if player.health <= 0:
		var deathTween = animate_death(player)
		await deathTween.finished
		if DEBUG_COMBATLOGS:
			print(playerName," died!\n")
	
	await get_tree().process_frame
	can_move = true;

#combat method for ranged enemys
func ranged_enemy_combat(player, enemy):
	#lock player
	can_move = false
	#grab some information about combatants
	var playerName = player.player_name
	var enemyName = enemy.name
	#take combatant strength - opponent defense as damage, floor player to 1 and enemies to 0 damage to favor player some.
	var enemyDamage = max(enemy.strength - player.armor, 1)
	
	if DEBUG_COMBATLOGS:
		print("-----Initiating combat between ",playerName," and ",enemyName,"!-----")
	
	#Roll combat
	var enemyHitChance = calculate_hit_chance(enemy.strength,player.armor)
	var enemyRoll = randf()
	if DEBUG_COMBATLOGS:
		print(enemyName," needs less than <",enemyHitChance,"> to hit, rolled a <",snapped(enemyRoll,0.01),">.")
	if enemyRoll <= enemyHitChance:
		damage_player_signal.emit(enemyDamage)
		var attackTween = animate_attack(enemy, player)
		await attackTween.finished
		if DEBUG_COMBATLOGS:
			print(enemyName," dealt ",enemyDamage," damage to ",playerName,". ",playerName," has ",player.health," health left.")
	else:
		var missTween = animate_miss(enemy)
		await missTween.finished
		if DEBUG_COMBATLOGS:
			print(enemyName," missed ",playerName,"!")
	
	#if player dies, game over.
	if player.health <= 0:
		var deathTween = animate_death(player)
		await deathTween.finished
		if DEBUG_COMBATLOGS:
			print(playerName," died!\n")
	await get_tree().process_frame
	can_move = true;

#calculate chance to hit based on difference between attack and armor
func calculate_hit_chance(attack, defense):
	var baseHit = 0.90
	var minHit = 0.40
	var diff = attack - defense
	#penalty is applied if diff < 0
	#for example, if the player has 3 defense vs a skeleton with 1 attack
	#diff = -2, penalty = 0.20, chance to hit = 0.70
	var penalty = 0.10 * max(-diff,0)
	#clamp penalty to minHit value so there's always a chance to hit something. penalty range is between 0.0 - 0.5.
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
		if is_instance_valid(attacker):
			attacker.set_deferred("position", originPos.snapped(Vector2.ONE * -distance))
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
		if is_instance_valid(attacker):
			attacker.set_deferred("position", originPos.snapped(Vector2.ONE * -8))
	)
	return tween

func animate_death(target) -> Tween:
	if not is_instance_valid(target):
		return get_tree().create_tween()
		
	var tween = get_tree().create_tween()
	
	tween.tween_property(target, "modulate", Color.RED, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "scale", Vector2(), animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	return tween
