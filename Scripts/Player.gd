extends CharacterBody2D
#extends Node2D

#onready vars to reference other nodes and manipulate their values
@onready var PlayerAnim = $AnimatedSprite2D
@onready var Ray = $RayCast2D
@onready var collision = $CollisionShape2D
@onready var Camera = $Camera2D

#debug flags
@export var noclip_enabled = false
@export var godmode_enabled = false

#inventory and gold
@onready var inventory_node: Node2D = $Inventory
@export var inventory: Array[String] = []
@export var known_items = {}
@export var gold = 0

# Turn on/off item debug statments
@export var DEBUG_ITEM = false

#base player stats to be affected by levels/potions
@export var player_name = ""
@export var health = 10
@export var MAX_HEALTH = 10
@export var level = 1
@export var currentXP = 0
var XPtoNext = 10
var XPNeeded = XPtoNext - currentXP
@export var strength = 1
@export var defense = 1
@export var movement_speed = 1
@export var moves_left = 1
@export var base_zoom = 3
@export var entity_size = Vector2i(1, 1)

#variable player stats to be affected by equipment
@export var attack = strength
@export var armor = defense

# status effects
## potion effects
@export var is_invisible = false
@export var is_psychedelic = false
@export var is_poisoned = false
@export var is_speedy = false
@export var is_blind = false
const INVISIBILITY_LENGTH = 20
const PSYCHEDELIC_LENGTH = 40
const POISON_LENGTH = 10
const SPEED_LENGTH = 20
const BLIND_LENGTH = 40
## scroll effects
@export var is_stat_boosted = false
const STAT_BOOST_LENGTH = 15
@export var stats_before_stat_boost = []

## effects from enemies
@export var is_frozen = false # doesn't do anything, just an example - remove if needed

## other player effects
@export var is_standing_on_exit = false

#movement related variables
var tileSize = 16
var moveTimer = 0.0  #timer used to count down movement delay
@export var moveDelay = 0.15  #movement delay in seconds
@export var animationSpeed = 18 #tweening speed

#this controls movement and combat flow.
#TRUE if the player is locked into an action. Moving/in combat/looting/whatever
#FALSE if the player is between turns, before input.
@export var moving = false


#dict map of input strings to directional vectors
var inputs = {"Up": Vector2.UP,
			"Left": Vector2.LEFT,
			"Right": Vector2.RIGHT,
			"Down": Vector2.DOWN,
			"Space": Vector2.ZERO}

#run as soon as the player enters the scene
func _ready():
	#set position and start animation
	position = position.snapped(Vector2.ONE * tileSize)
	position += Vector2.ONE * tileSize/2
	PlayerAnim.play("Idle")
	add_to_group("Player")
	
	#connect to signals
	GameMaster.gained_gold.connect(_on_gold_gain.bind())
	GameMaster.gained_item.connect(_on_item_gain.bind())
	GameMaster.set_name.connect(_on_name_recieved.bind())
	GameMaster.damage_player_signal.connect(_on_damage_received.bind())
	GameMaster.heal_player_signal.connect(_on_heal_received.bind())
	GameMaster.end_status_effect_signal.connect(_on_remove_status_effect.bind())
	

#Called every frame to handle continuous input
func _process(delta):
	#if we're already tweening movement, don't move again
	if moving or not GameMaster.can_move:
		moveTimer = 0.0
		return
	
	#decrease timer by delta every frame
	moveTimer -= delta
	
	#flip sprite based on input direction
	if Input.is_action_pressed("Left"):
		PlayerAnim.flip_h = !is_psychedelic
	if Input.is_action_pressed("Right"):
		PlayerAnim.flip_h = is_psychedelic
	
	#process input, both presses and holds
	for dir in inputs.keys():
		#if button is just pressed OR if timer has elapsed and button is held
		if Input.is_action_just_pressed(dir) or (moveTimer <= 0 and Input.is_action_pressed(dir)):
			if moving or movement_speed == 0:
				return
			moving = true
			#await everything before we can move again
			if await move(dir) == 2:
				moves_left = 0
			#reset movement timer on succesful move
			moving = false
			moveTimer = moveDelay
	
			if moves_left > 0:
				moves_left -= 1
			if moves_left == 0:
				moves_left = movement_speed
				await GameMaster.takeTurn(1)
	
	# TODO: add organize_inventory() function to organize the ivnentory and reunite orphaned stackables

# function to try a move, returns 0 on invalid movement, 1 on valid movement, and 2 on attack
func move(dir) -> int:
	if noclip_enabled:
		# Move freely without collision checks
		position += inputs[dir] * tileSize
		moveTimer = moveDelay
		return 1

	#set ray to move direction +16 pixels, update immediately
	Ray.target_position = inputs[dir] * tileSize
	Ray.force_raycast_update()
	
	#check if ray is colliding with wall/enemy
	#return true for valid turn, false for invalid turn
	#if collider is an enemy, initiate combat via GameMaster
	if Ray.is_colliding():
		var collider = Ray.get_collider()
		if collider.is_in_group("enemies"):
			if Input.is_action_just_pressed(dir):
				await GameMaster.combat(self, collider)
				return 2
		return 0
	#create a new Tween object to handle smooth movement
	var tween = create_tween()
	#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
	var target_pos = (position + inputs[dir] * tileSize).snapped(Vector2.ONE * tileSize/2)  # Snap target
	tween.tween_property(self, "position", target_pos, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
	#set this flag to true until tween is finished to disallow multiple moves at once
	await tween.finished
	#just snap back to tile position
	position = position.snapped(Vector2.ONE * tileSize/2)
	#emit a movement signal here, after the player succesfully moves
	emit_signal("input_event")
	return 1

func add_xp(amount: int):
	currentXP += amount
	if currentXP >= XPtoNext:
		gain_level()

func gain_level():
	while currentXP >= XPtoNext:
		print("+++++Gained a level!+++++")
		animate_level_up()
		currentXP -= XPtoNext
		level += 1
		XPtoNext = 10 * (level ** 2)
		MAX_HEALTH = MAX_HEALTH + 5
		health = MAX_HEALTH
		strength += 1
		defense += 1
		attack += 1
		armor += 1

func animate_level_up():
	var originColor = self.modulate
	var animSpeed = 0.1

	$LevelUpParticles2D.emitting = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.GOLD, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", originColor, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func animate_become_invisible():
	$BecomeInvisibleParticles2D.emitting = true

func end_game():
	GameMaster.can_move = false
	var game_over = preload("res://Scenes/Menus/game_over.tscn").instantiate()
	$"..".add_child(game_over)

func _on_gold_gain(gold_worth: int):
	# increase gold counter
	gold += gold_worth
	print("collected gold, increasing gold by ", gold_worth, "; total gold = ", gold)

func _on_item_gain(item : Area2D):
	var index = inventory.find(item.entity_name)
	# add unique new item
	if (index == -1):
		await get_tree().process_frame
		item.can_pickup = false
		item.reparent(inventory_node)
		#await item.call_deferred("reparent", inventory_node)
		inventory.append(item.entity_name)
		item.visible = false
		if (DEBUG_ITEM):
			print("Added ", item.entity_name, " to inventory. Current inventory is:")
			print(inventory)
	# increase existing stackable item count
	elif (index != -1 and item.stackable):
		var existing_item = inventory_node.get_child(index)
		existing_item.count += 1
		item.queue_free()
		if (DEBUG_ITEM):
			print("Increased stack count of ", existing_item.entity_name, " to ", existing_item.count, ". Current inventory is:")
			print(inventory)

func _on_name_recieved(p_name: String):
	player_name = p_name
	var stat_node = preload("res://Scenes/Menus/player_stats.tscn").instantiate()
	get_parent().add_child(stat_node)
	
func _on_damage_received(amount: int):
	if godmode_enabled:
		health = 10
		return
	if health > 0:
		health -= amount
		if health <= 0:
			end_game()
	#print("Player took ", amount, " damage. New health:", health)

func _on_heal_received(amount: int):
	if health < MAX_HEALTH:
		$HealParticles2D.emitting = true
		health = min(MAX_HEALTH, health+amount)
	#print("Player healed ", amount, " points. New health:", health)

func use(item_index: int):
	# check bounds
	if item_index < 0 or item_index >= inventory_node.get_child_count():
		return
	
	identify(item_index)
	# apply item effect
	var item = inventory_node.get_child(item_index)
	var key_used = false
	match item.item_type:
		GameMaster.ItemType.MELEE_WEAPON:
			attack = strength + item.attack
		GameMaster.ItemType.ARMOR:
			armor = defense + item.armor
		GameMaster.ItemType.POTION:
			use_potion(item)
		GameMaster.ItemType.SCROLL:
			use_scroll(item)
		GameMaster.ItemType.MISC:
			key_used = use_misc(item)
			
	# decrement count if consumable - if 0, remove from inventory
	if item.consumable:
		item.count -= 1
		if item.count == 0:
			inventory.erase(item.entity_name)
			item.free()
	# consume key if needed
	if key_used:
		inventory.erase(item.entity_name)
		item.free()

func use_potion(potion: Area2D):
	match potion.effect:
		GameMaster.PotionEffect.HEALING:
			use_healing_potion()
		GameMaster.PotionEffect.SPEED:
			use_speed_potion()
		GameMaster.PotionEffect.POISON:
			use_poison_potion()
		GameMaster.PotionEffect.PSYCHEDELIC:
			use_psychedelic_potion()
		GameMaster.PotionEffect.INVISIBILITY:
			use_invisibility_potion()

func use_healing_potion():
	var heal_amount = ceil(float(MAX_HEALTH)/4)
	GameMaster.heal_player_signal.emit(heal_amount)

func use_speed_potion():
	if not is_speedy:
		is_speedy = true
		add_speed(1)
	GameMaster.start_status_effect(GameMaster.StatusEffect.SPEEDY, SPEED_LENGTH)

func use_poison_potion():
	is_poisoned = true
	PlayerAnim.play("Poisoned")
	GameMaster.start_status_effect(GameMaster.StatusEffect.POISONED, POISON_LENGTH)

func use_psychedelic_potion():
	is_psychedelic = true
	PlayerAnim.flip_v = true
	GameMaster.start_status_effect(GameMaster.StatusEffect.PSYCHEDELIC, PSYCHEDELIC_LENGTH)
	Camera.find_child('ScreenEffects').find_child('Invert').visible = true

func use_invisibility_potion():
	is_invisible = true
	PlayerAnim.play("Invisible")
	GameMaster.start_status_effect(GameMaster.StatusEffect.INVISIBLE, INVISIBILITY_LENGTH)
	animate_become_invisible()
	#TODO: add duration scaling

func _on_remove_status_effect(effect: GameMaster.StatusEffect):
	match effect:
		GameMaster.StatusEffect.SPEEDY:
			remove_speed_effect()
		GameMaster.StatusEffect.POISONED:
			remove_poison_effect()
		GameMaster.StatusEffect.PSYCHEDELIC:
			remove_psychedelic_effect()
		GameMaster.StatusEffect.INVISIBLE:
			remove_invisibility_effect()
		GameMaster.StatusEffect.STAT_BOOSTED:
			remove_stat_boost()
		GameMaster.StatusEffect.BLIND:
			remove_blind()

func remove_speed_effect():
	is_speedy = false
	remove_speed(1)

func remove_poison_effect():
	is_poisoned = false
	PlayerAnim.play("Idle")

func remove_psychedelic_effect():
	is_psychedelic = false
	PlayerAnim.flip_v = false
	Camera.find_child('ScreenEffects').find_child('Invert').visible = false

func remove_invisibility_effect():
	is_invisible = false
	PlayerAnim.play("Idle")

func remove_stat_boost():
	attack = stats_before_stat_boost[0]
	armor = stats_before_stat_boost[1]
	is_stat_boosted = false
	PlayerAnim.play("Idle")

func remove_blind():
	zoom(base_zoom)
	is_blind = false
	Camera.find_child('ScreenEffects').find_child('Darken').visible = false

func use_scroll(scroll: Area2D):
	match scroll.effect:
		GameMaster.ScrollEffect.RANDOM_TP:
			random_tp()
		GameMaster.ScrollEffect.BLIND:
			use_blind_scroll()
		GameMaster.ScrollEffect.IDENTIFY:
			use_identify_scroll()
		GameMaster.ScrollEffect.GOLD_RUSH:
			use_gold_rush_scroll()
		GameMaster.ScrollEffect.STAT_BOOST:
			use_stat_boost_scroll()

func random_tp():
	$"../map_gen".place_entity_in_random_room(self)

func use_blind_scroll():
	zoom(1)
	is_blind = true
	GameMaster.start_status_effect(GameMaster.StatusEffect.BLIND, BLIND_LENGTH)
	Camera.find_child('ScreenEffects').find_child('Darken').visible = true

func use_identify_scroll():
	$"../PlayerStats".show_identify()

func use_gold_rush_scroll():
	for i in range(0, randi_range(6, 9)):
		$"../map_gen".force_spawn(position, "gold", 0)
	for i in range(0, randi_range(3, 5)):
		$"../map_gen".force_spawn(position, "gold", 1)
	for i in range(0, randi_range(2, 4)):
		$"../map_gen".force_spawn(position, "gold", 2)

func use_stat_boost_scroll():
	if not is_stat_boosted:
		is_stat_boosted = true
		stats_before_stat_boost = [attack, armor]
		attack = int(ceil(1.3 * attack))
		armor = int(ceil(1.3 * armor))
	PlayerAnim.play("StatBoosted")
	GameMaster.start_status_effect(GameMaster.StatusEffect.STAT_BOOSTED, INVISIBILITY_LENGTH)

func use_misc(misc: Area2D) -> bool:
	match misc.misc_type:
		GameMaster.MiscType.MAP:
			use_map(misc)
			return false
		GameMaster.MiscType.KEY:
			return use_key(misc)
		_:
			return false

func use_map(map: Area2D):
	var current_level = $"../map_gen".level
	if map.map_level == current_level:
		base_zoom += 1
		zoom(base_zoom)
		GameMaster.DISABLE_FOG = true
	else:
		print("This map was meant for level ", map.map_level, ", so it's useless on level ", current_level, ".")

func use_key(key: Area2D) -> bool:
	if is_standing_on_exit:
		# call function to start new level
		get_node("/root/World/map_gen").regenerate_map()
		return true
	else:
		print("Cannot use key now.")
		return false

func add_speed(speed: int):
	movement_speed += speed
	moves_left += speed

func remove_speed(speed: int):
	movement_speed -= speed
	moves_left -= speed

func identify(item_index: int):
	var item = inventory_node.get_child(item_index)
	match item.item_type:
		GameMaster.ItemType.MELEE_WEAPON:
			known_items[item.entity_name] = "[+%s Attack] %s" % [item.attack, item.entity_name]
		GameMaster.ItemType.ARMOR:
			known_items[item.entity_name] = "[+%s Armor] %s" % [item.armor, item.entity_name]
		GameMaster.ItemType.POTION:
			if item.entity_name not in known_items:
				match item.effect:
					GameMaster.PotionEffect.HEALING:
						known_items[item.entity_name] = "Healing Potion"
					GameMaster.PotionEffect.SPEED:
						known_items[item.entity_name] = "Speed Potion"
					GameMaster.PotionEffect.POISON:
						known_items[item.entity_name] = "Poison Potion"
					GameMaster.PotionEffect.PSYCHEDELIC:
						known_items[item.entity_name] = "Psychedelic Potion"
					GameMaster.PotionEffect.INVISIBILITY:
						known_items[item.entity_name] = "Invisibility Potion"
		GameMaster.ItemType.SCROLL:
			if item.entity_name not in known_items:
				match item.effect:
					GameMaster.ScrollEffect.RANDOM_TP:
						known_items[item.entity_name] = "Scroll of Teleportation"
					GameMaster.ScrollEffect.BLIND:
						known_items[item.entity_name] = "Scroll of Darkness"
					GameMaster.ScrollEffect.IDENTIFY:
						known_items[item.entity_name] = "Scroll of Identify"
					GameMaster.ScrollEffect.GOLD_RUSH:
						known_items[item.entity_name] = "Scroll of Wealth"
					GameMaster.ScrollEffect.STAT_BOOST:
						known_items[item.entity_name] = "Scroll of Power"
		_:
			return

func identify_all():
	for i in range(0, inventory.size()):
		identify(i)

func known(item_name: String) -> String:
	if item_name in known_items:
		return known_items[item_name]
	else:
		return item_name

func drop(item_index: int):
	pass

func zoom(zoom_level: int):
	var zoom_levels = [
		Vector2(17, 17),
		Vector2(11.2, 11.2),
		Vector2(3, 3),
		Vector2(2, 2),
		Vector2(1, 1),
	]
	if zoom_level > zoom_levels.size():
		zoom_level = 5
	Camera.zoom = zoom_levels[zoom_level - 1]

func zoom_raw(zoom_level: float):
	Camera.zoom = Vector2(zoom_level, zoom_level)

func no_clip():
	noclip_enabled = !noclip_enabled
	collision.disabled = !collision.disabled
	$RayCast2D.enabled = !$RayCast2D.enabled

func god_mode():
	godmode_enabled = !godmode_enabled
