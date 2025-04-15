@tool
extends InspectorSpawner

signal remove_this_panel

#@export var song_data : SongData

@onready var song_title_label: Label = %SongTitleLabel

var song_data : SongData

func _ready() -> void:
	inspector_below_here = %InspectorBelowHere

func _miniinspector_anchor_sizeflag_override(mini_inspector : Control):
	mini_inspector.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mini_inspector.custom_minimum_size.y = self.custom_minimum_size.y + 30.0

func _inspectorvbox_anchor_sizeflag_override(mini_inspector_vbox : VBoxContainer):
	mini_inspector_vbox.size_flags_horizontal = SIZE_EXPAND_FILL

func _propname_matchcase_override(res_to_edit : Resource, prop_name : String):
	match prop_name:
		prop_title_varname:
			song_title_label.text = res_to_edit.get(prop_name)

func _prop_changed_override(prop : String, value : Variant):
	if prop == prop_title_varname:
		song_title_label.text = value
	pass

func fill_data(data : Resource):
	song_data = data
	instantiate_inspector(song_data)
	#init_panel()

func print_prop(res : Resource):
	print("---")
	for prop_dict : Dictionary in res.get_property_list():
		print(prop_dict)
	print("---")

func _on_remove_btn_pressed() -> void:
	remove_this_panel.emit()
