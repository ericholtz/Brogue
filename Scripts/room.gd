extends Node2D

@export var inside_width : int
@export var inside_height : int

var Generation

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
	
func east():
	#pass
	$DoorE.visible = true
	if $WallE:
		$WallE.queue_free()
	
func west():
	#pass
	$DoorW.visible = true
	if $WallW:
		$WallW.queue_free()
	
