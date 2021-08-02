extends Object
class_name GridModel

var width
var height
var actual_grid = []

func _init(meta: MetaModel):
	_init_grid(meta)

func _init_grid(meta: MetaModel):
	actual_grid = []

	width = meta.scene_width
	height = meta.scene_height

	for x in width:
		var column = []
		actual_grid.append(column)
		for y in height:
			column.append(CellModel.new())

func get_cell(pos: Vector2) -> CellModel:
	return actual_grid[pos.x][pos.y]

func get_cell_with_room_on_position(pos: Vector2):
	var cell = get_cell(pos)
	if cell.room:
		# we found cell right on place
		return [cell, pos]

	# if we dont have cell on specified position, then check nearest cells and find cells which can overlap with position
	for x in range(pos.x, pos.x - 10, -1):
		for y in range(pos.y, pos.y - 10, -1):
			cell = get_cell(Vector2(x, y))
			if cell.room:
				if x + cell.room.size.x > pos.x and y + cell.room.size.y > pos.y:
					return [cell, Vector2(x, y)]

	return null
