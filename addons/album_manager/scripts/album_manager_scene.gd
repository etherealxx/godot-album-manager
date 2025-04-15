@tool
extends VBoxContainer

signal refresh

const ADDON_SETTINGS_FILE_PATH = "res://addons/album_manager/settings.cfg"
const ARRAY_NAME = "album_list"

#@export var album : AlbumData
#@export var album_collection : AlbumCollection

@onready var main_ui_vbox: VBoxContainer = %MainUIVbox
@onready var album_collection_loader: FileDialog = $AlbumCollectionLoader
@onready var imported_path: TextEdit = %ImportedPath
@onready var create_new_btn: Button = %CreateNewBtn
@onready var close_current_btn: Button = %CloseCurrentBtn

enum Mode {LOAD_EXISTING, CREATE_NEW}

var current_filedialog_mode := Mode.LOAD_EXISTING
var loaded_settings := ConfigFile.new()
var editor_test_panel

func _on_refresh_btn_pressed() -> void:
	print("---")
	refresh.emit()

func _ready() -> void:
	album_collection_loader.hide()
	close_current_btn.hide()
	if Engine.is_editor_hint():
		if FileAccess.file_exists(ADDON_SETTINGS_FILE_PATH):
			loaded_settings.load(ADDON_SETTINGS_FILE_PATH)
			var path_to_load = loaded_settings.get_value(
									"settings",
									"import_album_collection_path", "")
			var load_success = attempt_load_album_collection(path_to_load)
			if load_success:
				after_load_album_collection(path_to_load)

func attempt_load_album_collection(path : String) -> bool: # return the success status
	var album_collection = ResourceLoader.load(path)
	if (album_collection == Resource.new()) or album_collection is not AlbumCollection:
		push_warning("Invalid selected resource. Must be an AlbumCollection")
		imported_path.text = ""
		return false
	main_ui_vbox.init_albumgroups(album_collection, ARRAY_NAME)
	return true
	
func _on_import_btn_pressed() -> void:
	current_filedialog_mode = Mode.LOAD_EXISTING
	album_collection_loader.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	album_collection_loader.show()

func _on_album_collection_loader_file_selected(path: String) -> void:
	if Engine.is_editor_hint():
		match (current_filedialog_mode):
			Mode.LOAD_EXISTING:
				var load_success = attempt_load_album_collection(path)
				if !load_success: return
				
				loaded_settings.set_value("settings", "import_album_collection_path", path)
				loaded_settings.save(ADDON_SETTINGS_FILE_PATH)
				
				print("Album Collection on %s loaded" % path)
				
			Mode.CREATE_NEW:
				var new_album_collection = AlbumCollection.new()
				ResourceSaver.save(new_album_collection, path)
				main_ui_vbox.init_albumgroups(new_album_collection, ARRAY_NAME)
		
		after_load_album_collection(path)

func after_load_album_collection(path : String):
	imported_path.text = path
	create_new_btn.hide()
	close_current_btn.show()

func _on_create_new_btn_pressed() -> void:
	current_filedialog_mode = Mode.CREATE_NEW
	album_collection_loader.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	album_collection_loader.show()

func _on_close_current_btn_pressed() -> void:
	main_ui_vbox.clear_albumgroup()
	close_current_btn.hide()
	create_new_btn.show()
