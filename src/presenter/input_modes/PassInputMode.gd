extends InputMode
class_name PassInputMode

func _init(presenter_, grid).(presenter_, grid):
	pass

func _ready():
	pass

func _process(_delta):
	pass
	#_tween_cursor_to_mouse_pos(delta)

func on_left_mouse_button_click(mouse_pos):
	presenter.create_pass(mouse_pos)

func on_right_mouse_button_click(mouse_pos):
	presenter.remove_pass(mouse_pos)
