extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# call function to start new level
		get_node("/root/World/map_gen").regenerate_map()
