@tool
extends InspectorSpawner

signal remove_this_albumgroup

const SONG_PANEL = preload("res://addons/album_manager/scenes/song_panel.tscn")

@onready var songpanels_hflow: HFlowContainer = $SongPanelListHFlow
@onready var album_name_btn: CheckButton = %AlbumNameBtn
@onready var album_cover: TextureRect = %AlbumCover

var album_ref : AlbumData
#var albumlist_index : int

func _ready() -> void:
	inspector_below_here = %InspectorBelowHere

func _miniinspector_anchor_sizeflag_override(mini_inspector : Control):
	mini_inspector.size_flags_horizontal = SIZE_SHRINK_BEGIN
	mini_inspector.custom_minimum_size.y = 110.0

func _inspectorvbox_anchor_sizeflag_override(mini_inspector_vbox : VBoxContainer):
	mini_inspector_vbox.custom_minimum_size.x = 300.0

func _skip_if_true_override(res_to_edit : Resource, prop_dict : Dictionary) -> bool:
	if prop_dict["type"] == TYPE_ARRAY:
		if res_to_edit.get(prop_dict["name"]) == res_array_ref:
			return true
	
	return false

func _propname_matchcase_override(res_to_edit : Resource, prop_name : String):
	match prop_name:
		prop_title_varname:
			album_name_btn.text = res_to_edit.get(prop_name)
		prop_cover_varname:
			album_cover.texture = res_to_edit.get(prop_name)

func _after_init_override():
	mini_inspector.hide()

func _prop_changed_override(prop_name : String, value : Variant):
	match (prop_name):
		prop_title_varname:
			album_name_btn.text = value
		prop_cover_varname:
			album_cover.texture = value

func init_songpanels(album : Resource, song_list : Array):
	instantiate_inspector(album, song_list)
	for song : Resource in song_list:
		instantiate_songpanel(song, song_list)
	%AddItemBtn.pressed.connect(_on_add_item_pressed.bind(song_list))

func instantiate_songpanel(song : Resource, song_list_ref : Array):
	var new_songpanel : Control = SONG_PANEL.instantiate()
	songpanels_hflow.add_child(new_songpanel)
	new_songpanel.fill_data(song)
	new_songpanel.remove_this_panel.connect(_on_songpanel_remove.bind(new_songpanel, song_list_ref))
	songpanels_hflow.move_child(%AddItemBtn, -1)

func get_songpanel_list() -> Node:
	return songpanels_hflow

#func set_albumlist_index(idx : int):
	#albumlist_index = idx

func _on_add_item_pressed(song_list : Array):
	EditorInterface.mark_scene_as_unsaved()
	var new_songdata = SongData.new()
	#for line in new_songdata.get_property_list():
		#print(line)
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

func _on_album_name_btn_toggled(toggled_on: bool) -> void:
	if self.is_ancestor_of(mini_inspector):
		#print("visible %s" % toggled_on)
		mini_inspector.visible = toggled_on

func _on_remove_btn_pressed() -> void:
	EditorInterface.mark_scene_as_unsaved()
	remove_this_albumgroup.emit()
