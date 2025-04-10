extends Node2D

@onready var player: Node2D  = $"/root/World/Player"# Drag your player node here
@export var reveal_radius: int = 4  # Radius of revealed area
@onready var fog_tilemap = $Fog

@export var inside_width : int = 26
@export var inside_height : int = 9

var room_name = "Large Horizontal"
var Generation
var spawned_entity
var fog = false


var start_idx = -3
var total_width = 34
var total_height = 17

func _ready():
	spawned_entity = {"ENEMY" : [], "ITEM" : [], "GOLD" : []}
	fog_tilemap.z_index = 10
	
func _process(_delta):
	if !fog:
		$Fog.visible = !GameMaster.DISABLE_FOG
	reveal_area(player.global_position)

# Reveals tiles around the player
func reveal_area(playerposition):
	var tile_pos = fog_tilemap.local_to_map(fog_tilemap.to_local(playerposition))
	
	for x in range(-reveal_radius, reveal_radius + 1):
		for y in range(-reveal_radius, reveal_radius + 1):
			var fog_tile = tile_pos + Vector2i(x, y)
			fog_tilemap.erase_cell(fog_tile)  # Removes fog from revealed area

func northleft():
	$DoorLeftN.visible = true
	if $WallLeftN:
		$WallLeftN.queue_free()

func northright():
	$DoorRightN.visible = true
	if $WallRightN:
		$WallRightN.queue_free()

func southleft():
	$DoorLeftS.visible = true
	if $WallLeftS:
		$WallLeftS.queue_free()

func southright():
	$DoorRightS.visible = true
	if $WallRightS:
		$WallRightS.queue_free()

func east():
	$DoorE.visible = true
	if $WallE:
		$WallE.queue_free()
	
func west():
	$DoorW.visible = true
	if $WallW:
		$WallW.queue_free()
	
func gold():
	$Gold.visible = true
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Fog.visible = false
		fog = true
