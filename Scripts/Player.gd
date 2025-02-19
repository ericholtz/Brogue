extends CharacterBody2D
#extends Node2D

#onready vars to reference other nodes and manipulate their values
@onready var PlayerAnim = $AnimatedSprite2D
@onready var Ray = $RayCast2D

var animationSpeed = 18 #tweening speed
var moving = false #keeps us from glitching out movement

var inventory = []
@export var gold = 0

var player_name = ""
var health = 10
var strength = 1
var defense = 1

var tileSize = 16
var moveTimer = 0.0  #timer used to count down movement delay
var moveDelay = 0.1  #movement delay in seconds
#dict map of input strings to directional vectors
var inputs = {"Up": Vector2.UP,
			"Left": Vector2.LEFT,
			"Right": Vector2.RIGHT,
			"Down": Vector2.DOWN,
			"Space": Vector2.ZERO}

func _ready():
	# position and animation
	position = position.snapped(Vector2.ONE * tileSize)
	position += Vector2.ONE * tileSize/2
	PlayerAnim.play("Idle")
	add_to_group("Player")
	
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
	#set ray to move direction +16 pixels
	Ray.target_position = inputs[dir] * tileSize
	#update instantly
	Ray.force_raycast_update()
	
	#if ray is colliding with a wall, we can't move there
	if Ray.is_colliding():
		var collider = Ray.get_collider()
		if collider.is_in_group("enemies"):
			GameMaster.damage_player(collider.Str)
			return false
	else:
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

func _on_gold_gain(gold_count: int):
	# increase gold counter
	gold += gold_count
	print("collected gold, increasing gold by ", gold_count, "; total gold = ", gold)

func _on_item_gain(item_gained: String):
	# add to list
	inventory.append(item_gained)
	
	# modify stats
	match item_gained:
		# Weapons
		"GoldSword":
			print("collected GoldSword, increasing strength by 1")
			strength += 1
		"MetalSword":
			print("collected MetalSword, increasing strength by 4")
			strength += 4
		"MetalHammer":
			print("collected MetalHammer, increasing strength by 2")
			strength += 2
		"MetalBattleaxe":
			print("collected MetalBattleaxe, increasing strength by 2")
			strength += 3
		
		# Armor
		"LeatherArmor":
			print("collected LeatherArmor, increasing defense by 1")
			strength += 1
		"ChainArmor":
			print("collected ChainArmor, increasing defense by 3")
			strength += 3
		
		# Potions
		"BluePotion": print("collected BluePotion, adding to inventory")
		"GreenPotion": print("collected GreenPotion, adding to inventory")
		"OrangePotion": print("collected OrangePotion, adding to inventory")
		"PurplePotion": print("collected PurplePotion, adding to inventory")
		"RedPotion": print("collected RedPotion, adding to inventory")
		
		# Misc
		"MetalKey": print("collected MetalKey, adding to inventory")

func _on_name_recieved(p_name: String):
	player_name = p_name
	
func _on_damage_received(amount: int):
	if health > 0:
		health -= amount
	print("Player took ", amount, " damage. New health:", health)

func _on_heal_received(amount: int):
	if health < 15:
		health += amount
	print("Player healed ", amount, " points. New health:", health)
