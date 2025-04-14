@tool
extends VBoxContainer

const SONG_PANEL = preload("res://addons/album_manager/scenes/song_panel.tscn")

const INTERNAL_RESOURCE_PROP_NAMES := \
	["resource_local_to_scene", "resource_name", "metadata/_custom_type_script"]

const TITLE_IDENTIFIER_CONSTNAME := "title_identifier"
const COVER_IDENTIFIER_CONSTNAME := "cover_identifier"

@onready var songpanels_hflow: HFlowContainer = $SongPanelListHFlow
@onready var inspector_below_here: Node = %InspectorBelowHere
@onready var album_name_btn: CheckButton = %AlbumNameBtn
@onready var album_cover: TextureRect = %AlbumCover

var propname_edprop_map : Dictionary[String, EditorProperty]
var mini_inspector : EditorInspector
var mini_inspector_vbox : VBoxContainer
var prop_title_varname : String
var prop_cover_varname : String
var album_ref : AlbumData

func init_songpanels(album : Resource, song_list : Array):
	instantiate_inspector(album, song_list)
	for song : Resource in song_list:
		instantiate_songpanel(song, song_list)
	%AddItemBtn.pressed.connect(_on_add_item_pressed.bind(song_list))

func instantiate_inspector(album : Resource, song_list_ref : Array):
	album_ref = album
	mini_inspector = EditorInspector.new()
	#mini_inspector.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	#mini_inspector.custom_minimum_size.x = 300.0
	mini_inspector.size_flags_horizontal = SIZE_SHRINK_BEGIN
	mini_inspector.size_flags_vertical = SIZE_EXPAND_FILL
	mini_inspector.custom_minimum_size.y = 110.0
	mini_inspector.draw_focus_border = false
	mini_inspector.focus_exited.connect(_on_mini_inspector_focus_exited)

	inspector_below_here.add_sibling(mini_inspector)
	
	mini_inspector_vbox = VBoxContainer.new()
	mini_inspector_vbox.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mini_inspector_vbox.size_flags_vertical = SIZE_EXPAND_FILL
	#mini_inspector_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	mini_inspector_vbox.custom_minimum_size.x = 300.0
	mini_inspector.add_child(mini_inspector_vbox)
	
	var data_dict_list : Array[Dictionary]
	for prop_dict : Dictionary in album.get_property_list():
		# Custom exported variables
		if prop_dict["usage"] in [6, 4102] and (prop_dict["name"] not in INTERNAL_RESOURCE_PROP_NAMES):
			# Skip the song array as it's already handled by the songpanels
			if prop_dict["type"] == TYPE_ARRAY:
				if album.get(prop_dict["name"]) == song_list_ref:
					continue
			data_dict_list.append(prop_dict)
		elif prop_dict["name"] == 'script' and prop_dict["class_name"] == 'Script':
			var res_script : Script = album.get(prop_dict["name"])
			var res_class_name = res_script.get_global_name()
			var script_const_map := res_script.get_script_constant_map()
			if TITLE_IDENTIFIER_CONSTNAME in script_const_map:
				# The variable name that's responsible to the song name
				prop_title_varname = res_script[TITLE_IDENTIFIER_CONSTNAME]
			if COVER_IDENTIFIER_CONSTNAME in script_const_map:
				prop_cover_varname = res_script[COVER_IDENTIFIER_CONSTNAME]
			
	for data_prop_dict : Dictionary in data_dict_list:
		#print(data_prop_dict)
		var prop_name : String = data_prop_dict["name"]
		
		match (prop_name):
			prop_title_varname:
				album_name_btn.text = album.get(prop_name)
			prop_cover_varname:
				album_cover.texture = album.get(prop_name)
				
		var prop_editor : EditorProperty = EditorInspector.instantiate_property_editor(
			album,
			data_prop_dict["type"],
			prop_name,
			data_prop_dict["hint"],
			data_prop_dict["hint_string"],
			data_prop_dict["usage"]
		)
		mini_inspector_vbox.add_child(prop_editor)
		prop_editor.set_object_and_property(album, prop_name)
		prop_editor.label = prop_name.capitalize()
		prop_editor.name_split_ratio = 0.4
		prop_editor.property_changed.connect(_prop_changed)
		prop_editor.selected.connect(_prop_selected)
		prop_editor.update_property()
		propname_edprop_map[prop_name] = prop_editor
	print("albumpanel initiated")
	mini_inspector.hide()

func _on_mini_inspector_focus_exited():
	for edprop in mini_inspector_vbox.get_children():
		if edprop is EditorProperty:
			edprop.deselect()

func _prop_changed(p_property: String, p_value, p_field: StringName, p_changing: bool) -> void:
	if p_property == prop_title_varname:
		album_name_btn.text = p_value
	album_ref.set(p_property, p_value)
	if typeof(p_value) >= TYPE_ARRAY:
		propname_edprop_map[p_property].update_property()

func _prop_selected(p_path:String, p_focusable: int) -> void:
	for edprop in mini_inspector_vbox.get_children():
		if edprop is EditorProperty:
			if edprop == propname_edprop_map[p_path]:
				continue
			if edprop.is_selected():
				edprop.deselect()
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
	for line in new_songdata.get_property_list():
		print(line)
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
		print("visible %s" % toggled_on)
		mini_inspector.visible = toggled_on
