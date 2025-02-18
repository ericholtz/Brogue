extends Node2D

@onready var player: Node2D  = $"/root/World/Player"# Drag your player node here
@export var reveal_radius: int = 3  # Radius of revealed area
@onready var fog_tilemap = $Fog

@export var inside_width : int
@export var inside_height : int

var room_name = "Large Vertical"
var Generation

var start_idx = -3
var total_width = 17
var total_height = 34

func _ready():
	fill_fog()  # Covers the map at the start
	fog_tilemap.z_index = 10
	
func _process(delta):
	reveal_area(player.global_position)

 #Covers the entire map with fog tiles
func fill_fog():
	if not fog_tilemap:
		print("error no map")
		return
	
	for x in range(start_idx, start_idx + total_width):
		for y in range(start_idx, start_idx + total_height):
			fog_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(3, 13), 0)  # Use your fog tile ID
			
# Reveals tiles around the player
func reveal_area(position):
	var tile_pos = fog_tilemap.local_to_map(fog_tilemap.to_local(position))
	
	for x in range(-reveal_radius, reveal_radius + 1):
		for y in range(-reveal_radius, reveal_radius + 1):
			var fog_tile = tile_pos + Vector2i(x, y)
			fog_tilemap.erase_cell(fog_tile)  # Removes fog from revealed area

func north():
	#pass
	$DoorN.visible = true
	if $WallN:
		$WallN.queue_free()
	
func south():
	#pass
	$DoorS.visible = true
	if $WallS:
		$WallS.queue_free()
	
func easttop():
	#pass
	$DoorTopE.visible = true
	if $WallTopE:
		$WallTopE.queue_free()

func eastbot():
	#pass
	$DoorBotE.visible = true
	if $WallBotE:
		$WallBotE.queue_free()

func westtop():
	#pass
	$DoorTopW.visible = true
	if $WallTopW:
		$WallTopW.queue_free()

func westbot():
	#pass
	$DoorBotW.visible = true
	if $WallBotW:
		$WallBotW.queue_free()
	
func gold():
	$Gold.visible = true
