extends Node2D

@export var inside_width : int
@export var inside_height : int

var Generation

var room_name = "hallway"
var flag_north = false
var flag_south = false
var flag_east = false
var flag_west = false

func north():
	#pass
	$DoorN.visible = true
	flag_north = true
	if $WallN:
		$WallN.queue_free()
	
func south():
	#pass
	$DoorS.visible = true
	flag_south = true
	if $WallS:
		$WallS.queue_free()
	
func east():
	#pass
	$DoorE.visible = true
	flag_east = true
	if $WallE:
		$WallE.queue_free()
	
func west():
	#pass
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
		print("dead end")
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
	
