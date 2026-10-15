extends Node2D
## Radiostacja Gliwice - wspinaczka (w stylu Timbermana). Zero zewnętrznych assetów.

const W := 480.0
const H := 800.0
const CX := 240.0
const SEG_H := 84.0
const NUM_SEGS := 11
const PLAYER_Y := 600.0
const TOWER_W := 64.0
const ARM_LEN := 120.0
const PLAYER_DX := 78.0
const SAVE_PATH := "user://rekord.cfg"

enum State { WAIT, PLAY, DEAD }

var segs: Array[int] = []   # 0 = pusto, 1 = antena z lewej, 2 = antena z prawej
var state: State = State.WAIT
var side: int = 0           # 0 = lewa strona wieży, 1 = prawa
var score: int = 0
var best: int = 0
var energy: float = 1.0
var scroll: float = 0.0
var px_vis: float = CX - PLAYER_DX
var dead_time: float = 0.0
var shake: float = 0.0
var t: float = 0.0
var death_msg: String = ""
var stars := PackedVector2Array()
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	RenderingServer.set_default_clear_color(Color("#0b1530"))
	for i in 40:
		stars.append(Vector2(rng.randf_range(0.0, W), rng.randf_range(0.0, 500.0)))
	load_best()
	reset_game()


func rand_seg() -> int:
	var r := rng.randf()
	if r < 0.5:
		return 0
	return 1 if r < 0.75 else 2


func reset_game() -> void:
	segs.clear()
	for i in NUM_SEGS:
		segs.append(0 if i < 3 else rand_seg())
	state = State.WAIT
	score = 0
	energy = 1.0
	scroll = 0.0
	side = 0
	px_vis = CX - PLAYER_DX
	dead_time = 0.0
	shake = 0.0


func tap(s: int) -> void:
	if state == State.DEAD:
		if dead_time > 0.5:
			reset_game()
		return
	if state == State.WAIT:
		state = State.PLAY
	side = s
	segs.remove_at(0)
	segs.append(rand_seg())
	scroll = -SEG_H
	if segs[0] == side + 1:
		die("Zderzenie z anteną!")
		return
	score += 1
	energy = minf(1.0, energy + 0.05)


func die(msg: String) -> void:
	state = State.DEAD
	death_msg = msg
	dead_time = 0.0
	shake = 0.4
	if score > best:
		best = score
		save_best()


func _process(delta: float) -> void:
	t += delta
	scroll = lerpf(scroll, 0.0, 1.0 - exp(-delta * 22.0))
	var target_x := CX + (PLAYER_DX if side == 1 else -PLAYER_DX)
	px_vis = lerpf(px_vis, target_x, 1.0 - exp(-delta * 30.0))
	if state == State.PLAY:
		energy -= minf(0.22 + score * 0.004, 0.55) * delta
		if energy <= 0.0:
			energy = 0.0
			die("Zabrakło zasilania!")
	elif state == State.DEAD:
		dead_time += delta
	shake = maxf(0.0, shake - delta)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo:
			if k.keycode == KEY_LEFT or k.keycode == KEY_A:
				tap(0)
			elif k.keycode == KEY_RIGHT or k.keycode == KEY_D:
				tap(1)
			elif k.keycode == KEY_SPACE or k.keycode == KEY_ENTER:
				tap(1 - side)
	elif event is InputEventMouseButton:
		var m := event as InputEventMouseButton
		if m.pressed and m.button_index == MOUSE_BUTTON_LEFT:
			tap(0 if m.position.x < CX else 1)


# ---------------------------------------------------------------- zapis

func load_best() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best = int(cfg.get_value("game", "best", 0))


func save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "best", best)
	cfg.save(SAVE_PATH)


# ---------------------------------------------------------------- rysowanie

func _draw() -> void:
	var off := Vector2.ZERO
	if shake > 0.0:
		off = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * shake * 25.0
	draw_set_transform(off, 0.0, Vector2.ONE)

	# niebo
	for i in 16:
		var c := Color("#0b1530").lerp(Color("#3a5a8c"), float(i) / 15.0)
		draw_rect(Rect2(-20.0, i * 50.0, W + 40.0, 50.0), c)
	for i in stars.size():
		var a := 0.5 + 0.5 * sin(t * 2.0 + float(i))
		draw_circle(stars[i], 1.5, Color(1, 1, 1, a * 0.8))

	# fale radiowe znad wieży
	for k in 3:
		var rad := fmod(t * 70.0 + k * 60.0, 180.0)
		draw_arc(Vector2(CX, 90.0), rad, 0.0, TAU, 48, Color(1, 1, 1, (1.0 - rad / 180.0) * 0.35), 3.0)

	# wieża (segment -1 to "podstawa" wypełniająca lukę podczas animacji)
	for i in range(-1, NUM_SEGS):
		var cy := PLAYER_Y - i * SEG_H + scroll
		if cy < -SEG_H:
			continue
		var kind: int = 0 if i < 0 else segs[i]
		draw_segment(cy, kind)

	# ziemia
	draw_rect(Rect2(-20.0, PLAYER_Y + SEG_H * 0.5, W + 40.0, H), Color("#1e3a2a"))

	# gracz
	var py := PLAYER_Y
	if state == State.DEAD:
		py += minf(dead_time * dead_time * 900.0, 500.0)
	draw_player(px_vis, py)

	# HUD (bez drgań)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_rect(Rect2(60.0, 20.0, 360.0, 22.0), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(60.0, 20.0, 360.0 * energy, 22.0), Color.RED.lerp(Color.GREEN, energy))
	draw_rect(Rect2(60.0, 20.0, 360.0, 22.0), Color.WHITE, false, 2.0)
	txt("ZASILANIE", 60.0, 16, Color.WHITE)

	if state == State.WAIT:
		txt("RADIOSTACJA GLIWICE", 280.0, 36, Color("#f1c40f"))
		txt("Wspinaj się po drewnianej wieży", 330.0, 20)
		txt("i omijaj ramiona anten!", 358.0, 20)
		txt("Strzałki / A D / dotyk lewej i prawej połowy ekranu", 410.0, 15)
		txt("Spacja = zmień stronę", 436.0, 15)
		txt("Rekord: %d" % best, 480.0, 20, Color("#f1c40f"))
	elif state == State.PLAY:
		txt(str(score), 140.0, 72)
	else:
		txt(death_msg, 300.0, 32, Color("#ff6b5b"))
		txt("Wynik: %d" % score, 350.0, 28)
		txt("Rekord: %d" % best, 385.0, 22, Color("#f1c40f"))
		if dead_time > 0.5:
			txt("Dotknij, aby zagrać ponownie", 440.0, 20)


func draw_segment(cy: float, kind: int) -> void:
	var l := CX - TOWER_W * 0.5
	var r := CX + TOWER_W * 0.5
	var top_y := cy - SEG_H * 0.5
	var bot_y := cy + SEG_H * 0.5
	draw_rect(Rect2(l, top_y, TOWER_W, SEG_H), Color("#6b4a2b"))
	draw_line(Vector2(l, top_y), Vector2(r, bot_y), Color("#3e2a17"), 3.0)
	draw_line(Vector2(r, top_y), Vector2(l, bot_y), Color("#3e2a17"), 3.0)
	draw_line(Vector2(l, top_y), Vector2(r, top_y), Color("#3e2a17"), 4.0)
	draw_line(Vector2(l, top_y), Vector2(l, bot_y), Color("#8a6238"), 6.0)
	draw_line(Vector2(r, top_y), Vector2(r, bot_y), Color("#8a6238"), 6.0)
	if kind == 1:
		draw_arm(cy, -1.0)
	elif kind == 2:
		draw_arm(cy, 1.0)


func draw_arm(cy: float, dir: float) -> void:
	var x0 := CX + dir * TOWER_W * 0.5
	var x1 := CX + dir * (TOWER_W * 0.5 + ARM_LEN)
	var red := Color("#c0392b")
	draw_line(Vector2(x0, cy), Vector2(x1, cy), red, 8.0)
	draw_line(Vector2(x0, cy - 26.0), Vector2(x1, cy - 26.0), red, 4.0)
	draw_line(Vector2(x1, cy - 26.0), Vector2(x1, cy + 10.0), red, 4.0)
	draw_circle(Vector2(x1, cy + 17.0), 7.0, Color("#ecf0f1"))
	draw_line(Vector2(x1, cy + 24.0), Vector2(x0, cy + SEG_H * 0.45), Color("#ecf0f1"), 2.0)


func draw_player(x: float, y: float) -> void:
	draw_rect(Rect2(x - 11.0, y - 4.0, 9.0, 26.0), Color("#2c3e50"))
	draw_rect(Rect2(x + 2.0, y - 4.0, 9.0, 26.0), Color("#2c3e50"))
	draw_rect(Rect2(x - 14.0, y - 26.0, 28.0, 28.0), Color("#e67e22"))
	draw_circle(Vector2(x, y - 36.0), 11.0, Color("#f1c27d"))
	draw_rect(Rect2(x - 13.0, y - 50.0, 26.0, 12.0), Color("#f1c40f"))
	draw_line(Vector2(x + 14.0, y - 14.0), Vector2(x + 22.0, y - 40.0), Color("#bdc3c7"), 3.0)


func txt(s: String, y: float, size: int, col: Color = Color.WHITE) -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(2.0, y + 2.0), s, HORIZONTAL_ALIGNMENT_CENTER, W, size, Color(0, 0, 0, 0.6))
	draw_string(font, Vector2(0.0, y), s, HORIZONTAL_ALIGNMENT_CENTER, W, size, col)
