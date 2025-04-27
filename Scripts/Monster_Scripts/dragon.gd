extends CharacterBody2D

@onready var Animations = $AnimatedSprite2D

#Rays
@onready var RayTopRight = $RayTopRight
@onready var RayTopMiddle = $RayTopMiddle
@onready var RayTopLeft = $RayTopLeft
@onready var RayBottomRight = $RayBottomRight
@onready var RayBottomMiddle = $RayBottomMiddle
@onready var RayBottomLeft = $RayBottomLeft
@onready var RayRightTop = $RayRightTop
@onready var RayRightMiddle = $RayRightMiddle
@onready var RayRightBottom = $RayRightBottom
@onready var RayLeftTop = $RayLeftTop
@onready var RayLeftMiddle = $RayLeftMiddle
@onready var RayLeftBottom = $RayLeftBottom

var entity_name = "Dragon"
var entity_size = Vector2i(3, 3)
@export var entity_type: GameMaster.EntityType

# Basic Used
var animationSpeed = 18
var moving = false
var player = null
var playerattack = null
var tileSize = 16
var breathFire = false
var breathAttackCooldown = 0
var breathAttackDirection = "None"
var startedBreathAttackDirection = "None"

#Monsters States
var health = 50
var strength = 5
var defense = 3
var Movement_Speed = 1
var xp = 100

func _ready():
	# position and animation
	add_to_group("enemies")
	Animations.play("")
	var Level = get_parent().level
	health = (Level * 4)
	strength = (Level * 3)
	defense = (Level)

func take_turn():
	if moving:
		return
	if player != null:
		if breathFire == true: # Attack with Fire Breath
			breathFire = false
			if startedBreathAttackDirection == "Right":
				# Call Animations
				$BreathAttackRight/Close/MiddleFire.emitting = true
				$BreathAttackRight/Medium/TopFire.emitting = true
				$BreathAttackRight/Medium/MiddleFire.emitting = true
				$BreathAttackRight/Medium/BottomFire.emitting = true
				$BreathAttackRight/Far/BottomFire.emitting = true
				$BreathAttackRight/Far/BottomMiddleFire.emitting = true
				$BreathAttackRight/Far/MiddleFire.emitting = true
				$BreathAttackRight/Far/TopMiddleFire.emitting = true
				$BreathAttackRight/Far/TopFire.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Emiting Right Breath Attak")
			elif startedBreathAttackDirection == "Left":
				# Call Animations
				$BreathAttackLeft/Close/MiddleFire.emitting = true
				$BreathAttackLeft/Medium/TopFire.emitting = true
				$BreathAttackLeft/Medium/MiddleFire.emitting = true
				$BreathAttackLeft/Medium/BottomFire.emitting = true
				$BreathAttackLeft/Far/BottomFire.emitting = true
				$BreathAttackLeft/Far/BottomMiddleFire.emitting = true
				$BreathAttackLeft/Far/MiddleFire.emitting = true
				$BreathAttackLeft/Far/TopMiddleFire.emitting = true
				$BreathAttackLeft/Far/TopFire.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Emiting Left Breath Attak")
			elif startedBreathAttackDirection == "Top":
				# Call Animations
				$BreathAttackTop/Close/MiddleFire.emitting = true
				$BreathAttackTop/Medium/LeftFire.emitting = true
				$BreathAttackTop/Medium/MiddleFire.emitting = true
				$BreathAttackTop/Medium/RightFire.emitting = true
				$BreathAttackTop/Far/RightFire.emitting = true
				$BreathAttackTop/Far/RightMiddleFire.emitting = true
				$BreathAttackTop/Far/MiddleFire.emitting = true
				$BreathAttackTop/Far/LeftMiddleFire.emitting = true
				$BreathAttackTop/Far/LeftFire.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Emiting Top Breath Attak")
			elif startedBreathAttackDirection == "Bottom":
				# Call Animations
				$BreathAttackBottom/Close/MiddleFire.emitting = true
				$BreathAttackBottom/Medium/LeftFire.emitting = true
				$BreathAttackBottom/Medium/MiddleFire.emitting = true
				$BreathAttackBottom/Medium/RightFire.emitting = true
				$BreathAttackBottom/Far/RightFire.emitting = true
				$BreathAttackBottom/Far/RightMiddleFire.emitting = true
				$BreathAttackBottom/Far/MiddleFire.emitting = true
				$BreathAttackBottom/Far/LeftMiddleFire.emitting = true
				$BreathAttackBottom/Far/LeftFire.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Emiting Bottom Breath Attak")
			# Attack Player
			if startedBreathAttackDirection == breathAttackDirection:
				# Attack & damge
				await GameMaster.dragon_combat(player, self)
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Attacking With Breath Attak")
					# Call Attack
		elif breathAttackCooldown == 0 and (breathAttackDirection != "None"): # Prepare Fire Breath Attack
			breathFire = true
			breathAttackCooldown = 3
			startedBreathAttackDirection = breathAttackDirection
			# Find Direction
			if startedBreathAttackDirection == "Right":
				# Emit area indicators of attack Right
				$BreathAttackRight/Close/MiddleIndicator.emitting = true
				$BreathAttackRight/Medium/TopIndicator.emitting = true
				$BreathAttackRight/Medium/MiddleIndicator.emitting = true
				$BreathAttackRight/Medium/BottomIndicator.emitting = true
				$BreathAttackRight/Far/TopIndicator.emitting = true
				$BreathAttackRight/Far/TopMiddleIndicator.emitting = true
				$BreathAttackRight/Far/MiddleIndicator.emitting = true
				$BreathAttackRight/Far/BottomMiddleIndicator.emitting = true
				$BreathAttackRight/Far/BottomIndicator.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Starting Right Breath Attak")
			elif startedBreathAttackDirection == "Left":
				# Emit area indicators of attack Left
				$BreathAttackLeft/Close/MiddleIndicator.emitting = true
				$BreathAttackLeft/Medium/TopIndicator.emitting = true
				$BreathAttackLeft/Medium/MiddleIndicator.emitting = true
				$BreathAttackLeft/Medium/BottomIndicator.emitting = true
				$BreathAttackLeft/Far/TopIndicator.emitting = true
				$BreathAttackLeft/Far/TopMiddleIndicator.emitting = true
				$BreathAttackLeft/Far/MiddleIndicator.emitting = true
				$BreathAttackLeft/Far/BottomMiddleIndicator.emitting = true
				$BreathAttackLeft/Far/BottomIndicator.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Starting Left Breath Attak")
			elif startedBreathAttackDirection == "Top":
				# Emit area indicators of attack top
				$BreathAttackTop/Close/MiddleIndicator.emitting = true
				$BreathAttackTop/Medium/LeftIndicator.emitting = true
				$BreathAttackTop/Medium/MiddleIndicator.emitting = true
				$BreathAttackTop/Medium/RightIndicator.emitting = true
				$BreathAttackTop/Far/RightIndicator.emitting = true
				$BreathAttackTop/Far/RightMiddleIndicator.emitting = true
				$BreathAttackTop/Far/MiddleIndicator.emitting = true
				$BreathAttackTop/Far/LeftMiddleIndicator.emitting = true
				$BreathAttackTop/Far/LeftIndicator.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Starting Top Breath Attak")
			elif startedBreathAttackDirection == "Bottom":
				# Emit area indicators of attack bottom 
				$BreathAttackBottom/Close/MiddleIndicator.emitting = true
				$BreathAttackBottom/Medium/LeftIndicator.emitting = true
				$BreathAttackBottom/Medium/MiddleIndicator.emitting = true
				$BreathAttackBottom/Medium/RightIndicator.emitting = true
				$BreathAttackBottom/Far/RightIndicator.emitting = true
				$BreathAttackBottom/Far/RightMiddleIndicator.emitting = true
				$BreathAttackBottom/Far/MiddleIndicator.emitting = true
				$BreathAttackBottom/Far/LeftMiddleIndicator.emitting = true
				$BreathAttackBottom/Far/LeftIndicator.emitting = true
				if GameMaster.DEBUG_ENEMY_PRINTS == true:
					print("Starting Bottom Breath Attak")
		elif playerattack != null and not playerattack.is_invisible and not playerattack.moving: # Normal Attack
			await GameMaster.ranged_enemy_combat(playerattack, self)
			if breathAttackCooldown > 0:
				breathAttackCooldown = breathAttackCooldown - 1
		else: # Move and Wait for Cooldown
			if breathAttackCooldown > 0:
				breathAttackCooldown = breathAttackCooldown - 1
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
		# Update Rays Top
		RayTopRight.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayTopRight.force_raycast_update()
		RayTopMiddle.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayTopMiddle.force_raycast_update()
		RayTopLeft.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayTopLeft.force_raycast_update()
		
		if !RayTopRight.is_colliding() and !RayTopMiddle.is_colliding() and !RayTopLeft.is_colliding(): #if ray is colliding with a wall, we can't move there
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
		# Ray Bottom Update
		RayBottomRight.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayBottomRight.force_raycast_update()
		RayBottomMiddle.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayBottomMiddle.force_raycast_update()
		RayBottomLeft.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayBottomLeft.force_raycast_update()
		
		if !RayBottomRight.is_colliding() and !RayBottomMiddle.is_colliding() and !RayBottomLeft.is_colliding(): #if ray is colliding with a wall, we can't move there
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
		#Ray Right Update
		RayRightTop.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayRightTop.force_raycast_update()
		RayRightMiddle.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayRightMiddle.force_raycast_update()
		RayRightBottom.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayRightBottom.force_raycast_update()
		
		if !RayRightTop.is_colliding() and !RayRightMiddle.is_colliding() and !RayRightBottom.is_colliding(): #if ray is colliding with a wall, we can't move there
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
		# Ray Update Left
		RayLeftTop.target_position = dir *  tileSize # set ray to move direction +16 pixels
		RayLeftTop.force_raycast_update()
		RayLeftMiddle.target_position = dir *  tileSize # set ray to move direction +16 pixels
		RayLeftMiddle.force_raycast_update()
		RayLeftBottom.target_position = dir * tileSize # set ray to move direction +16 pixels
		RayLeftBottom.force_raycast_update()
		
		if !RayLeftTop.is_colliding() and !RayLeftMiddle.is_colliding() and !RayLeftBottom.is_colliding(): #if ray is colliding with a wall, we can't move there
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
			print("Player In Vision Area")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Exited Vision Area")

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

func _on_breath_attack_right_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "Right"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Entered Right Breath Attack Area.")

func _on_breath_attack_right_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "None"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Exited Right Breath Attack Area.")

func _on_breath_attack_left_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "Left"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Entered Left Breath Attack Area.")

func _on_breath_attack_left_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "None"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Exited Left Breath Attack Area.")

func _on_breath_attack_top_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "Top"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Entered Top Breath Attack Area.")

func _on_breath_attack_top_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "None"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Exited Top Breath Attack Area.")

func _on_breath_attack_bottom_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "Bottom"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Entered Bottom Breath Attack Area.")

func _on_breath_attack_bottom_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		breathAttackDirection = "None"
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Exited Bottom Breath Attack Area.")

func _on_attack_vision_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		playerattack = body
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Entered Attack Area.")

func _on_attack_vision_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		playerattack = null
		if GameMaster.DEBUG_ENEMY_PRINTS == true:
			print("Player Exited Attack Area.")
