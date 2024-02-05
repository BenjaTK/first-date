extends Area2D


@onready var particles: CPUParticles2D = $Particles
@onready var area: CollisionShape2D = $Area


func _process(delta: float) -> void:
	if not has_overlapping_bodies():
		return


func _ready() -> void:
	particles.emitting = true

	particles.amount = 12.0
	var size = area.shape.size
	particles.emission_rect_extents.x = size.x * 0.5
	particles.lifetime = size.y / 96.0
