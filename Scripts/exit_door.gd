extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		# call function to start new level
		get_node("/root/World/map_gen").regenerate_map()
