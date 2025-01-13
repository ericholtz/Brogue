extends Area2D

@onready var PlayerAnim = $AnimatedSprite2D
@onready var Ray = $RayCast2D

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
	for dir in inputs.keys():
		if event.is_action_pressed("Left"):
			PlayerAnim.flip_h = true
		if event.is_action_pressed("Right"):
			PlayerAnim.flip_h = false
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	Ray.target_position = inputs[dir] * tileSize
	Ray.force_raycast_update()
	if !Ray.is_colliding():
		position += inputs[dir] * tileSize
