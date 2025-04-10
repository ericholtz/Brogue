extends "entity.gd"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SoundFx.small_coin()
		body.has_key = true
		queue_free()
