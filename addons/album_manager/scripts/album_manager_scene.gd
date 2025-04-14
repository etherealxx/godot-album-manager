@tool
extends VBoxContainer

signal refresh

@export var album : AlbumData
@export var album_list : AlbumCollection

@onready var album_separator_vbox: VBoxContainer = %AlbumGroupVbox

var editor_test_panel

func _on_refresh_btn_pressed() -> void:
	print("---")
	refresh.emit()

func _ready() -> void:
	if Engine.is_editor_hint():
		album_separator_vbox.init_songpanels(album, album.song_list)
		#for song_panel in song_panel_list_hbox.get_children():
			#if song_panel.has_method("init_panel"):
				#song_panel.init_panel()

func _exit_tree() -> void:
	if editor_test_panel and Engine.is_editor_hint():
		editor_test_panel.queue_free()
