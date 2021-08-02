extends Node
class_name InputMode

var mouse_pos = Vector2(0, 0)
var grid_model
var meta
var presenter

func _init(presenter_, grid):
	presenter = presenter_
	grid_model = grid

func on_left_mouse_button_click(_mouse_pos):
	pass

func on_right_mouse_button_click(_mouse_pos):
	pass

func set_mouse_position(pos):
	mouse_pos = pos

func set_room_size(_new_size):
	pass

