extends Node2D

@onready var player: Node2D  = $"/root/World/Player"# Drag your player node here
@export var reveal_radius: int = 4  # Radius of revealed area
@onready var fog_tilemap = $Fog

@export var inside_width : int
@export var inside_height : int

var room_name = "hallway"
var Generation
var fog = false

var start_idx = -3
var total_width = 34
var total_height = 17

var flag_north = false
var flag_south = false
var flag_east = false
var flag_west = false

func _ready():
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

func north():
	$DoorN.visible = true
	flag_north = true
	if $WallN:
		$WallN.queue_free()
	
func south():
	$DoorS.visible = true
	flag_south = true
	if $WallS:
		$WallS.queue_free()
	
func east():
	$DoorE.visible = true
	flag_east = true
	if $WallE:
		$WallE.queue_free()
	
func west():
	$DoorW.visible = true
	flag_west = true
	if $WallW:
		$WallW.queue_free()

func corner():
	# 4 way connection
	if flag_east and flag_north and flag_south and flag_west:
		$CornerNESW.visible = true
		
	# 3 way connection
	elif flag_east and flag_north and flag_west:
		$CornerNWE.visible = true
		
	elif flag_east and flag_south and flag_west:
		$CornerESW.visible = true
		
	elif flag_north and flag_south and flag_west:
		$CornerNWS.visible = true
		
	elif flag_east and flag_north and flag_south:
		$CornerNES.visible = true
		
	# 2 way connection
	elif flag_north and flag_south :
		$CornerNS.visible = true
		
	elif flag_east and flag_north :
		$CornerNE.visible = true
		
	elif flag_north and flag_west:
		$CornerNW.visible = true
		
	elif flag_east and flag_south:
		$CornerES.visible = true
		
	elif flag_east and flag_west:
		$CornerEW.visible = true
		
	elif flag_south and flag_west:
		$CornerSW.visible = true
		
	else:
		if GameMaster.DEBUG_MAP: print("dead end")
		if flag_north:
			$CornerN.visible = true
		elif flag_east:
			$CornerE.visible = true
		elif flag_south:
			$CornerS.visible = true
		else:
			$CornerW.visible = true
	
func gold():
	$Gold.visible = true
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		fog_tilemap.visible = false
		fog = true
