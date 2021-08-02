extends Node2D

var was_changed
var base_room_size = Vector2()
var size_in_grid = Vector2()
var rect = Rect2()
var color = Color(1, 1, 1)
var border_color = Color(1, 1, 1)
var wall_width = 1
var passes = []

func _enter_tree():
	was_changed = true
	if ScaleManager.connect("scale_changed", self, "on_scale_changed") != OK:
		push_error("Can't connect")

func _process(_delta):
	if was_changed:
		update()
		was_changed = false

func _draw():
	draw_rect(rect, color, true)

	draw_left_wall()
	draw_right_wall()
	draw_bottom_wall()
	draw_top_wall()
	for p in passes:
		draw_pass(p)

func draw_left_wall():
	var from = Vector2(0, 0)
	var to = Vector2(0, rect.size.y)
	draw_line(from, to, border_color, wall_width)

func draw_right_wall():
	var from = Vector2(rect.size.x, 0)
	var to = Vector2(rect.size.x, rect.size.y)
	draw_line(from, to, border_color, wall_width)

func draw_bottom_wall():
	var from = Vector2(0, rect.size.y)
	var to = Vector2(rect.size.x, rect.size.y)
	draw_line(from, to, border_color, wall_width)

func draw_top_wall():
	var from = Vector2(0, 0)
	var to = Vector2(rect.size.x, 0)
	draw_line(from, to, border_color, wall_width)

func draw_pass(pass_pos):
	if fmod(pass_pos.x, 1.0) == 0.5:
		# horizontal
		_draw_hor_pass(pass_pos * base_room_size)
	elif fmod(pass_pos.y, 1.0) == 0.5:
		# it's vertical pass
		_draw_vert_pass(pass_pos * base_room_size)


func _draw_vert_pass(center: Vector2):
	var length = base_room_size.y / 3
	var from = Vector2(center.x, center.y  - length)
	var to = Vector2(center.x, center.y + length)
	draw_line(from, to, color, wall_width)

func _draw_hor_pass(center):
	var length = base_room_size.x / 3
	var from = Vector2(center.x - length, center.y)
	var to = Vector2(center.x + length, center.y)
	draw_line(from, to, color, wall_width)

func set_base_room_size(width, height):
	base_room_size.x = width
	base_room_size.y = height

	update_size_in_pixels()

func set_room_size(width_in_rows, height_in_cols):
	size_in_grid.x = width_in_rows
	size_in_grid.y = height_in_cols
	update_size_in_pixels()

func update_size_in_pixels():
	rect.size.x = base_room_size.x * size_in_grid.x
	rect.size.y = base_room_size.y * size_in_grid.y
	#rect.position.x = -width / 2
	#rect.position.y = -height / 2
	was_changed = true

func update_passes(new_passes):
	passes = new_passes
	was_changed = true

func play_create_animation():
	var tween = $Tween
	tween.interpolate_property(self, "scale", Vector2(0, 0), Vector2(1, 1), 0.3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "position", self.position + rect.size / 2, self.position, 0.3, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()

func play_destroy_animation():
	if $Tween.connect("tween_completed", self, "tween_completed") != OK:
		push_error("Can't connect")
	var tween = $Tween
	tween.interpolate_property(self, "scale", Vector2(1, 1), Vector2(0, 0), 0.3, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.interpolate_property(self, "position", self.position, self.position + rect.size / 2, 0.3, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()

func tween_completed(_object, _key):
	queue_free()

func on_scale_changed():
	set_base_room_size(ScaleManager.get_room_width(), ScaleManager.get_room_height())
