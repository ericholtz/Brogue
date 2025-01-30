extends Node

signal gained_gold(gold_count: int)
signal gained_item(item_name: String)

var gold = 0

func collectItem(itemName: String):
	match itemName:
		"SmallGold":
			gold += 2
			gained_gold.emit(2)
		"MediumGold":
			gold += 5
			gained_gold.emit(5)
		"LargeGold":
			gold += 10
			gained_gold.emit(10)
		_:
			gained_item.emit(itemName)
