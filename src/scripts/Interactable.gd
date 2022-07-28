extends Area2D


const dialogue_box = preload("res://src/DialogueBox/DialogueBox.tscn")
export var dialogue_id = "0"

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = Utils.get_player()
	player.connect("player_clicked_interactable_signal",self,"create_dialogue_box")


func create_dialogue_box(dialo_id):
	if dialo_id == dialogue_id:
		GlobalVariables.is_in_dialogue = true
		var dialogue = dialogue_box.instance()
		dialogue.dialogue_lines = DataHelper.dialogue_data[dialogue_id]
		dialogue.connect("dialogue_box_closed",self,"dialogue_closed")
		add_child(dialogue)
	
func dialogue_closed():
	Utils.get_player().set_physics_process(true)
	Utils.get_player().interactRay.enabled = true
	GlobalVariables.is_in_dialogue = false

