extends GutTest

# WHITE-BOX tests player _on_item_gain function with relevant CONDITION coverage
# _on_item_gain method located in Player.gd script
# 
# Here is the code for the function:
# === START OF CODE FOR _on_item_gain ===
#func _on_item_gain(item : Area2D):
	#var index = inventory.find(item.entity_name)
	## add unique new item
	#if (index == -1):
		#inventory.append(item.entity_name)
		#item.can_pickup = false
		#item.call_deferred("reparent", inventory_node)
		#item.visible = false
		#if (DEBUG_ITEM):
			#print("Added ", item.entity_name, " to inventory. Current inventory is:")
			#print(inventory)
	## increase existing stackable item count
	#elif (index != -1 and item.stackable):
		#var existing_item = inventory_node.get_child(index)
		#existing_item.count += 1
		#item.queue_free()
		#if (DEBUG_ITEM):
			#print("Increased stack count of ", existing_item.entity_name, " to ", existing_item.count, ". Current inventory is:")
			#print(inventory)
# ===  END OF CODE FOR _on_item_gain  ===
# 
# RELEVANT CONDITIONS ARE:
# 1. index == -1 and item.stackable can be true or false
# 2. index != -1 and item.stackable == true
# 3. index != -1 and item.stackable == false
# (for context, index == -1 just means the item isn't in the inventory list)

# load player and items
var Player = load("res://Scenes/Player.tscn")
var NonStackable = load("res://Scenes/Items/Weapons/Melee/GoldSword.tscn")
var Stackable = load("res://Scenes/Items/Potions/BluePotion.tscn")

# variables to hold instantiated nodes
var _player
var _non_stackable1
var _non_stackable2
var _stackable1
var _stackable2

# setup player and items for asserts
func before_all():
	# instantiate nodes
	_player = Player.instantiate()
	_non_stackable1 = NonStackable.instantiate()
	_non_stackable2 = NonStackable.instantiate()
	_stackable1 = Stackable.instantiate()
	_stackable2 = Stackable.instantiate()
	
	# add nodes to root scene
	# we move the player to make sure
	# item pickup happens on our terms
	get_tree().root.add_child(_player)
	_player.position += Vector2(100, 100)
	
	# avoid race condition where player collects
	# items before being moved
	await wait_seconds(1)
	get_tree().root.add_child(_non_stackable1)
	get_tree().root.add_child(_non_stackable2)
	get_tree().root.add_child(_stackable1)
	get_tree().root.add_child(_stackable2)
	
	# wait a second for instantiation to complete
	await wait_seconds(1)

# free player and sub-node items, since they get reparented
# also free item that wasn't picked up because it's a duplicate non-stackable
func after_all():
	_player.free()
	_non_stackable2.free()

func test_add_new_item___cond_1():
	assert_eq(_player.inventory_node.get_child_count(), 0) # make sure invenotry is empty
	_player._on_item_gain(_stackable1)
	await wait_seconds(1) # wait for item collection to complete
	
	# RELEVANT CONDITION #1 - new item
	# assert player correctly collected the item
	var unique_item1 = _player.inventory_node.get_child(0)
	assert_eq(_player.inventory_node.get_child_count(), 1)
	assert_eq(unique_item1.entity_name, "BluePotion")
	assert_eq(unique_item1.count, 1)

func test_add_stackable_item___cond_2():
	# RELEVANT CONDITION #2 - existing item and stackable == true
	# add another stackable item and assert count has increased
	# (blue potions are stackable by default)
	_player._on_item_gain(_stackable2)
	await wait_seconds(1)
	
	var unique_item1 = _player.inventory_node.get_child(0)
	assert_eq(_player.inventory_node.get_child_count(), 1)
	assert_eq(unique_item1.entity_name, "BluePotion")
	assert_eq(unique_item1.count, 2)

func test_add_non_stackable_item___cond_3():
	# add new item - preparing for #3
	# some redundant asserts here, but this is more for
	# ensuring correct test setup rather than testing the code
	_player._on_item_gain(_non_stackable1)
	await wait_seconds(1)
	var unique_item2 = _player.inventory_node.get_child(1)
	assert_eq(_player.inventory_node.get_child_count(), 2)
	assert_eq(unique_item2.count, 1)
	
	# RELEVANT CONDITION #3 - existing item and stackable == false
	# attempt to collect existing non-stackable item
	# this should do nothing, since we already have a
	# unique non-stackable item with the same name
	_player._on_item_gain(_non_stackable2)
	await wait_seconds(1)
	
	assert_eq(_player.inventory_node.get_child_count(), 2)
	assert_eq(unique_item2.count, 1)
