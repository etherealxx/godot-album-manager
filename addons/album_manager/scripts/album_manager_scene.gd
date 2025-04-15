@tool
extends VBoxContainer

signal refresh

const ARRAY_NAME = "album_list"

#@export var album : AlbumData
#@export var album_collection : AlbumCollection

@onready var main_ui_vbox: VBoxContainer = %MainUIVbox
@onready var album_collection_loader: FileDialog = $AlbumCollectionLoader
@onready var imported_path: TextEdit = %ImportedPath

var editor_test_panel

func _on_refresh_btn_pressed() -> void:
	print("---")
	refresh.emit()

func _ready() -> void:
	album_collection_loader.hide()
	#if Engine.is_editor_hint():
		#main_ui_vbox.init_albumgroups(album_collection, ARRAY_NAME)

func _exit_tree() -> void:
	if editor_test_panel and Engine.is_editor_hint():
		editor_test_panel.queue_free()

func _on_import_btn_pressed() -> void:
	album_collection_loader.show()

func _on_album_collection_loader_file_selected(path: String) -> void:
	if Engine.is_editor_hint():
		var album_collection = ResourceLoader.load(path)
		if (album_collection == Resource.new()) or album_collection is not AlbumCollection:
			push_warning("Invalid selected resource. Must be an AlbumCollection")
			
			return
		imported_path.text = path
		main_ui_vbox.init_albumgroups(album_collection, ARRAY_NAME)
		print("Album Collection on %s loaded" % path)
