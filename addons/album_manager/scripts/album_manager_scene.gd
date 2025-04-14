@tool
extends VBoxContainer

signal refresh

@export var album : AlbumData
@export var album_list : AlbumCollection

@onready var album_separator_vbox: VBoxContainer = %AlbumSeparatorVbox

var editor_test_panel

func _on_refresh_btn_pressed() -> void:
	print("---")
	refresh.emit()

func _ready() -> void:
	album_separator_vbox.init_songpanels(album, album.song_list)
	#for song_panel in song_panel_list_hbox.get_children():
		#if song_panel.has_method("init_panel"):
			#song_panel.init_panel()

func _on_instance_test_btn_pressed() -> void:
	#var mini_inspector := EditorInspector.new()
	#mini_inspector.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	#editor_test_panel.add_child(mini_inspector)
	#var mini_inspector_vbox : VBoxContainer = mini_inspector.get_child(0)
	#var mini_inspector_vbox := VBoxContainer.new()
	#mini_inspector_vbox.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	#mini_inspector.add_child(mini_inspector_vbox)
	
	var vbox := VBoxContainer.new()
	editor_test_panel.add_child(vbox)
	
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var mini_inspector_vbox = VBoxContainer.new()
	scroll.add_child(mini_inspector_vbox)
	mini_inspector_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	
	if editor_test_panel.song_data:
		#mini_inspector.edit(editor_test_panel.song_data)
		#mini_inspector.print_tree_pretty()
		var prop_editor : EditorProperty = EditorInspector.instantiate_property_editor(
			editor_test_panel.song_data, 
			4,				#data_prop_dict["type"],
			"song_title",	#data_prop_dict["name"],
			0,				#data_prop_dict["hint"],
			"",				#data_prop_dict["hint_string"],
			6				#data_prop_dict["usage"]
		)
		#var inspector_vbox_get
		mini_inspector_vbox.add_child(prop_editor)
		prop_editor.set_object_and_property(editor_test_panel.song_data, "song_title")
		prop_editor.label = "song_title"
		#prop_editor.property_changed.connect(_prop_changed)
		#prop_editor.selected.connect(_prop_selected)
		prop_editor.update_property()

func _exit_tree() -> void:
	if editor_test_panel and Engine.is_editor_hint():
		editor_test_panel.queue_free()
