extends Node2D

@export var inside_width : int
@export var inside_height : int

var Generation

func choose_size():
	var random_value = randi_range(0, 9)
	
	if random_value < 7:
		$SmallGold.visible = true
		$LargeGold.queue_free()
		$MediumGold.queue_free()
	elif random_value < 9:
		$MediumGold.visible = true
		$LargeGold.queue_free()
		$SmallGold.queue_free()
	else:
		$LargeGold.visible = true
		$MediumGold.queue_free()
		$SmallGold.queue_free()
	
