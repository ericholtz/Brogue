extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.has_key:
		SoundFx.stairs()
		get_node("/root/World/map_gen").regenerate_map()
	else:
		$"ExitMsg".visible = true

func _on_body_exited(body: Node2D) -> void:
	$ExitMsg.visible = false
