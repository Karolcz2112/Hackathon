extends Node2D

## Kosmiczny kurier: retro 8-bit styl, anteny inspirowane wieżą radiostacji w Gliwicach / Wieżą Eiffla.
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

# Pixel snap to emulate 8-bit feel
func _snap(v: Vector2) -> Vector2:
	return Vector2(round(v.x), round(v.y))

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
			"size": rng.randf_range(1.0, 2.8),
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
		# Spawning interval: gentler acceleration and cap after 100 points
		var capped_score := minf(score, 100.0)
		var interval := maxf(0.48, 0.92 - capped_score * 0.0030)
		if spawn_timer >= interval:
			spawn_timer = 0.0
			_spawn_item()
		_update_items(dt)
	queue_redraw()

func _spawn_item() -> void:
	var is_asteroid := rng.randf() < 0.62
	var x := rng.randf_range(28.0, screen_size.x - 28.0)
	var tries := 0
	# Zwiększony odstęp poziomy od gracza żeby było mniej konfuzji
	while absf(x - player_x) < 220.0 and tries < 24:
		x = rng.randf_range(28.0, screen_size.x - 28.0)
		tries += 1
	items.append({
		"x": x,
		"y": -80.0, # start wyżej - wyraźniejszy odstęp
		"radius": rng.randf_range(15.0, 22.0) if is_asteroid else 14.0,
		"asteroid": is_asteroid,
		"rotation": rng.randf_range(0.0, TAU),
		"spin": rng.randf_range(-1.8, 1.8),
		"height": rng.randf_range(36.0, 78.0),
		"phase": rng.randf_range(0.0, TAU),
		"can_be_cleared": not is_asteroid
	})

func _update_items(delta: float) -> void:
	# Fall speed: reduce acceleration to make game fairer after 100 points
	var base_speed := 210.0
	var fall_speed := base_speed + minf(score * 0.12, 120.0)
	if score >= 100:
		fall_speed = base_speed + minf(100.0 * 0.12, 120.0) + (score - 100.0) * 0.04
	for i in range(items.size() - 1, -1, -1):
		var item := items[i]
		item["y"] = float(item["y"]) + fall_speed * (1.0 if item["asteroid"] else 0.82) * delta
		item["rotation"] = float(item["rotation"]) + float(item["spin"]) * delta
		var player_pos := Vector2(player_x, screen_size.y * PLAYER_Y_RATIO)
		# Zwiększony margines od kolizji, tak aby była odczuwalna przerwa i mniej konfuzji przy klikaniu
		if player_pos.distance_to(Vector2(float(item["x"]), float(item["y"]))) < float(item["radius"]) + 24.0:
			if item["asteroid"]:
				lives -= 1
				if lives <= 0:
					items.remove_at(i)
					_end_game()
					return
			else:
				score += 10
			items.remove_at(i)
		elif float(item["y"]) > screen_size.y + 80.0:
			items.remove_at(i)

func _draw() -> void:
	var bg := Color("090e24")
	draw_rect(Rect2(Vector2.ZERO, screen_size), bg)
	draw_circle(screen_size * Vector2(0.5, 0.42), screen_size.y * 0.62, Color(0.12, 0.14, 0.34, 0.24))
	for star in stars:
		var p: Vector2 = star["pos"]
		# Pixelate star positions a bit for retro look
		p = _snap(p)
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
	draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.025, 0.035, 0.09, 0.52))
	var center_x := screen_size.x * 0.5
	_draw_text("✦  MISJA ANTENOWA  ✦", Vector2(center_x - 154, screen_size.y * 0.34), 15, Color("7cf5ff"))
	_draw_text("EIFFEL  SIGNAL", Vector2(center_x - 180, screen_size.y * 0.44), 38, Color("eff5ff"))
	_draw_text("Zbieraj sygnały ✦   omijaj wieże", Vector2(center_x - 178, screen_size.y * 0.52), 17, Color("bac5e2"))
	_draw_text("← → / A D albo przeciągaj myszą lub palcem", Vector2(center_x - 214, screen_size.y * 0.58), 14, Color("9da9cc"))
	_draw_text("KLIKNIJ LUB NACIŚNIJ SPACJĘ, ABY ZAGRAĆ", Vector2(center_x - 224, screen_size.y * 0.69), 16, Color("ffe78a"))

func _draw_item(item: Dictionary) -> void:
	var pos := Vector2(float(item["x"]), float(item["y"]))
	var swing := sin(elapsed * 3.8 + float(item["phase"])) * 5.0
	if item["asteroid"]:
		_draw_antenna_hazard(pos + Vector2(swing, 0.0), item)
	else:
		_draw_signal_beacon(pos + Vector2(swing, 0.0), item)

func _draw_antenna_hazard(pos: Vector2, item: Dictionary) -> void:
	# Lattice tower stylizowany na wiezę radiową / Eiffel
	var height := float(item["height"]) * 1.15
	var x := round(pos.x)
	var top := Vector2(x, pos.y)
	var bottom := Vector2(x, pos.y + height)
	# central pole (blocky)
	draw_rect(Rect2(x - 3, pos.y, 6, height), Color("2b2b3f"))
	# triangular legs - pixelated lines
	var steps := int(height / 10)
	for s in range(steps + 1):
		var t := float(s) / max(1, steps)
		var left_x := lerp(x - 28, x - 6, t)
		var right_x := lerp(x + 28, x + 6, t)
		var y := pos.y + t * height
		# horizontal crossbars
		if s % 2 == 0:
			draw_line(Vector2(left_x, y), Vector2(right_x, y), Color("6fa8ff"), 2.0)
		# diagonal lattice lines
		draw_line(Vector2(left_x, y), Vector2(x - 3, pos.y + t * height), Color("8aa0c4"), 1.6)
		draw_line(Vector2(right_x, y), Vector2(x + 3, pos.y + t * height), Color("8aa0c4"), 1.6)
	# small antennas / metal pieces
	for a in range(3):
		var ay := pos.y + 8.0 + a * (height / 3.0)
		draw_rect(Rect2(x - 1, ay, 2, 12), Color("dfe8ff"))
		draw_line(Vector2(x, ay + 4), Vector2(x - 18, ay + 8), Color("ffe38a"), 2.0)
		draw_line(Vector2(x, ay + 6), Vector2(x + 18, ay + 10), Color("ffe38a"), 2.0)
	# base platform
	draw_rect(Rect2(x - 22, pos.y + height - 10, 44, 10), Color("262740"))

func _draw_signal_beacon(pos: Vector2, item: Dictionary, ) -> void:
	# Antenna / metal scrap look for beacons
	var height := float(item["height"])
	var x := round(pos.x)
	# main thin rod
	draw_rect(Rect2(x - 2, pos.y, 4, height), Color("76e0ff"))
	# crossbars and clamps
	for i in range(3):
		var y := pos.y + 12 + i * (height / 3.0)
		draw_rect(Rect2(x - 12, y, 24, 4), Color("cfe8ff"))
		draw_rect(Rect2(x - 2, y - 2, 4, 8), Color("dfe8ff"))
	# small antenna tips
	draw_rect(Rect2(x - 6, pos.y - 8, 12, 6), Color("ffe781"))
	# round signal glow - make pixelated by drawing two concentric circles
	draw_circle(Vector2(x, pos.y - 6), 8.0, Color(1.0, 0.96, 0.72, 0.55))
	draw_circle(Vector2(x, pos.y - 6), 4.0, Color("ffe781"))

func _draw_ship(pos: Vector2) -> void:
	# Blocky 8-bit ship
	pos = _snap(pos)
	# body
	draw_rect(Rect2(pos.x - 12, pos.y - 16, 24, 12), Color("d5fbff"))
	# cockpit
	draw_rect(Rect2(pos.x - 6, pos.y - 22, 12, 8), Color("7cf5ff"))
	# thruster
	draw_rect(Rect2(pos.x - 6, pos.y + 2, 12, 10), Color("697be0"))
	# small pixel flame
	draw_rect(Rect2(pos.x - 3, pos.y + 12, 3, 8), Color("8c8dff"))

func _draw_text(text: String, pos: Vector2, size: int, color: Color) -> void:
	if font:
		draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
