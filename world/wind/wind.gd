extends Area2D


@export var direction: Vector2i = Vector2i.UP
@export var push: float = 32.0
@export var gravity_scale: float = -1.1
@export var only_gliding: bool = true

@onready var particles: CPUParticles2D = $Particles
@onready var area: CollisionShape2D = $Area




func _ready() -> void:
	particles.emitting = true

	particles.amount = 12.0
	var size = area.shape.size
	particles.emission_rect_extents.x = size.x * 0.5
	particles.lifetime = size.y / 96.0
