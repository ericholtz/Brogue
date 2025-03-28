extends CharacterBody2D

@onready var Animations = $AnimatedSprite2D
@onready var Ray = $RayCast2D

var entity_name = "Skeleton Warrior"
var entity_type = "monster"

var animationSpeed = 18 #Used what player was
var moving = false
var player = null

#I dont use this! But When doing item it might be nice
var gold = 5

#Monsters States
var health = 10
var strength = 1
var defense = 2
var Movement_Speed = 1
var xp = 10

var tileSize = 16

#Just for testing
var inputs = {"Up": Vector2.UP,
			"Left": Vector2.LEFT,
			"Right": Vector2.RIGHT,
			"Down": Vector2.DOWN}

func _ready():
	# position and animation
	add_to_group("enemies")
	name = "Skeleton"
	Animations.play("")

func take_turn():
	if moving:
		return
	
	var try_move = Vector2.ZERO
	if player:
		try_move = vec_to_cardinal(position.direction_to(player.position))
	if try_move == Vector2.ZERO:  # Skip if no movement is needed
		return
	if await move(try_move):
		await get_tree().process_frame



func move(dir) -> bool:
	
	#var min_val = 1
	#var max_val = 4
	#var rng = RandomNumberGenerator.new()
	#var ran_num = rng.randi_range(min_val, max_val)
	#var dir = str(ran_num)
	
	Ray.target_position = dir * tileSize	#set ray to move direction +16 pixels
	Ray.force_raycast_update()
	if Ray.is_colliding(): #if ray is colliding with a wall, we can't move there
		var collider = Ray.get_collider()
		if collider.is_in_group("Player"):
				GameMaster.combat(collider, self)
				return false
		else:
				return false
	else:
		var tween = create_tween() #create a new Tween object to handle smooth movement
		#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
		tween.tween_property(self, "position", position + dir * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
		moving = true #set this to true until tween is finished to disallow multiple moves at once
		await tween.finished
		moving = false
		emit_signal("input_event") #emit a movement signal here, after the player succesfully moves
		return true #flag for movement happening

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		print("player in area")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		print("player exited area")
	
func vec_to_cardinal(vec: Vector2) -> Vector2:
	if vec == Vector2.ZERO:
		return Vector2.ZERO
	
	vec = vec.normalized()  # Ensure the vector is a unit vector
	var ass = abs(vec.aspect())  # Calculate the aspect ratio
	var res = vec.sign()  # Get the sign of x and y
	# If the aspect ratio indicates a clear horizontal or vertical direction
	if ass < 0.557852 or ass > 1.79259:
		res[int(ass > 1.0)] = 0
	else:
		# If diagonal, randomly select one of the two closest cardinal directions
		if randi() % 2 == 0:
			res.x = 0
		else:
			res.y = 0
	
	return res
