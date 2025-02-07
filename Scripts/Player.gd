extends Area2D

#onready vars to reference other nodes and manipulate their values
@onready var PlayerAnim = $AnimatedSprite2D
@onready var Ray = $RayCast2D

var animationSpeed = 18 #tweening speed
var moving = false #keeps us from glitching out movement

var items = []
@export var gold = 0

var player_name = ""
var health = 10
var strength = 1
var defense = 1

var tileSize = 16
var inputs = {"Up": Vector2.UP,
			"Left": Vector2.LEFT,
			"Right": Vector2.RIGHT,
			"Down": Vector2.DOWN}

func _ready():
	# position and animation
	position = position.snapped(Vector2.ONE * tileSize)
	position += Vector2.ONE * tileSize/2
	PlayerAnim.play("Idle")
	
	# connect to gained_gold and gained_item signals
	GameMaster.gained_gold.connect(_on_gold_gain.bind())
	GameMaster.gained_item.connect(_on_item_gain.bind())
	GameMaster.set_name.connect(_on_name_recieved.bind())

func _input(event):
	if not GameMaster.can_move or moving:
		#if we're already tweening movement, don't move again
		return
	for dir in inputs.keys():
		if event.is_action_pressed("Left"):
			PlayerAnim.flip_h = true
		if event.is_action_pressed("Right"):
			PlayerAnim.flip_h = false
		if event.is_action_pressed(dir):
			move(dir)
			GameMaster.takeTurn(1)

func move(dir):
	Ray.target_position = inputs[dir] * tileSize	#set ray to move direction +16 pixels
	Ray.force_raycast_update()
	if !Ray.is_colliding(): #if ray is colliding with a wall, we can't move there
		var tween = create_tween() #create a new Tween object to handle smooth movement
		#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
		tween.tween_property(self, "position", position + inputs[dir] * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
		moving = true #set this to true until tween is finished to disallow multiple moves at once
		await tween.finished
		moving = false
		emit_signal("input_event") #emit a movement signal here, after the player succesfully moves

func _on_gold_gain(gold_count: int):
	# increase gold counter
	gold += gold_count
	print("collected gold, increasing gold by ", gold_count, "; total gold = ", gold)

func _on_item_gain(item_gained: String):
	# add to list
	items.append(item_gained)
	
	# modify stats
	match item_gained:
		"MetalSword":
			print("collected MetalSword, increasing strength by one")
			strength += 1

func _on_name_recieved(p_name: String):
	player_name = p_name
	
