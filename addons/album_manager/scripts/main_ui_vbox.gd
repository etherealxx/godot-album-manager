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
	var i := 0
	var album_list = album_collection.get(prop_name)
	for album in album_list: # for album in albumlist
		instantiate_albumgroup(album, album_list, album.song_list)
		i += 1
	add_item_btn.show()
	add_item_btn.pressed.connect(_on_add_item_pressed.bind(album_list))

func instantiate_albumgroup(album : Resource, album_list : Array, album_song_list : Array = Array()): #@TODO maybe remove album_song_list if unused
	var new_albumgroup = ALBUM_GROUP_VBOX.instantiate()
	add_child(new_albumgroup)
	new_albumgroup.init_songpanels(album, album.song_list)
	#new_albumgroup.set_albumlist_index(albumlist_index)
	#print("all value: %s, %s, %s" %[str(new_albumgroup), str(album), str(album_song_list)])
	new_albumgroup.remove_this_albumgroup.connect(_on_albumgroup_remove.bind(new_albumgroup, album, album_list))
	move_child(add_item_btn, -1)

func clear_albumgroup():
	add_btn_disconnect_signal()
	for albumgroup in self.get_children():
		if albumgroup.is_in_group("albumgroup"):
			queue_free()
	add_item_btn.hide()

func _on_add_item_pressed(album_list : Array):
	EditorInterface.mark_scene_as_unsaved()
	var new_albumdata = AlbumData.new()
	#for line in new_songdata.get_property_list():
		#print(line)
	album_list.append(new_albumdata)
	instantiate_albumgroup(new_albumdata, album_list)

func _on_albumgroup_remove(albumgroup_to_remove : Control, album : Resource, album_list_ref : Array):
	album_list_ref.erase(album)
	albumgroup_to_remove.queue_free()
	#recalculate_albumgroup_indexes()
#
#func recalculate_albumgroup_indexes():
	#var i := 0
	#for albumgroup in self.get_children():
		#if albumgroup.is_in_group("albumgroup"):
			#albumgroup.set_albumlist_index(i)
			#i += 1
