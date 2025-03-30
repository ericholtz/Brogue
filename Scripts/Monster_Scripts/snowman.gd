extends CharacterBody2D

@onready var Animations = $AnimatedSprite2D
@onready var Ray = $RayCast2D

var entity_name = "Snowman"
var entity_size = Vector2i(1,1)
@export var entity_type: GameMaster.EntityType

var animationSpeed = 18 #Used what player was
var moving = false
var player = null

#Monsters States
var health = 5
var strength = 1
var defense = 25
var xp = 100

var tileSize = 16

func _ready():
	# position and animation
	add_to_group("enemies")
	Animations.play("")

func take_turn():
	return # Here for future
