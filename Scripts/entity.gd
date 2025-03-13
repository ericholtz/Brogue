extends Area2D

@export var entity_name: String
@export var entity_type: GameMaster.EntityType
@export var can_pickup: bool = true

# entities can be collected when collided with by a Player
func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player" and can_pickup):
		GameMaster.collect_entity(self)
		if (entity_type == GameMaster.EntityType.GOLD):
			queue_free()
			
