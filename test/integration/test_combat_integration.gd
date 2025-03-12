extends GutTest

#This is an INTEGRATION test of GameMaster's combat function, using the actual scripts for player and enemy instead of dummy values

#load the relevant scripts and make holders
var GameMaster = load("res://Core/GameMaster.gd")
var Player = load("res://Scenes/Player.tscn")
var Enemy = load("res://Scenes/Enemies/Cave_Enemies/SkeletonWarrior.tscn")

var gm = null
var player = null
var enemy = null

#before each test, instantiate new gm/player/enemy and add to scene tree
func before_each():
	gm = GameMaster.new()
	player = Player.instantiate()
	enemy = Enemy.instantiate()
	
	add_child(gm)
	add_child(player)
	add_child(enemy)

#after each test, free everything
func after_each():
	gm.queue_free()
	player.queue_free()
	enemy.queue_free()

#test for combat to calculate the right numbers
func test_combat_damage():
	player.attack = 5
	enemy.defense = 2
	var expected_damage = 3
	gm.combat(player, enemy)
	await get_tree().create_timer(0.7).timeout
	assert_eq(enemy.health, 2)
