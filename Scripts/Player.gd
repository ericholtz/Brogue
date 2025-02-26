extends CharacterBody2D
#extends Node2D

#onready vars to reference other nodes and manipulate their values
@onready var PlayerAnim = $AnimatedSprite2D
@onready var Ray = $RayCast2D
@onready var collision = $CollisionShape2D

#debug flags
var noclip_enabled = false
var godmode_enabled = false

#inventory and gold
@onready var inventoryNode : Node2D = $"Inventory"
var inventory : Array[String] = []
@export var gold = 0
enum EntityType {GOLD, MELEE_WEAPON, ARMOR, POTION, MISC}

#base player stats to be affected by levels/potions
var player_name = ""
var health = 10
var level = 1
var currentXP = 0
var XPtoNext = 10
var XPNeeded = XPtoNext - currentXP
var strength = 1
var defense = 1

#variable player stats to be affected by equipment
var attack = strength
var armor = defense

#movement related variables
var tileSize = 16
var moveTimer = 0.0  #timer used to count down movement delay
var moveDelay = 0.15  #movement delay in seconds
var animationSpeed = 18 #tweening speed

#this controls movement and combat flow.
#TRUE if the player is locked into an action. Moving/in combat/looting/whatever
#FALSE if the player is between turns, before input.
var moving = false


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
		PlayerAnim.flip_h = true
	if Input.is_action_pressed("Right"):
		PlayerAnim.flip_h = false
	
	#process input, both presses and holds
	for dir in inputs.keys():
		#if button is just pressed OR if timer has elapsed and button is held
		if Input.is_action_just_pressed(dir) or (moveTimer <= 0 and Input.is_action_pressed(dir)):
			if moving:
				return
			moving = true
			#await everything before we can move again
			if await move(dir):
				await GameMaster.takeTurn(1)
			#reset movement timer on succesful move
			moving = false
			moveTimer = moveDelay
			return

#function to try a move, returns TRUE on succesfull move and FALSE on invalid
func move(dir) -> bool:
	if noclip_enabled:
		# Move freely without collision checks
		position += inputs[dir] * tileSize
		moveTimer = moveDelay
		return true

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
				return true
		return false
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
	return true

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
		strength += 1
		defense += 1

func animate_level_up():
	var originColor = self.modulate
	var animSpeed = 0.1
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.GOLD, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", originColor, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func end_game():
	GameMaster.can_move = false
	var game_over = preload("res://Scenes/Menus/game_over.tscn").instantiate()
	$"..".add_child(game_over)

func _on_gold_gain(gold_worth: int):
	# increase gold counter
	gold += gold_worth
	print("collected gold, increasing gold by ", gold_worth, "; total gold = ", gold)

func _on_item_gain(itemRoot : Area2D):
	# get item info
	var item = itemRoot.get_child(0)
	var itemName = item.name
	
	# add to inventory
	if itemName not in inventory:
		inventory.append(itemName)
		itemRoot.call_deferred("reparent", inventoryNode)
		itemRoot.visible = false
		print("Added ", itemName, " to inventory. Current inventory is:")
		print(inventory)
		
		if (item.type == EntityType.MELEE_WEAPON):
			attack = strength + itemRoot.find_child("MeleeWeaponStats").attack
			print("Now wielding ", itemName, ". attack = ", attack)
		if (item.type == EntityType.ARMOR):
			armor = defense + itemRoot.find_child("ArmorStats").armor
			print("Now wearing ", itemName, ". armor = ", armor)
	else:
		print("Already have one ", itemName, ", cannot pick up more")

func _on_name_recieved(p_name: String):
	player_name = p_name
	var stat_node = preload("res://Scenes/Menus/player_stats.tscn").instantiate()
	$"..".add_child(stat_node)
	
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
	if health < 15:
		health += amount
	#print("Player healed ", amount, " points. New health:", health)

func no_clip():
	noclip_enabled = !noclip_enabled
	collision.disabled = !collision.disabled
	$RayCast2D.enabled = !$RayCast2D.enabled

func god_mode():
	godmode_enabled = !godmode_enabled
