extends Interactable


@export var shrinking_circle: ColorRect
@export var ending_screen: Control

@onready var flower: Sprite2D = $Sprite/Flower
@onready var heart: Sprite2D = $Heart


func _ready() -> void:
	heart.hide()
	flower.hide()


func _on_interacted() -> void:
	var player: Player = get_overlapping_bodies().front()
	player.can_move = false
	monitoring = false
	sprite.pause()

	await get_tree().create_timer(0.5).timeout
	player.has_flower = false
	flower.show()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).set_parallel(true)
	tween.tween_callback(heart.show).set_delay(1.25)
	tween.tween_property(heart, "position", Vector2(2, -9), 0.5).set_delay(1.25)
	tween.tween_callback(sprite.play).set_delay(1.25)
	tween.tween_property(shrinking_circle, "circle_size", 0.3, 1.0).set_delay(2.5)
	tween.tween_property(shrinking_circle, "circle_size", 0.0, 1.0).set_delay(4.0)
	tween.tween_callback(ending_screen.show).set_delay(5.0)
