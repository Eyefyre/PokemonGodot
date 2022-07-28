extends Area2D


const dialogue_box = preload("res://src/DialogueBox/DialogueBox.tscn")
export var dialogue_id = "12"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = Utils.get_player()
	player.connect("player_cut_tree_signal",self,"cut_tree")


func cut_tree():
	GlobalVariables.is_in_dialogue = true
	var dialogue = dialogue_box.instance()
	if GlobalVariables.has_cut:
		if GlobalVariables.badges[1]:
			dialogue.dialogue_lines = DataHelper.dialogue_data["13"]
		else:
			dialogue.dialogue_lines = DataHelper.dialogue_data["14"]
	else:
		dialogue.dialogue_lines = DataHelper.dialogue_data["12"]
	dialogue.connect("dialogue_box_closed",self,"dialogue_closed")
	add_child(dialogue)

func dialogue_closed():
	if GlobalVariables.has_cut and GlobalVariables.badges[1]:
		queue_free()
	Utils.get_player().set_physics_process(true)
	Utils.get_player().cuttreeRay.enabled = true
	GlobalVariables.is_in_dialogue = false
