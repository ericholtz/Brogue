extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var item = get_child(0)
		GameMaster.collectEntity(self)
		if (item.type == item.Type.GOLD):
			queue_free()
