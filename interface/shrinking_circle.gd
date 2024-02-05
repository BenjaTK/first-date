extends ColorRect


var circle_size: float = 2.0 :
	set(value):
		circle_size = value
		material.set_shader_parameter("circle_size", circle_size)
