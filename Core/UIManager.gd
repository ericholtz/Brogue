extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameMaster.gained_gold.connect(update_gold_display)
	GameMaster.health_changed.connect(update_health_display)

func update_gold_display(_gained_gold):
	# Defer the update so it runs after the player data actually updates
	call_deferred("_update_gold_display")

func _update_gold_display():
	$GoldDisplay.text = str($"../Player".gold)

func update_health_display(_adjust_health):
	call_deferred("_update_health_display")

func _update_health_display():
	$HealthDisplay.text = str($"../Player".health)
