extends Node2D

## Kosmiczny kurier: kompletny prototyp w jednej scenie, bez zewnętrznych assetów.
const PLAYER_Y_RATIO := 0.82
const PLAYER_SPEED := 520.0
const MAX_LIVES := 3

var rng := RandomNumberGenerator.new()
var screen_size := Vector2(900, 600)
var player_x := 450.0
var items: Array[Dictionary] = []
var stars: Array[Dictionary] = []
var score := 0
var lives := MAX_LIVES
var elapsed := 0.0
var spawn_timer := 0.0
var running := false
var pointer_active := false
var pointer_x := 0.0
var best_score := 0
var font: Font

func _ready() -> void:
	rng.randomize()
	font = ThemeDB.fallback_font
	var saved_scores := ConfigFile.new()
	if saved_scores.load("user://wyniki.cfg") == OK:
		best_score = int(saved_scores.get_value("scores", "best", 0))
	_reset_stars()
	_update_screen_size()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_screen_size()
		_reset_stars()
		queue_redraw()

func _update_screen_size() -> void:
	screen_size = get_viewport_rect().size
	player_x = clampf(player_x, 24.0, screen_size.x - 24.0)

func _reset_stars() -> void:
	stars.clear()
	var count := int(screen_size.x * screen_size.y / 3600.0)
	for i in count:
		stars.append({
			"pos": Vector2(rng.randf_range(0.0, screen_size.x), rng.randf_range(0.0, screen_size.y)),
			"size": rng.randf_range(1.0, 2.6),
			"alpha": rng.randf_range(0.25, 0.9),
			"speed": rng.randf_range(18.0, 65.0)
		})

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE and not running:
			_start_game()
		elif event.keycode == KEY_ENTER and not running:
			_start_game()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not running:
				_start_game()
			pointer_active = true
			pointer_x = event.position.x
		else:
			pointer_active = false
	elif event is InputEventMouseMotion and pointer_active:
		pointer_x = event.position.x
	elif event is InputEventScreenTouch:
		if event.pressed:
			if not running:
				_start_game()
			pointer_active = true
			pointer_x = event.position.x
		else:
			pointer_active = false
	elif event is InputEventScreenDrag:
		pointer_x = event.position.x
		pointer_active = true

func _start_game() -> void:
	score = 0
	lives = MAX_LIVES
	elapsed = 0.0
	spawn_timer = 0.0
	items.clear()
	player_x = screen_size.x * 0.5
	running = true
	queue_redraw()

func _end_game() -> void:
	running = false
	if score > best_score:
		best_score = score
		var save := ConfigFile.new()
		save.set_value("scores", "best", best_score)
		save.save("user://wyniki.cfg")

func _process(delta: float) -> void:
	var dt := minf(delta, 0.05)
	for star in stars:
		star["pos"].y += float(star["speed"]) * dt
		if star["pos"].y > screen_size.y:
			star["pos"].y = 0.0
			star["pos"].x = rng.randf_range(0.0, screen_size.x)
	if running:
		elapsed += dt
		var direction := Input.get_axis("ui_left", "ui_right")
		if Input.is_key_pressed(KEY_A):
			direction = -1.0
		elif Input.is_key_pressed(KEY_D):
			direction = 1.0
		if pointer_active:
			player_x = move_toward(player_x, pointer_x, PLAYER_SPEED * 1.7 * dt)
		else:
			player_x += direction * PLAYER_SPEED * dt
		player_x = clampf(player_x, 24.0, screen_size.x - 24.0)
		spawn_timer += dt
		var interval := maxf(0.28, 0.78 - score * 0.0007)
		if spawn_timer >= interval:
			spawn_timer = 0.0
			_spawn_item()
		_update_items(dt)
	queue_redraw()

func _spawn_item() -> void:
	var is_asteroid := rng.randf() < 0.64
	items.append({
		"x": rng.randf_range(28.0, screen_size.x - 28.0),
		"y": -32.0,
		"radius": rng.randf_range(13.0, 23.0) if is_asteroid else 15.0,
		"asteroid": is_asteroid,
		"rotation": rng.randf_range(0.0, TAU),
		"spin": rng.randf_range(-1.5, 1.5)
	})

func _update_items(delta: float) -> void:
	var fall_speed := 250.0 + minf(score * 0.22, 330.0)
	for i in range(items.size() - 1, -1, -1):
		var item := items[i]
		item["y"] = float(item["y"]) + fall_speed * (1.0 if item["asteroid"] else 0.82) * delta
		item["rotation"] = float(item["rotation"]) + float(item["spin"]) * delta
		var player_pos := Vector2(player_x, screen_size.y * PLAYER_Y_RATIO)
		if player_pos.distance_to(Vector2(float(item["x"]), float(item["y"]))) < float(item["radius"]) + 13.0:
			if item["asteroid"]:
				lives -= 1
				if lives <= 0:
					items.remove_at(i)
					_end_game()
					return
			else:
				score += 10
			items.remove_at(i)
		elif float(item["y"]) > screen_size.y + 40.0:
			items.remove_at(i)

func _draw() -> void:
	var bg := Color("090e24")
	draw_rect(Rect2(Vector2.ZERO, screen_size), bg)
	draw_circle(screen_size * Vector2(0.5, 0.44), screen_size.y * 0.62, Color(0.12, 0.14, 0.34, 0.22))
	for star in stars:
		var p: Vector2 = star["pos"]
		draw_circle(p, float(star["size"]), Color(0.82, 0.89, 1.0, float(star["alpha"])))
	_draw_hud()
	if running:
		for item in items:
			_draw_item(item)
		_draw_ship(Vector2(player_x, screen_size.y * PLAYER_Y_RATIO))
	else:
		_draw_menu()

func _draw_hud() -> void:
	_draw_text("WYNIK", Vector2(24, 30), 13, Color("9da9cc"))
	_draw_text(str(score), Vector2(24, 61), 27, Color("eff5ff"))
	_draw_text("REKORD  " + str(best_score), Vector2(screen_size.x - 185, 35), 15, Color("7cf5ff"))
	var hearts := ""
	for i in MAX_LIVES:
		hearts += "♥ " if i < lives else "♡ "
	_draw_text(hearts, Vector2(screen_size.x - 115, 68), 22, Color("ff81c8"))

func _draw_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.025, 0.035, 0.09, 0.48))
	var center_x := screen_size.x * 0.5
	_draw_text("✦  MISJA SPECJALNA  ✦", Vector2(center_x - 135, screen_size.y * 0.34), 15, Color("7cf5ff"))
	_draw_text("KOSMICZNY KURIER", Vector2(center_x - 244, screen_size.y * 0.44), 38, Color("eff5ff"))
	_draw_text("Zbieraj paczki ✦   Omijaj asteroidy", Vector2(center_x - 177, screen_size.y * 0.52), 17, Color("bac5e2"))
	_draw_text("← → / A D albo przeciągaj myszą lub palcem", Vector2(center_x - 215, screen_size.y * 0.58), 14, Color("9da9cc"))
	_draw_text("KLIKNIJ LUB NACIŚNIJ SPACJĘ, ABY ZAGRAĆ", Vector2(center_x - 224, screen_size.y * 0.69), 16, Color("ffe78a"))

func _draw_item(item: Dictionary) -> void:
	var pos := Vector2(float(item["x"]), float(item["y"]))
	var radius := float(item["radius"])
	if item["asteroid"]:
		draw_circle(pos, radius, Color("77749c"))
		draw_arc(pos, radius, 0.0, TAU, 24, Color("b1a8d1"), 2.0)
		draw_circle(pos + Vector2(-radius * 0.28, 0), radius * 0.18, Color("514e76"))
		draw_circle(pos + Vector2(radius * 0.3, -radius * 0.25), radius * 0.12, Color("514e76"))
	else:
		draw_circle(pos, radius * 1.5, Color(1.0, 0.88, 0.45, 0.14))
		_draw_text("✦", pos + Vector2(-12, 9), 27, Color("ffe78a"))

func _draw_ship(pos: Vector2) -> void:
	var flame := PackedVector2Array([pos + Vector2(-5, 10), pos + Vector2(0, rng.randf_range(22, 31)), pos + Vector2(5, 10)])
	draw_colored_polygon(flame, Color("8c8dff"))
	var points := PackedVector2Array([pos + Vector2(0, -19), pos + Vector2(14, 14), pos + Vector2(0, 8), pos + Vector2(-14, 14)])
	draw_colored_polygon(points, Color("d5fbff"))
	draw_circle(pos + Vector2(0, -2), 4, Color("697be0"))

func _draw_text(text: String, pos: Vector2, size: int, color: Color) -> void:
	if font:
		draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
