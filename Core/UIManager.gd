extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameMaster.gained_gold.connect(update_gold_display)

func update_gold_display(gained_gold):
	$GoldDisplay.text = str(GameMaster.gold)
