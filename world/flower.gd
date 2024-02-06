extends Interactable


@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer


func _on_interacted() -> void:
	audio_stream_player.play()
	hide()
	get_overlapping_bodies().front().has_flower = true
	await audio_stream_player.finished
	queue_free()
