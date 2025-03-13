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
func test_combat_round():
	#run combat, wait for tweens to finish with hard timer
	gm.combat(player, enemy)
	await get_tree().create_timer(0.7).timeout
	#this if check is here because combat rolls a die for each side
	if enemy.health < 5:
		#if the enemy's health dropped, make sure it dropped correctly
		assert_eq(enemy.health, 4, "Enemy health is <"+str(enemy.health)+">, expected 4")
	else:
		#if it doesn't (miss), make sure it remains unchanged
		assert_eq(enemy.health, 5, "Enemy health is <"+str(enemy.health)+">, expected 5 on player miss")
	#same check as above for player
	if player.health < 10:
		assert_eq(player.health, 9, "Player health is <"+str(player.health)+">, expected 9")
	else:
		assert_eq(player.health, 10, "Player health is <"+str(player.health)+">, expected 10 on enemy miss")
