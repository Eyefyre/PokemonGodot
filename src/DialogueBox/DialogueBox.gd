extends CanvasLayer


var dialogue_lines = ["PALLET TOWN","Shades of your","journey await!"]
var latest_page = 0
var scroll_num = 0
var should_scroll = false

signal dialogue_box_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(len(dialogue_lines)):
		dialogue_lines[x] = dialogue_lines[x].replace("<<PLAYER>>", GlobalVariables.player_name)
		dialogue_lines[x] = dialogue_lines[x].replace("<<RIVAL>>", GlobalVariables.rival_name)
	$NinePatchRect/RichTextLabel.set_visible_characters(0)
	if len(dialogue_lines) <= 2:
		$NinePatchRect/AnimationPlayer.stop()
		$NinePatchRect/TextureRect.visible = false
		if len(dialogue_lines) == 1:
			$NinePatchRect/RichTextLabel.set_bbcode(dialogue_lines[0])
		else:
			$NinePatchRect/RichTextLabel.set_bbcode(dialogue_lines[0] + "\n" +  dialogue_lines[1] + "\n")
	else:
		$NinePatchRect/RichTextLabel.set_bbcode(dialogue_lines[0] + "\n" +  dialogue_lines[1] + "\n")
		latest_page = 1
		
		

func _unhandled_input(event):
	if event.is_action_pressed("Accept"):
		if $NinePatchRect/RichTextLabel.get_visible_characters() < $NinePatchRect/RichTextLabel.get_total_character_count():
			$NinePatchRect/RichTextLabel.set_visible_characters($NinePatchRect/RichTextLabel.get_total_character_count())
		elif len(dialogue_lines) <= 2 or latest_page == dialogue_lines.size()-1:
			emit_signal("dialogue_box_closed")
			self.queue_free()
		elif latest_page < dialogue_lines.size()-1:
			$NinePatchRect/RichTextLabel.set_visible_characters($NinePatchRect/RichTextLabel.get_total_character_count())
			$NinePatchRect/RichTextLabel.set_bbcode($NinePatchRect/RichTextLabel.get_bbcode() + dialogue_lines[latest_page+1] + "\n")
			latest_page += 1
			$NinePatchRect/ScrollTimer.start()
			if latest_page == dialogue_lines.size()-1:
				$NinePatchRect/AnimationPlayer.stop()
				$NinePatchRect/TextureRect.visible = false

func _on_Timer_timeout():
	$NinePatchRect/RichTextLabel.set_visible_characters($NinePatchRect/RichTextLabel.get_visible_characters()+1)


func _on_ScrollTimer_timeout():
	$NinePatchRect/RichTextLabel.get_v_scroll().set_value($NinePatchRect/RichTextLabel.get_v_scroll().value+1)
	scroll_num += 1
	if scroll_num > 14.5:
		$NinePatchRect/ScrollTimer.stop()
		scroll_num = 0
