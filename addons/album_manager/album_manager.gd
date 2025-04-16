@tool
extends EditorPlugin

#const InspectorPlugin = preload("res://addons/album_manager/scripts/inspector_plugin.gd")
const ALBUM_MANAGER_SCENE_PATH = "uid://bs3f7leqohnnl"

var album_manager_node : Node
var inspector_plugin_inst

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		load_addon_mainscreen()
		pass

func load_addon_mainscreen():
	album_manager_node = load(ALBUM_MANAGER_SCENE_PATH).instantiate()
	
	EditorInterface.get_editor_main_screen().add_child(album_manager_node)
	_make_visible(false)
	#var inspector_plugin_inst = InspectorPlugin.new()
	#add_inspector_plugin(inspector_plugin_inst)

func _ready() -> void:
	if Engine.is_editor_hint():
		album_manager_node.refresh.connect(_on_addon_refresh)
		#scene_saved.connect(album_manager_node._on_any_scene_saved)
		
		#EditorInterface.get_inspector().edited_object_changed.connect(_on_addon_refresh)

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		if album_manager_node:
			album_manager_node.queue_free()
		#remove_inspector_plugin(inspector_plugin_inst)

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
		album_manager_node.refresh.disconnect(_on_addon_refresh)
		#scene_saved.disconnect(album_manager_node._on_any_scene_saved)
		album_manager_node.queue_free()
		#remove_inspector_plugin(inspector_plugin_inst)
		load_addon_mainscreen()
		album_manager_node.refresh.connect(_on_addon_refresh)
		#scene_saved.connect(album_manager_node._on_any_scene_saved)
		album_manager_node.visible = true
		print("Album Manager refreshed")
		print("---")
		
		
