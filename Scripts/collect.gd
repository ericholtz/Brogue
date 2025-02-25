extends Area2D


var entity_name = "item"
var entity_type = "item"

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		GameMaster.collectItem(name)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var item = get_child(0)
		GameMaster.collectEntity(self)
		if (item.type == item.Type.GOLD):
			queue_free()
