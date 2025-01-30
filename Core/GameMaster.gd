extends Node

signal gained_gold(gold_count: int)
signal gained_item(item_name: String)

var gold = 0

func collectItem(itemName: String):
	match itemName:
		"SmallGold":
			gained_gold.emit(2)
			gold += 2
		"MediumGold":
			gained_gold.emit(5)
			gold += 5
		"LargeGold":
			gained_gold.emit(10)
			gold += 10
		_:
			gained_item.emit(itemName)
