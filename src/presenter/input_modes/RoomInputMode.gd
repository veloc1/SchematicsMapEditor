extends InputMode
class_name RoomInputMode

const Room = preload("res://src/view/objects/Room.tscn")

onready var cursor

func _init(presenter_, grid).(presenter_, grid):
	pass

func _ready():
	cursor = _init_cursor()

func _process(delta):
	_tween_cursor_to_mouse_pos(delta)

func _tween_cursor_to_mouse_pos(delta):
	# round mouse position to underlying grid cell
	var cell_under_mouse = Utils.grid_to_pix(Utils.pix_to_grid(mouse_pos))
	cursor.position = cursor.position.linear_interpolate(cell_under_mouse, delta * 5)

func on_left_mouse_button_click(mouse_pos):
	presenter.create_room(mouse_pos)

func on_right_mouse_button_click(mouse_pos):
	presenter.remove_room(mouse_pos)

func _init_cursor():
	var cursor_room =  Room.instance()
	add_child(cursor_room)

	cursor_room.position.x = 320
	cursor_room.position.y = 240

	cursor_room.color = Color(0.6, 0.6, 0.6, 0.6)

	cursor_room.set_base_room_size(ScaleManager.get_room_width(), ScaleManager.get_room_height())
	cursor_room.set_room_size(1, 1)
	cursor_room.z_index = 3
	return cursor_room

func set_room_size(new_size):
	cursor.set_room_size(new_size.x, new_size.y)
