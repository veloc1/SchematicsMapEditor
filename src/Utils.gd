extends Node

# convert pixel coords to grid coords
func pix_to_grid(pix):
	var cell_x = round((pix.x - ScaleManager.get_room_width() / 2.0) / ScaleManager.get_room_width())
	var cell_y = round((pix.y - ScaleManager.get_room_height() / 2.0) / ScaleManager.get_room_height())
	return Vector2(cell_x, cell_y)

func grid_to_pix(grid_pos):
	var x = grid_pos.x * ScaleManager.get_room_width()
	var y = grid_pos.y * ScaleManager.get_room_height()
	return Vector2(x, y)
