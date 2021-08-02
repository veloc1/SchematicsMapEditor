extends Node2D

var draw_from = -100
var draw_to = 1000
var room_width = 0
var room_height = 0

export var color = Color(0.6, 0.6, 0.6)

var was_changed = false

func _enter_tree():
	was_changed = true
	if ScaleManager.connect("scale_changed", self, "on_scale_changed") != OK:
		push_error("Can't connect")

func _process(_delta):
	if was_changed:
		update()
		was_changed = false

func _draw():
	var width = 1

	for x in range(draw_from / room_width, draw_to / room_width):
		var from = Vector2(x * room_width, draw_from)
		var to = Vector2(x * room_width, draw_to)

		draw_line(from, to, color, width)

	for y in range(draw_from / room_height, draw_to / room_height):
		var from = Vector2(draw_from, y * room_height)
		var to = Vector2(draw_to, y * room_height)

		draw_line(from, to, color, width)

func set_room_size(width, height):
	room_width = width
	room_height = height
	was_changed = true

func on_scale_changed():
	set_room_size(ScaleManager.get_room_width(), ScaleManager.get_room_height())
