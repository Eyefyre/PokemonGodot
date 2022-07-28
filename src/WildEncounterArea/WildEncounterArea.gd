extends Node2D

const grass_overlay_texture = preload("res://assets/images/TallGrassOverlay.png")
var grass_overlay: TextureRect = null
export var area_id = 1
export var tile_density = 25

var player_inside: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.get_player().connect("player_moving_signal",self,"player_exiting_grass")
	Utils.get_player().connect("player_stopped_signal",self,"player_in_grass")


func player_exiting_grass():
	player_inside = false
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()
	
func player_in_grass():
	if player_inside:
		check_encounter()
#		grass_overlay = TextureRect.new()
#		grass_overlay.texture = grass_overlay_texture
#		grass_overlay.rect_position = position
#		get_tree().current_scene.add_child(grass_overlay)
		
func check_encounter():
	var player_dir = DataHelper.convert_int_to_vector2(Utils.get_player().facing_direction)
	var encounter_number = DataHelper.generate_random_number(1,256)
	if encounter_number <= tile_density:
		var battle_data = DataHelper.generate_encounter(area_id)
		GlobalVariables.wild_encounter_data = battle_data
		GlobalVariables.current_scene = Utils.get_current_scene().filename
		GlobalVariables.player_facing_direction = player_dir
		GlobalVariables.player_position = Utils.get_player().position
#		if is_instance_valid(grass_overlay):
#			grass_overlay.queue_free()
		Utils.get_scene_manager().battle_transition()


func _on_Area2D_body_entered(_body):
	player_inside = true


func _on_Area2D_body_exited(_body):
	pass
