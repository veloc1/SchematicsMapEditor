extends Node

# Presenter glues view and model. Also, presenter contains most logic for changing model based on user input

signal color_was_used

var view
var grid_model
var mouse_pos = Vector2()
var input_mode: InputMode

var current_color = Color(0.1, 0.4, 1)
var color_was_changed = false

var current_room_size = Vector2(1, 1)

func _init(view_, grid):
	view = view_
	grid_model = grid

	view.setup_grid(grid_model)

func _ready():
	input_mode = RoomInputMode.new(self, grid_model)
	add_child(input_mode)

func _process(_delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		input_mode.set_mouse_position(mouse_pos)
	if event is InputEventMouseButton:
		if event.pressed == false:
			# do work only on button release
			if event.button_index == BUTTON_LEFT:
				input_mode.on_left_mouse_button_click(mouse_pos)
			if event.button_index == BUTTON_RIGHT:
				input_mode.on_right_mouse_button_click(mouse_pos)

			# scale
			if event.button_index == BUTTON_WHEEL_UP:
				ScaleManager.scale_up()
			if event.button_index == BUTTON_WHEEL_DOWN:
				ScaleManager.scale_down()

func create_room(pos):
	var cell_pos = Utils.pix_to_grid(pos)

	var cell = grid_model.get_cell(cell_pos)

	# clear old room
	if cell.room:
		cell.room = null

	# create room
	var room = RoomModel.new()
	room.size = current_room_size
	room.color = current_color

	cell.room = room

	view.update_cell(cell_pos, cell)

	if color_was_changed:
		emit_signal("color_was_used", current_color)
		color_was_changed = false

func remove_room(pos):
	var cell_pos = Utils.pix_to_grid(pos)

	# there can be room with size more than 1x1 cells
	var cell_info = grid_model.get_cell_with_room_on_position(cell_pos)

	if cell_info:
		var cell = cell_info[0]
		cell_pos = cell_info[1]

		# clear old room
		if cell.room:
			cell.room = null
		cell.passes.clear()
		view.update_cell(cell_pos, cell)

func create_pass(pos):
	var click_cell_pos = Utils.pix_to_grid(pos)

	var cell_info = grid_model.get_cell_with_room_on_position(click_cell_pos)

	if cell_info:
		var cell = cell_info[0]
		var cell_pos = cell_info[1]

		var pass_pos = _find_pass_coord_from_click(pos)
		if pass_pos:
			cell.passes.append(pass_pos)
			_add_pass_to_neighbor(cell_pos, pass_pos)

		view.update_cell(cell_pos, cell)

func remove_pass(pos):
	var click_cell_pos = Utils.pix_to_grid(pos)

	var cell_info = grid_model.get_cell_with_room_on_position(click_cell_pos)

	if cell_info:
		var cell = cell_info[0]
		var cell_pos = cell_info[1]

		var pass_pos = _find_pass_coord_from_click(pos)
		if pass_pos:
			var index = cell.passes.find(pass_pos)
			if index >= 0:
				cell.passes.remove(index)
		view.update_cell(cell_pos, cell)

func _find_pass_coord_from_click(pos):
	var click_cell_pos = Utils.pix_to_grid(pos)

	var cell_info = grid_model.get_cell_with_room_on_position(click_cell_pos)

	if cell_info:
		var cell = cell_info[0]
		var cell_pos = cell_info[1]
		var pass_pos = null

		if cell.room:
			# find nearest pass

			# pass in local room coordinates, pass in most left cell to left will have position 0, 0.5
			# left cell, pass to top room - 0.5, 0
			# right cell, with room_size=1 - 1, 0.5

			# variant 1: traverse along border and check if some border get < base_room_width(or height) / 3 px diff
			# there will be issues in corners
			var left = cell_pos.x * ScaleManager.get_room_width()
			var top = cell_pos.y * ScaleManager.get_room_height()
			var right = (cell_pos.x + cell.room.size.x) * ScaleManager.get_room_width()
			var bottom = (cell_pos.y + cell.room.size.y) * ScaleManager.get_room_height()

			# basically, find nearest border
			var left_distance = pos.x - left
			var right_distance = right - pos.x
			var top_distance = pos.y - top
			var bottom_distance = bottom - pos.y

			var min_distance = min(left_distance, min(right_distance, min(top_distance, bottom_distance)))
			if min_distance == left_distance:
				# create pass on the left side
				pass_pos = Vector2(0, 0.5 + click_cell_pos.y - cell_pos.y)
			elif min_distance == right_distance:
				# create pass on the right side
				pass_pos = Vector2(cell.room.size.x, 0.5 + click_cell_pos.y - cell_pos.y)
			elif min_distance == top_distance:
				# create pass on the top side
				pass_pos = Vector2(0.5 + click_cell_pos.x  - cell_pos.x, 0)
			elif min_distance == bottom_distance:
				# create pass on the bottom side
				pass_pos = Vector2(0.5 + click_cell_pos.x - cell_pos.x, cell.room.size.y)

			return pass_pos
	return null

func _add_pass_to_neighbor(cell_pos, pass_pos):
	var neighbor = null
	var neighbor_pos = null
	var neighbor_pass_pos = null

	if pass_pos.x == 0:
		# find neighbor to left and add pass to right side
		var cell_info = grid_model.get_cell_with_room_on_position(Vector2(cell_pos.x - 1, cell_pos.y + pass_pos.y - 0.5))

		if cell_info:
			neighbor = cell_info[0]
			neighbor_pos = cell_info[1]

			if neighbor.room:
				neighbor_pass_pos = Vector2(neighbor.room.size.x, cell_pos.y + pass_pos.y - neighbor_pos.y)
	elif pass_pos.x > 0 and fmod(pass_pos.x, 1) == 0:
		# find neighbor to right and add pass to left side
		var cell_info = grid_model.get_cell_with_room_on_position(Vector2(cell_pos.x + pass_pos.x, cell_pos.y + pass_pos.y - 0.5))

		if cell_info:
			neighbor = cell_info[0]
			neighbor_pos = cell_info[1]

			if neighbor.room:
				neighbor_pass_pos = Vector2(0, cell_pos.y + pass_pos.y - neighbor_pos.y)

	if pass_pos.y == 0:
		# find neighbor to top and add pass to bottom side
		var cell_info = grid_model.get_cell_with_room_on_position(Vector2(cell_pos.x + pass_pos.x - 0.5, cell_pos.y - 1))

		if cell_info:
			neighbor = cell_info[0]
			neighbor_pos = cell_info[1]

			if neighbor.room:
				neighbor_pass_pos = Vector2(cell_pos.x + pass_pos.x - neighbor_pos.x, neighbor.room.size.y)
	elif pass_pos.y > 0 and fmod(pass_pos.y, 1) == 0:
		# find neighbor to bootm and add pass to top side
		var cell_info = grid_model.get_cell_with_room_on_position(Vector2(cell_pos.x + pass_pos.x - 0.5, cell_pos.y + pass_pos.y))

		if cell_info:
			neighbor = cell_info[0]
			neighbor_pos = cell_info[1]

			if neighbor.room:
				neighbor_pass_pos = Vector2(cell_pos.x + pass_pos.x - neighbor_pos.x, 0)

	if neighbor_pass_pos:
		if neighbor.passes.find(neighbor_pass_pos) == -1:
			neighbor.passes.append(neighbor_pass_pos)

	if neighbor:
		view.update_cell(neighbor_pos, neighbor)

func color_changed(color):
	current_color = color
	color_was_changed = true

func mode_changed(new_mode):
	input_mode.queue_free()
	if new_mode == "rooms":
		input_mode = RoomInputMode.new(self, grid_model)
		add_child(input_mode)
#
#	if new_mode == "doors":
#		mode = MODE_DOORS
#
#		cursor_room.hide()
#
	if new_mode == "pass":
		input_mode = PassInputMode.new(self, grid_model)
		add_child(input_mode)

func room_width_changed(new_width):
	current_room_size.x = new_width
	input_mode.set_room_size(current_room_size)

func room_height_changed(new_height):
	current_room_size.y = new_height
	input_mode.set_room_size(current_room_size)
