@tool
extends VBoxContainer

signal refresh

const ADDON_SETTINGS_FILE_PATH = "res://addons/album_manager/settings.cfg"
const ARRAY_NAME = "album_list"
const AUTOSAVE_AFTER_INPUT_COOLDOWN := 2.0 # seconds

#@export var album : AlbumData
#@export var album_collection : AlbumCollection # unused, just for checking

@onready var main_ui_vbox: VBoxContainer = %MainUIVbox
@onready var album_collection_loader: FileDialog = $AlbumCollectionLoader
@onready var imported_path: TextEdit = %ImportedPath
@onready var create_new_btn: Button = %CreateNewBtn
@onready var close_current_btn: Button = %CloseCurrentBtn
@onready var autosave_cooldown_timer: Timer = $AutosaveCooldownTimer

enum Mode {LOAD_EXISTING, CREATE_NEW}

var current_filedialog_mode := Mode.LOAD_EXISTING
var loaded_settings := ConfigFile.new()

var current_albumcol_path_pair : Dictionary[String, AlbumCollection]
#var editor_test_panel

func _on_refresh_btn_pressed() -> void:
	print("---")
	attempt_save_resource_changes()
	refresh.emit()

func attempt_save_resource_changes(do_print_message := true):
	if not current_albumcol_path_pair.is_empty():
		var album_col_path_key : String = current_albumcol_path_pair.keys()[0]
		if FileAccess.file_exists(album_col_path_key):
			ResourceSaver.save(current_albumcol_path_pair[album_col_path_key], album_col_path_key)
			if do_print_message:
				print("Changes to resource %s saved." % album_col_path_key)

func save_on_property_changed():
	if autosave_cooldown_timer.get_time_left() == 0.0:
		autosave_cooldown_timer.start()
		attempt_save_resource_changes(false)

func _on_autosave_cooldown_timer_timeout() -> void:
	attempt_save_resource_changes(false)

func _ready() -> void:
	album_collection_loader.hide()
	close_current_btn.hide()
	autosave_cooldown_timer.wait_time = AUTOSAVE_AFTER_INPUT_COOLDOWN
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
	current_albumcol_path_pair.clear()
	imported_path.text = ""
	if FileAccess.file_exists(path):
		var album_collection = ResourceLoader.load(path)
		
		if (album_collection == Resource.new()) or album_collection is not AlbumCollection:
			push_warning("Invalid selected resource. Must be an AlbumCollection.")
			return false
			
		main_ui_vbox.init_albumgroups(album_collection, ARRAY_NAME)
		main_ui_vbox.connect_signals_to_save(save_on_property_changed)
		current_albumcol_path_pair[path] = album_collection
		return true
		
	else:
		push_warning("Selected/saved path is invalid.")
		return false

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

# Connected from album_manager.gd
#@TODO Somehow this was not needed?
#func _on_any_scene_saved(_filepath : String):
	#if not current_albumcol_path_pair.is_empty():
		#var album_col_path_key : String = current_albumcol_path_pair.keys()[0]
		#var album_col_before_save := ResourceLoader.load(album_col_path_key)
		#print("compare: %s vs %s " % [	str(album_col_before_save.get_rid()),
										#str(current_albumcol_path_pair[album_col_path_key].get_rid())
									#])
		#if album_col_before_save != current_albumcol_path_pair[album_col_path_key]:
			#ResourceSaver.save(current_albumcol_path_pair[album_col_path_key], album_col_path_key)
			#print("Changes to resource %s saved." % album_col_path_key)
