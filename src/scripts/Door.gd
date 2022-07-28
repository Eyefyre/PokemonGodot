extends Area2D

export(String, FILE) var next_scene_path = ""


export(Vector2) var spawn_location = Vector2(0,0)
export(Vector2) var spawn_direction = Vector2(0,0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_entered = false


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = Utils.get_player()
	player.connect("player_entering_door_signal",self,"enter_door")


func enter_door():
	if player_entered:
		Utils.get_scene_manager().transition_to_scene(next_scene_path,spawn_location,spawn_direction)


func _on_Door_body_entered(_body):
	player_entered = true


func _on_Door_body_exited(_body):
	player_entered = false
