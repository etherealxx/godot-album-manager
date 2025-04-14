extends Resource
class_name AlbumData

const title_identifier := "album_title"
const cover_identifier := "album_cover"

@export var album_cover : Texture2D # ideal size is 600x600 px
@export var album_title : String

@export var song_list : Array[SongData]
