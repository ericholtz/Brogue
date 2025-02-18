extends Node2D

@export var inside_width : int
@export var inside_height : int

var room_name = "Large Vertical"
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
