@tool
extends EditorPlugin

var ALBUM_MANAGER_SCENE_PATH = "uid://bs3f7leqohnnl"

var album_manager_node : Node

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		load_addon_mainscreen()
		pass

func load_addon_mainscreen():
	album_manager_node = load(ALBUM_MANAGER_SCENE_PATH).instantiate()
	
	EditorInterface.get_editor_main_screen().add_child(album_manager_node)
	_make_visible(false)

func _ready() -> void:
	if Engine.is_editor_hint():
		album_manager_node.refresh.connect(_on_addon_refresh)
		pass

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		if album_manager_node:
			album_manager_node.queue_free()

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if album_manager_node:
		album_manager_node.visible = visible

func _get_plugin_name():
	return "Album Manager"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("AudioStreamPlayer", "EditorIcons")

func _on_addon_refresh():
	var editor_main_screen : Node = EditorInterface.get_editor_main_screen()
	if editor_main_screen.is_ancestor_of(album_manager_node):
		album_manager_node.queue_free()
		load_addon_mainscreen()
		album_manager_node.refresh.connect(_on_addon_refresh)
		album_manager_node.visible = true
		print("addon refreshed")
		
		
