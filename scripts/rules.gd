extends "res://scripts/rules_base.gd"

var board: Array[int] = []
var won := false
var awaiting_continue := false


func _init() -> void:
	title = "2048"
	subtitle = "Deslize para combinar os números"


func reset() -> void:
	super.reset()
	won = false
	awaiting_continue = false
	board.resize(16)
	board.fill(0)
	_spawn()
	_spawn()


func _spawn() -> void:
	var empty: Array[int] = []
	for i in range(16):
		if board[i] == 0:
			empty.append(i)
	if not empty.is_empty():
		board[empty.pick_random()] = 4 if randf() < 0.1 else 2


func _compress(line: Array) -> Array:
	var values: Array[int] = []
	for value in line:
		if value != 0:
			values.append(value)
	var combined: Array[int] = []
	var i := 0
	while i < values.size():
		if i + 1 < values.size() and values[i] == values[i + 1]:
			var merged := values[i] * 2
			combined.append(merged)
			score += merged
			if merged >= 2048:
				won = true
			i += 2
		else:
			combined.append(values[i])
			i += 1
	while combined.size() < 4:
		combined.append(0)
	return combined


func move(direction: String) -> bool:
	if ended or awaiting_continue:
		return false
	if not ["left", "right", "up", "down"].has(direction):
		return false
	var was_won := won
	var old := board.duplicate()
	for lane in range(4):
		var indices: Array[int] = []
		for step in range(4):
			if direction == "left":
				indices.append(lane * 4 + step)
			elif direction == "right":
				indices.append(lane * 4 + 3 - step)
			elif direction == "up":
				indices.append(step * 4 + lane)
			else:
				indices.append((3 - step) * 4 + lane)
		var line: Array = []
		for index in indices:
			line.append(board[index])
		var merged := _compress(line)
		for step in range(4):
			board[indices[step]] = merged[step]
	var changed := board != old
	if changed:
		_spawn()
		if won and not was_won:
			awaiting_continue = true
			message = "Você chegou a 2048!"
		elif not can_move():
			ended = true
			message = "Sem movimentos!"
	elif not can_move():
		ended = true
		message = "Sem movimentos!"
	return changed


func continue_after_win() -> void:
	if not awaiting_continue:
		return
	awaiting_continue = false
	if can_move():
		message = ""
	else:
		ended = true
		message = "Sem movimentos!"


func can_move() -> bool:
	for i in range(16):
		if board[i] == 0:
			return true
		var x := i % 4
		var y := i / 4
		if x < 3 and board[i] == board[i + 1]:
			return true
		if y < 3 and board[i] == board[i + 4]:
			return true
	return false


func swipe(a: Vector2, b: Vector2) -> void:
	var direction := b - a
	if absf(direction.x) > absf(direction.y):
		move("right" if direction.x > 0.0 else "left")
	else:
		move("down" if direction.y > 0.0 else "up")


func tap(p: Vector2) -> void:
	var d := p - Vector2(0.5, 0.5)
	if absf(d.x) > absf(d.y):
		move("right" if d.x > 0 else "left")
	else:
		move("down" if d.y > 0 else "up")


func draw_game(canvas: CanvasItem, area: Rect2) -> void:
	label(canvas, "Combine peças iguais", Vector2(area.get_center().x, area.position.y + 60), 26)
	var side := minf(area.size.x - 28, area.size.y - 145)
	var board_area := Rect2(Vector2(area.get_center().x - side / 2, area.get_center().y - side / 2 + 35), Vector2.ONE * side)
	canvas.draw_rect(board_area, Color("cdd8ed"))
	for i in range(16):
		var x := i % 4
		var y := i / 4
		var cell := cell_rect(board_area, x, y, 4, 4, 6)
		var value := board[i]
		var color := Color("edf1f9") if value == 0 else Color.from_hsv(fmod(0.09 + log(float(value)) * 0.095, 1.0), 0.5, 0.96)
		canvas.draw_rect(cell, color)
		if value > 0:
			label(canvas, str(value), cell.get_center(), 34 if value < 1024 else 26)
