extends GutTest

# This is a BLACK-BOX test on inputs for Player.use() function
# checks ranges of index inputs and types of items indexed
#
# Since the function just takes an integer, it could be argued
# that I should only be testing in and out of range indexes.
# However, since I expect this method to have different
# behavior depending on what node is at that inventory index,
# there are asserts for each type of item as well.

# load player and items
var Player = load("res://Scenes/Player.tscn")
var MeleeWeapon = load("res://Scenes/Items/Weapons/Melee/GoldSword.tscn")
var Armor = load("res://Scenes/Items/Armor/ChainArmor.tscn")
var HealingPotion = load("res://Scenes/Items/Potions/RedPotion.tscn")
var InvisibilityPotion = load("res://Scenes/Items/Potions/BluePotion.tscn")
var Misc = load("res://Scenes/Items/Misc/MetalKey.tscn")

# variables to hold instantiated nodes
var _player
var _melee_weapon
var _armor
var _healing_potion
var _invisibility_potion
var _misc

# enum so more item types could be added in the future
enum ItemIndex {
	MELEE_WEAPON,
	ARMOR,
	HEALING_POTION,
	INVISIBILITY_POTION,
	MISC,
}

# setup player, items, and inventory for asserts
func before_all():
	# instantiate nodes
	_player = Player.instantiate()
	_melee_weapon = MeleeWeapon.instantiate()
	_armor = Armor.instantiate()
	_healing_potion = HealingPotion.instantiate()
	_invisibility_potion = InvisibilityPotion.instantiate()
	_misc = Misc.instantiate()
	
	# add nodes to root scene
	get_tree().root.add_child(_player)
	get_tree().root.add_child(_melee_weapon)
	get_tree().root.add_child(_armor)
	get_tree().root.add_child(_healing_potion)
	get_tree().root.add_child(_invisibility_potion)
	get_tree().root.add_child(_misc)
	
	# attach item nodes to player node
	_melee_weapon._on_body_entered(_player)
	_armor._on_body_entered(_player)
	_healing_potion._on_body_entered(_player)
	_invisibility_potion._on_body_entered(_player)
	_misc._on_body_entered(_player)
	
	# wait a second for instantiation to complete
	await wait_seconds(1)

# free player once finished
# this also frees items, since they became child nodes
func after_all():
	_player.free()

# asserts that the player's attack changes
# when using a range of weapon stats
func test_assert_attack_change():
	var og_attack = _player.attack
	for test_attack in range(-3,3):
		_melee_weapon.attack = test_attack
		_player.use(ItemIndex.MELEE_WEAPON)
		
		assert_eq(_player.attack, og_attack+test_attack)

# asserts that the player's defense changes
# when using a range of armor stats
func test_assert_defense_change():
	var og_armor = _player.armor
	for test_armor in range(-3,3):
		_armor.armor = test_armor
		_player.use(ItemIndex.ARMOR)
		
		assert_eq(_player.armor, og_armor+test_armor)

# asserts that the player's health increases by 25% of their max health
# when using a healing potion (this is expected behavior)
func test_assert_health_change():
	var og_health = _player.health
	_player.use(ItemIndex.HEALING_POTION)
	
	assert_eq(_player.health, int(og_health+ceil(float(_player.MAX_HEALTH)/4)))

# asserts that the player.visible field becomes false when using an invisibility potion
func test_assert_visibility_change():
	assert_true(_player.visible)
	_player.use(ItemIndex.INVISIBILITY_POTION - 1) # minus 1 because 1 potion was consumed
	
	assert_false(_player.visible)
# I won't test the other potions, since they do nothing

# asserts that nothing changes after using a key
# To make sure I test all item categories, I am going
# to test the key item (MISC category of items).
# keys are unimplemented so they shouldn't do anything.
func test_assert_misc_no_change():
	var og_stats = [
		_player.attack,
		_player.armor,
		_player.health,
		]
	_player.use(ItemIndex.MISC - 1) # minus 2 because 2 potions were consumed
	assert_eq_deep(og_stats, [_player.attack, _player.armor, _player.health])

# tests out-of-bounds inventory_node indexes
func test_out_of_bounds():
	# since these values are out of bounds
	# for the player's inventory list,
	# the player's stats shouldn't change at all
	var og_stats = [
		_player.attack,
		_player.armor,
		_player.health,
		]
	_player.use(-5)
	assert_eq_deep(og_stats, [_player.attack, _player.armor, _player.health])
	_player.use(-1)
	assert_eq_deep(og_stats, [_player.attack, _player.armor, _player.health])
	_player.use(99999)
	assert_eq_deep(og_stats, [_player.attack, _player.armor, _player.health])
