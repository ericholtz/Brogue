extends Area2D

#onready vars to reference other nodes and manipulate their values
@onready var PlayerAnim = $AnimatedSprite2D
@onready var Ray = $RayCast2D

var animationSpeed = 18 #tweening speed
var moving = false #keeps us from glitching out movement

var tileSize = 16
var inputs = {"Up": Vector2.UP,
			"Left": Vector2.LEFT,
			"Right": Vector2.RIGHT,
			"Down": Vector2.DOWN}

func _ready():
	position = position.snapped(Vector2.ONE * tileSize)
	position += Vector2.ONE * tileSize/2
	PlayerAnim.play("Idle")

func _input(event):
	if moving:
		#if we're already tweening movement, don't move again
		return
	for dir in inputs.keys():
		if event.is_action_pressed("Left"):
			PlayerAnim.flip_h = true
		if event.is_action_pressed("Right"):
			PlayerAnim.flip_h = false
		if event.is_action_pressed(dir):
			move(dir)

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
