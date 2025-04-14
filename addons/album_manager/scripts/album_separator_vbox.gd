@tool
extends VBoxContainer

const SONG_PANEL = preload("res://addons/album_manager/scenes/song_panel.tscn")

@onready var songpanels_hflow: HFlowContainer = $SongPanelListHFlow

func init_songpanels(album : Resource, song_list : Array):
	for song : Resource in song_list:
		instantiate_songpanel(song, song_list)
	%AddItemBtn.pressed.connect(_on_add_item_pressed.bind(song_list))

#func _on_add_item_pressed(album : Resource):
	#Array().append()
func instantiate_songpanel(song : Resource, song_list_ref : Array):
	var new_songpanel : Control = SONG_PANEL.instantiate()
	songpanels_hflow.add_child(new_songpanel)
	new_songpanel.fill_data(song)
	new_songpanel.remove_this_panel.connect(_on_songpanel_remove.bind(new_songpanel, song_list_ref))
	songpanels_hflow.move_child(%AddItemBtn, -1)

func _on_add_item_pressed(song_list : Array):
	var new_songdata = SongData.new()
	song_list.append(new_songdata)
	instantiate_songpanel(new_songdata, song_list)

func _on_songpanel_remove(panel_to_remove : Control, song_list_ref : Array):
	song_list_ref.erase(panel_to_remove.song_data)
	panel_to_remove.queue_free()
	
func _exit_tree() -> void:
	if Engine.is_editor_hint():
		for panel in songpanels_hflow.get_children():
			if panel.is_in_group("songpanel"):
				panel.queue_free()
