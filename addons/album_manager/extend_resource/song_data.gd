extends Resource
class_name SongData

const title_identifier := "song_title"

@export var song_cover : Texture2D
@export var song_title : String
@export_file("*.mp3") var song_path := ""
@export_file("*.json", "*.mboy") var chart_path := ""
