extends Node2D

@export var inside_width : int
@export var inside_height : int

var room_name = "Large Horizontal"
var Generation

func northleft():
	#pass
	$DoorLeftN.visible = true
	if $WallLeftN:
		$WallLeftN.queue_free()

func northright():
	$DoorRightN.visible = true
	if $WallRightN:
		$WallRightN.queue_free()

func southleft():
	#pass
	$DoorLeftS.visible = true
	if $WallLeftS:
		$WallLeftS.queue_free()

func southright():
	$DoorRightS.visible = true
	if $WallRightS:
		$WallRightS.queue_free()

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
	
func gold():
	$Gold.visible = true
	
