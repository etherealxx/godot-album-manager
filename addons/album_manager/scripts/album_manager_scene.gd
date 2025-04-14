@tool
extends VBoxContainer

signal refresh

const ARRAY_NAME = "album_list"

@export var album : AlbumData
@export var album_collection : AlbumCollection

#@onready var album_separator_vbox: VBoxContainer = %AlbumGroupVbox
@onready var main_ui_vbox: VBoxContainer = %MainUIVbox

var editor_test_panel

func _on_refresh_btn_pressed() -> void:
	print("---")
	refresh.emit()

func _ready() -> void:
	if Engine.is_editor_hint():
		main_ui_vbox.init_albumgroups(album_collection, ARRAY_NAME)
		#for song_panel in song_panel_list_hbox.get_children():
			#if song_panel.has_method("init_panel"):
				#song_panel.init_panel()

func _exit_tree() -> void:
	if editor_test_panel and Engine.is_editor_hint():
		editor_test_panel.queue_free()
