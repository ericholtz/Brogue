extends CharacterBody2D
#extends Node2D

#onready vars to reference other nodes and manipulate their values
@onready var PlayerAnim = $AnimatedSprite2D
@onready var Ray = $RayCast2D
@onready var collision = $CollisionShape2D

var noclip_enabled = false
var godmode_enabled = false

var animationSpeed = 18 #tweening speed
var moving = false #keeps us from glitching out movement

@onready var inventoryNode : Node2D = $"Inventory"
var inventory : Array[String] = []
@export var gold = 0

var baseStrength = 1
var baseDefense = 1

var player_name = ""
var health = 10
var strength = baseStrength
var defense = baseDefense

var tileSize = 16
var moveTimer = 0.0  #timer used to count down movement delay
var moveDelay = 0.1  #movement delay in seconds
#dict map of input strings to directional vectors
var inputs = {"Up": Vector2.UP,
			"Left": Vector2.LEFT,
			"Right": Vector2.RIGHT,
			"Down": Vector2.DOWN,
			"Space": Vector2.ZERO}

enum EntityType {GOLD, MELEE_WEAPON, ARMOR, POTION, MISC}

func _ready():
	# position and animation
	position = position.snapped(Vector2.ONE * tileSize)
	position += Vector2.ONE * tileSize/2
	PlayerAnim.play("Idle")
	
	# connect to gained_gold and gained_item signals
	GameMaster.gained_gold.connect(_on_gold_gain.bind())
	GameMaster.gained_item.connect(_on_item_gain.bind())
	GameMaster.set_name.connect(_on_name_recieved.bind())
	GameMaster.damage_player_signal.connect(_on_damage_received.bind())
	GameMaster.heal_player_signal.connect(_on_heal_received.bind())
	

#Called every frame to handle continuous input
func _process(delta):
	
	var hasMoved = false
	#if we're already tweening movement, don't move again
	if not GameMaster.can_move or moving:
		moveTimer = 0.0
		return
	
	#decrease timer by delta every frame
	moveTimer -= delta
	
	#flip sprite based on input direction
	if Input.is_action_pressed("Left"):
		PlayerAnim.flip_h = true
	if Input.is_action_pressed("Right"):
		PlayerAnim.flip_h = false
	
	#if input is JUST pressed, bypass movement delay and move immediately
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir) and not hasMoved:
			if await move(dir):
				GameMaster.takeTurn(1)
			#reset movement timer on succesful move
			moveTimer = moveDelay
			hasMoved = true
			return
			
	#if movement timer has elapsed and key is held, loop turns
	if moveTimer <= 0:
		for dir in inputs.keys():
			if Input.is_action_pressed(dir) and not hasMoved:
				if await move(dir):
					GameMaster.takeTurn(1)
				#set movement timer to automove delay in this case
				moveTimer = moveDelay
				hasMoved = true
				return

func move(dir) -> bool:
	
	if noclip_enabled:
		# Move freely without collision checks
		position += inputs[dir] * tileSize
		moveTimer = moveDelay
		return true

	#set ray to move direction +16 pixels
	Ray.target_position = inputs[dir] * tileSize
	#update instantly
	Ray.force_raycast_update()
	
	#if ray is colliding with a wall, we can't move there
	if !Ray.is_colliding():
		#create a new Tween object to handle smooth movement
		var tween = create_tween()
		#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
		tween.tween_property(self, "position", position + inputs[dir] * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
		#set this flag to true until tween is finished to disallow multiple moves at once
		moving = true
		await tween.finished
		moving = false
		#emit a movement signal here, after the player succesfully moves
		emit_signal("input_event")
		moveTimer = moveDelay
		return true
	moveTimer = moveDelay
	return false

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
		itemRoot.reparent(inventoryNode)
		itemRoot.visible = false
		print("Added ", itemName, " to inventory. Current inventory is:")
		print(inventory)
		
		if (item.type == EntityType.MELEE_WEAPON):
			strength = baseStrength + itemRoot.find_child("MeleeWeaponStats").attack
			print("Now wielding ", itemName, ". strength = ", strength)
		if (item.type == EntityType.ARMOR):
			defense = baseDefense + itemRoot.find_child("ArmorStats").defense
			print("Now wearing ", itemName, ". defense = ", defense)
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
	print("Player took ", amount, " damage. New health:", health)

func _on_heal_received(amount: int):
	if health < 15:
		health += amount
	print("Player healed ", amount, " points. New health:", health)

func no_clip():
	noclip_enabled = !noclip_enabled
	collision.disabled = !collision.disabled
	$RayCast2D.enabled = !$RayCast2D.enabled

func god_mode():
	godmode_enabled = !godmode_enabled
