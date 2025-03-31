extends CharacterBody2D

@onready var Animations = $AnimatedSprite2D
#Rays
@onready var RayTopRight = $RayTopRight
@onready var RayTopLeft = $RayTopLeft
@onready var RayBottomRight = $RayBottomRight
@onready var RayBottomLeft = $RayBottomLeft
@onready var RayRightTop = $RayRightTop
@onready var RayRightBottom = $RayRightBottom
@onready var RayLeftTop = $RayLeftTop
@onready var RayLeftBottom = $RayLeftBottom

var entity_name = "Polar Bear"
var entity_size = Vector2i(2,2)
@export var entity_type: GameMaster.EntityType

# Basic Used
var animationSpeed = 18
var moving = false
var player = null
var tileSize = 16

#Monsters States
var health = 30
var strength = 4
var defense = 0
var Movement_Speed = 1
var xp = 20

func _ready():
	# position and animation
	add_to_group("enemies")
	Animations.play("")
	var Level = get_parent().level
	health = 5 * Level
	strength = (2 * Level)
	defense = Level - 1

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
				return #Skip turn
		if await move(try_move):
			await get_tree().process_frame



func move(dir) -> bool:
	if dir == Vector2.UP:
		# Update Rays
		RayTopRight.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayTopRight.force_raycast_update()
		RayTopLeft.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayTopLeft.force_raycast_update()
		
		if !RayTopRight.is_colliding() and !RayTopLeft.is_colliding(): #if ray is colliding with a wall, we can't move there
			var tween = create_tween() #create a new Tween object to handle smooth movement
			#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
			tween.tween_property(self, "position", position + dir * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
			moving = true #set this to true until tween is finished to disallow multiple moves at once
			await tween.finished
			moving = false
			emit_signal("input_event") #emit a movement signal here, after the player succesfully moves
			return true #flag for movement happening
		return false #no movement, no delay
	elif dir == Vector2.DOWN:
		# Update Rays
		RayBottomRight.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayBottomRight.force_raycast_update()
		RayBottomLeft.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayBottomLeft.force_raycast_update()
		
		if !RayBottomRight.is_colliding() and !RayBottomLeft.is_colliding(): #if ray is colliding with a wall, we can't move there
			var tween = create_tween() #create a new Tween object to handle smooth movement
			#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
			tween.tween_property(self, "position", position + dir * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
			moving = true #set this to true until tween is finished to disallow multiple moves at once
			await tween.finished
			moving = false
			emit_signal("input_event") #emit a movement signal here, after the player succesfully moves
			return true #flag for movement happening
		return false #no movement, no delay
	elif dir == Vector2.RIGHT:
		# Update Rays
		RayRightTop.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayRightTop.force_raycast_update()
		RayRightBottom.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayRightBottom.force_raycast_update()
		
		if !RayRightTop.is_colliding() and !RayRightBottom.is_colliding(): #if ray is colliding with a wall, we can't move there
			var tween = create_tween() #create a new Tween object to handle smooth movement
			#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
			tween.tween_property(self, "position", position + dir * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
			moving = true #set this to true until tween is finished to disallow multiple moves at once
			await tween.finished
			moving = false
			emit_signal("input_event") #emit a movement signal here, after the player succesfully moves
			return true #flag for movement happening
		return false #no movement, no delay
	elif dir == Vector2.LEFT:
		# Update Rays
		RayLeftTop.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayLeftTop.force_raycast_update()
		RayLeftBottom.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayLeftBottom.force_raycast_update()
		
		if !RayLeftTop.is_colliding() and !RayLeftBottom.is_colliding(): #if ray is colliding with a wall, we can't move there
			var tween = create_tween() #create a new Tween object to handle smooth movement
			#tween the position property of self to a position of +16 pixels in the input direction, on a sin curve
			tween.tween_property(self, "position", position + dir * tileSize, 1.0/animationSpeed).set_trans(Tween.TRANS_SINE)
			moving = true #set this to true until tween is finished to disallow multiple moves at once
			await tween.finished
			moving = false
			emit_signal("input_event") #emit a movement signal here, after the player succesfully moves
			return true #flag for movement happening
		return false #no movement, no delay
	return false #no movement at all, no delay!!!


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
