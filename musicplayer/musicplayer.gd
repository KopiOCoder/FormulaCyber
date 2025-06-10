extends Node

var songs = [
	preload("res://musicplayer/music/music1.mp3"), 
	preload("res://musicplayer/music/music2.mp3")
]
var current_song_index = 0
var audio_player
var started = false

func _process(delta):
	if not started:
		started = true
		audio_player.play()

func _ready():
	set_process(true)
	if not get_tree().root.has_node("AudioStreamPlayer"):
		set_name("AudioStreamPlayer")
		get_tree().root.add_child(self)
		set_process(true)
	else:
		queue_free()
	audio_player = $AudioStreamPlayer
	audio_player.stream = songs[randi() % songs.size()]
	audio_player.play()
	audio_player.connect("finished", Callable(self, "_on_song_finished"))
	
func ensure_music_is_playing():
	if not audio_player.playing:
		audio_player.play()

func _on_song_finished():
	current_song_index = (current_song_index + 1) % songs.size()
	audio_player.stream = songs[current_song_index]
	audio_player.play()
