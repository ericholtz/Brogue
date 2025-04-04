extends Area2D

@export var entity_name: String
@export var entity_type: GameMaster.EntityType
@export var can_pickup: bool = true
@export var entity_size = Vector2i(1,1)

# entities can be collected when collided with by a Player
func _on_body_entered(body: Node2D):
	if (body.name == "Player" and can_pickup):
		GameMaster.collect_entity(self)
		if (entity_type == GameMaster.EntityType.GOLD):
			queue_free()

func _on_body_exited(_body: Node2D):
	can_pickup = true
