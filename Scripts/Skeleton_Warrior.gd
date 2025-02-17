extends CharacterBody2D

@onready var Animations = $AnimatedSprite2D
@onready var Ray = $RayCast2D

#@onready var monster = "Skeleton Warrior/Area2D"
#@onready var player = "Player"

var animationSpeed = 18 #Used what player was
var moving = false
var player = null

#I dont use this! But When doing item it might be nice
var gold = 0

#Monsters States
var Health = 10
var Str = 2
var Def = 1
var Movement_Speed = 1

var tileSize = 16

#Just for testing
var inputs = {"Up": Vector2.UP,
			"Left": Vector2.LEFT,
			"Right": Vector2.RIGHT,
			"Down": Vector2.DOWN}

func _ready():
	# position and animation
	position = position.snapped(Vector2.ONE * tileSize)
	position += Vector2.ONE * tileSize/2
	Animations.play("")

func _input(event):
	var try_move = Vector2.ZERO
	var rand_move = Vector2.ZERO
	if not GameMaster.can_move or moving:
		#if we're already tweening movement, don't move again
		return
		
	
	#var rng = RandomNumberGenerator.new()
	#var my_random_number = rng.randf_range(1, 4)
	#var dir = Input.get_vector("Left", "Right", "Up", "Down")
	
	#for dir in inputs.keys():
		#if event.is_action_pressed("Left"):
			#Animations.flip_h = true
			##This Makes enemy face correct direction
		#if event.is_action_pressed("Right"):
			#Animations.flip_h = false
			##This Makes enemy face correct direction
		#if event.is_action_pressed(dir):
			#move(dir)
	
	# move enemy in direction of the player if within area
	if player:
		try_move = vec_to_cardinal(position.direction_to(player.position))
		print(try_move)
	# move in random direction on turn
	#else:
		#try_move = vec_to_cardinal(position.direction_to(rand_move))
	move(try_move)


#func move_monster_towards_player(monster: Area2D, player: Area2D) -> void:
	#var step_size := 16
	#var monster_pos := monster.global_position
	#var player_pos := player.global_position

	#var dx := player_pos.x - monster_pos.x
	#var dy := player_pos.y - monster_pos.y

	#if abs(dx) > abs(dy):
		# Move horizontally
		#monster.global_position.x += step_size if dx > 0 else -step_size
	#else:
		# Move vertically
		#monster.global_position.y += step_size if dy > 0 else -step_size
	


func move(dir):
	
	#var min_val = 1
	#var max_val = 4
	#var rng = RandomNumberGenerator.new()
	#var ran_num = rng.randi_range(min_val, max_val)
	#var dir = str(ran_num)
	
	Ray.target_position = dir * tileSize	#set ray to move direction +16 pixels
	Ray.force_raycast_update()
	if !Ray.is_colliding(): #if ray is colliding with a wall, we can't move there
		var tween = create_tween() #create a new Tween object to handle smooth movement
		#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
		tween.tween_property(self, "position", position + dir * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
		moving = true #set this to true until tween is finished to disallow multiple moves at once
		await tween.finished
		moving = false
		emit_signal("input_event") #emit a movement signal here, after the player succesfully moves


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		print("player in area")


func _on_area_2d_body_exited(body: Node2D) -> void:
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
