extends Area2D

@export var entity_type: GameMaster.EntityType


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# call function to start new level
		get_node("/root/World/map_gen").regenerate_map()
		# reset zoom and fog from possible map use
		GameMaster.DISABLE_FOG = false
		body.find_child("Camera2D").zoom = Vector2(3, 3)
