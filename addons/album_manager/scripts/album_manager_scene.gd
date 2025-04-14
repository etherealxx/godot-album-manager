@tool
extends VBoxContainer

signal refresh

func _on_refresh_btn_pressed() -> void:
	refresh.emit()
