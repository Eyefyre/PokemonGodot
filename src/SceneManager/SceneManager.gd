extends Node2D

var next_scene = null

var player_location = Vector2(0,0)
var player_direction = Vector2(0,0)

enum transitionType {NEW_SCENE,BATTLE,FROM_BATTLE,FROM_MAIN_MENU}
var transition_type = transitionType.NEW_SCENE

func _ready():
	$DoorScreenTransition/ColorRect.color = Color(0,0,0,0)

#func transition_menu(selected_option):
#	if selected_option == 1:
#		transition_type = transitionType.PARTY_SCREEN
#	elif selected_option == 3:
#		transition_type = transitionType.PLAYER_STATS
#	else:
#		transition_type = transitionType.MENU_ONLY
#	$DoorScreenTransition/AnimationPlayer.play("FadeToWhite")
#
	
func battle_transition():
	transition_type = transitionType.BATTLE
	$DoorScreenTransition/AnimationPlayer.play("FadeToWhite")
	
func transition_from_battle(new_scene:String,spawn_location,spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = transitionType.FROM_BATTLE
	$DoorScreenTransition/AnimationPlayer.play("FadeToWhite")

func transition_to_scene(new_scene:String,spawn_location,spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = transitionType.NEW_SCENE
	$DoorScreenTransition/AnimationPlayer.play("FadeToBlack")
	
func transition_from_main(new_scene:String,spawn_location,spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = transitionType.FROM_MAIN_MENU
	$DoorScreenTransition/AnimationPlayer.play("FadeToBlack")
	
	
	
func finished_fading():
	match transition_type:
		transitionType.NEW_SCENE:
			$CurrentScene.get_child(0).queue_free()
			$CurrentScene.add_child(load(next_scene).instance())
			var player = Utils.get_player()
			player.set_spawn(Vector2(player_location.x,player_location.y), Vector2(player_direction.x,player_direction.y))
			$DoorScreenTransition/AnimationPlayer.play("FadeFromBlack")
#		transitionType.BATTLE:
#			$CurrentScene.get_child(0).queue_free()
#			$CurrentScene.add_child(load("res://src/scenes/Battles/WildBattle.tscn").instance())
#			$InGameMenu.queue_free()
#			$DoorScreenTransition/AnimationPlayer.play("FadeFromWhite")
#		transitionType.FROM_BATTLE:
#			$CurrentScene.get_child(0).queue_free()
#			GlobalVariables.is_in_dialogue = false
#			$CurrentScene.add_child(load(next_scene).instance())
#			self.add_child(load("res://src/scenes/UI/Menu.tscn").instance())
#			var player = Utils.get_player()
#			player.set_spawn(player_location,player_direction)
#			$DoorScreenTransition/AnimationPlayer.play("FadeFromWhite")
		transitionType.FROM_MAIN_MENU:
			$CurrentScene.get_child(0).queue_free()
			$CurrentScene.add_child(load(next_scene).instance())
			self.add_child(load("res://src/InGameMenu/Menu.tscn").instance())
			var player = Utils.get_player()
			player.set_spawn(Vector2(player_location.x,player_location.y), Vector2(player_direction.x,player_direction.y))
			$DoorScreenTransition/AnimationPlayer.play("FadeFromBlack")
