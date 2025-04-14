@tool
extends PanelContainer

signal remove_this_panel

const INTERNAL_RESOURCE_PROP_NAMES := \
	["resource_local_to_scene", "resource_name", "metadata/_custom_type_script"]

const TITLE_IDENTIFIER_CONSTNAME := "title_identifier"

@export var song_data : SongData

@onready var item_vbox: VBoxContainer = %PanelUIVbox
@onready var song_title_label: Label = %SongTitleLabel
@onready var inspector_below_here: Node = %InspectorBelowHere

var propname_edprop_map : Dictionary[String, EditorProperty]
var mini_inspector_vbox : VBoxContainer
var prop_title_varname : String

func fill_data(data : Resource):
	song_data = data
	init_panel()

func init_panel():
	var mini_inspector := EditorInspector.new()
	mini_inspector.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mini_inspector.size_flags_vertical = SIZE_EXPAND_FILL
	#mini_inspector.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mini_inspector.custom_minimum_size.y = self.custom_minimum_size.y + 30.0
	mini_inspector.draw_focus_border = false

	#mini_inspector.size_flags_horizontal = SIZE_EXPAND_FILL
	#item_vbox.add_child(mini_inspector)
	inspector_below_here.add_sibling(mini_inspector)
	
	mini_inspector_vbox = VBoxContainer.new()
	mini_inspector_vbox.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mini_inspector_vbox.size_flags_vertical = SIZE_EXPAND_FILL
	mini_inspector_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	mini_inspector.add_child(mini_inspector_vbox)
	
	if song_data:
		var data_dict_list : Array[Dictionary]
		for prop_dict : Dictionary in song_data.get_property_list():
			# custom exported variables
			if prop_dict["usage"] == 6 and (prop_dict["name"] not in INTERNAL_RESOURCE_PROP_NAMES):
				#print(prop_dict)
				data_dict_list.append(prop_dict)
			elif prop_dict["name"] == 'script' and prop_dict["class_name"] == 'Script':
				var res_script : Script = song_data.get(prop_dict["name"])
				var res_class_name = res_script.get_global_name()
				var script_const_map := res_script.get_script_constant_map()
				if TITLE_IDENTIFIER_CONSTNAME in script_const_map:
					# the variable name that's responsible to the song name
					prop_title_varname = res_script[TITLE_IDENTIFIER_CONSTNAME]
				
		for data_prop_dict : Dictionary in data_dict_list:
			#print(data_prop_dict)
			var prop_name : String = data_prop_dict["name"]
			if prop_name == prop_title_varname:
				song_title_label.text = song_data.get(prop_name)
				#@TODO probably continue here
			var prop_editor : EditorProperty = EditorInspector.instantiate_property_editor(
				song_data,
				data_prop_dict["type"],
				prop_name,
				data_prop_dict["hint"],
				data_prop_dict["hint_string"],
				data_prop_dict["usage"]
			)
			mini_inspector_vbox.add_child(prop_editor)
			prop_editor.set_object_and_property(song_data, prop_name)
			prop_editor.label = prop_name.capitalize()
			prop_editor.name_split_ratio = 0.4
			prop_editor.property_changed.connect(_prop_changed)
			prop_editor.selected.connect(_prop_selected)
			prop_editor.update_property()
			propname_edprop_map[prop_name] = prop_editor
		print("panel initiated")
		#@TODO make the textedit longer than the label name
		#for edprop in mini_inspector_vbox.get_children():
			#edprop.print_tree_pretty()
			#break

func _prop_changed(p_property: String, p_value, p_field: StringName, p_changing: bool) -> void:
	if p_property == prop_title_varname:
		song_title_label.text = p_value
	song_data.set(p_property, p_value)
	if typeof(p_value) >= TYPE_ARRAY:
		propname_edprop_map[p_property].update_property()

func _prop_selected(p_path:String, p_focusable: int) -> void:
	for edprop in mini_inspector_vbox.get_children():
		if edprop is EditorProperty:
			if edprop == propname_edprop_map[p_path]:
				continue
			if edprop.is_selected():
				edprop.deselect()

func print_prop(res : Resource):
	print("---")
	for prop_dict : Dictionary in res.get_property_list():
		print(prop_dict)
	print("---")

func _on_remove_btn_pressed() -> void:
	remove_this_panel.emit()
