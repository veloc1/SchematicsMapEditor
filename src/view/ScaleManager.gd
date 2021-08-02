extends Node

signal scale_changed

var room_width = 32
var room_height = 18
var scale = 1
var target_scale = 1

func _process(delta):
	if scale != target_scale:
		scale = lerp(scale, target_scale, 3 * delta)
		emit_signal("scale_changed")

func set_initial_size(width, height):
	room_width = width
	room_height = height

func get_room_width():
	return room_width * scale

func get_room_height():
	return room_height * scale

func scale_up():
	target_scale = target_scale * 1.05

func scale_down():
	target_scale = target_scale * 0.95


