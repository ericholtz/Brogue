extends GutTest

# INTEGRATION test tests the connection between player
# and visual item list in the UI
# The scripts being integrated are Player.gd and player_stats.gd
# The two units being tested are:
# 1. player._on_item_gain(), which modifies the player's inventory
# 2. player_stats.update_inventory(), which updates the UI
#    inventory list based on the current player inventory.
# 
# Both units must be in sync to correctly display items in the UI,
# so this tests the UI system in regards to that connoection.

# load player, items, and player_stats nodes
var Player = load("res://Scenes/Player.tscn")
var PlayerStats = load("res://Scenes/Menus/player_stats.tscn")
var NonStackable = load("res://Scenes/Items/Weapons/Melee/GoldSword.tscn")
var Stackable = load("res://Scenes/Items/Potions/BluePotion.tscn")

# variables to hold instantiated nodes
var _player
var _player_stats
var _non_stackable
var _stackable

# setup player, player stats, and items
func before_all():
	# instantiate nodes
	_player = Player.instantiate()
	_player_stats = PlayerStats.instantiate()
	_non_stackable = NonStackable.instantiate()
	_stackable = Stackable.instantiate()

	# add nodes to root scene
	# we move the player to make sure
	# item pickup happens on our terms
	get_tree().root.add_child(_player)
	_player.position += Vector2(100, 100)
	
	# avoid race condition where player collects
	# items before being moved
	await wait_seconds(1)
	get_tree().root.add_child(_player_stats)
	get_tree().root.add_child(_non_stackable)
	get_tree().root.add_child(_stackable)

# clean up instantiated nodes
func after_all():
	_player.free()
	_player_stats.free()

# test adding a single item and updating the UI inventory list
func test_add_item_to_list():
	# validate inventory list is empty
	assert_eq(_player_stats.inventory_list.get_child_count(), 0)
	
	# add item and check inventory list node count
	_player._on_item_gain(_non_stackable)
	await wait_seconds(1)
	_player_stats.update_inventory()
	assert_eq(_player_stats.inventory_list.get_child_count(), 1)

# test adding another unique item
func test_add_new_unique_item_to_list():
	# add another item and check inventory list node count
	_player._on_item_gain(_stackable)
	await wait_seconds(1)
	_player_stats.update_inventory()
	assert_eq(_player_stats.inventory_list.get_child_count(), 2)

# test using an item and seeing if it gets removed from the list
func test_use_item_remove_from_list():
	_player.use(1) # use the second item, which is the consumable
	await wait_seconds(1)
	_player_stats.update_inventory()
	
	# since we used a consumable, the item should be gone, so we should
	# be back down to 1 item in the inventory
	assert_eq(_player_stats.inventory_list.get_child_count(), 1)
