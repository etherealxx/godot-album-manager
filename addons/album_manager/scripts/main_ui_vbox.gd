@tool
extends VBoxContainer

const ALBUM_GROUP_VBOX = preload("res://addons/album_manager/scenes/album_group_vbox.tscn")

@onready var add_item_btn: Button = $AddItemBtn

func _ready() -> void:
	add_item_btn.hide()

func add_btn_disconnect_signal():
	if add_item_btn.is_connected("pressed", _on_add_item_pressed):
		add_item_btn.pressed.disconnect(_on_add_item_pressed)

func init_albumgroups(album_collection : Resource, prop_name : String):
	add_btn_disconnect_signal()
	for album in album_collection.get(prop_name):
		instantiate_albumgroup(album, album.song_list)
	add_item_btn.show()
	add_item_btn.pressed.connect(
		_on_add_item_pressed.bind(album_collection.get(prop_name)
	))

func instantiate_albumgroup(album : Resource, album_list : Array):
	var new_albumgroup = ALBUM_GROUP_VBOX.instantiate()
	add_child(new_albumgroup)
	new_albumgroup.init_songpanels(album, album.song_list)
	new_albumgroup.remove_this_panel.connect(_on_albumgroup_remove.bind(new_albumgroup, album, album_list))
	move_child(add_item_btn, -1)

func clear_albumgroup():
	add_btn_disconnect_signal()
	for albumgroup in self.get_children():
		if albumgroup.is_in_group("albumgroup"):
			queue_free()
	add_item_btn.hide()

func _on_add_item_pressed(album_list : Array):
	var new_albumdata = AlbumData.new()
	#for line in new_songdata.get_property_list():
		#print(line)
	album_list.append(new_albumdata)
	instantiate_albumgroup(new_albumdata, album_list)

func _on_albumgroup_remove(panel_to_remove : Control, album : Resource, album_list_ref : Array):
	album_list_ref.erase(album)
	panel_to_remove.queue_free()
