extends CharacterBody2D

@onready var Animations = $AnimatedSprite2D
@onready var Ray = $RayCast2D

var entity_name = "Bat"
var entity_size = Vector2i(1,1)

@export var entity_type: GameMaster.EntityType

# Basic Used
var animationSpeed = 18
var moving = false
var player = null
var tileSize = 16

#Monsters States
var health = 3
var strength = 3
var defense = 0
var Movement_Speed = 2
var xp = 10

func _ready():
	# position and animation
	add_to_group("enemies")
	name = "Bat"
	Animations.play("")
	var Level = 1
	health = 1 + Level
	strength = (3 * Level) - 1
	defense = 0

func take_turn():
	if moving:
		return
	for temp in Movement_Speed:
		var try_move = Vector2.ZERO
		if player and !player.is_invisible:
			try_move = vec_to_cardinal(position.direction_to(player.position))
		else :
			if GameMaster.DEBUG_RANDMOVE == true:
				#move rand
				var y = randi_range(-1, 1)
				var x = randi_range(-1,1)
				var direction = Vector2(x,y)
				try_move = vec_to_cardinal(direction)
			else:
				return #skip Turn
		if await move(try_move):
			await get_tree().process_frame


func move(dir) -> bool:
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
		return true #flag for movement happening
	return false #no movement, no delay

	
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("player in area")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("player exited area")
