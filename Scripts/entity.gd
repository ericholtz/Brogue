extends Area2D

@export var entityName: String
@export var entityType: GameMaster.EntityType
@export var canPickup: bool = true

# entities can be collected when collided with by a Player
func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player" and canPickup):
		GameMaster.collect_entity(self)
		if (entityType == GameMaster.EntityType.GOLD):
			queue_free()
			
