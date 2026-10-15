extends Node2D
## Radiostacja Gliwice - wspinaczka (w stylu Timbermana). 8-bit + anteny + bardziej czytelne ruchy.

const W := 480.0
const H := 800.0
const CX := 240.0
const SEG_H := 96.0
const NUM_SEGS := 11
const PLAYER_Y := 660.0
const TOWER_W := 64.0
const ARM_LEN := 160.0
const PLAYER_DX := 92.0
const SAVE_PATH := "user://rekord.cfg"

# Pixel-art / scale
const PIXEL := 4.0
const PLAYER_SCALE := 1.8

enum State { WAIT, PLAY, DEAD }

var segs: Array[int] = []
var seg_angles: Array[float] = []
var state: State = State.WAIT
var side: int = 0
var score: int = 0
var best: int = 0
var energy: float = 1.0
var scroll: float = 0.0
var px_vis: float = CX - PLAYER_DX
var dead_time: float = 0.0
var shake: float = 0.0
var t: float = 0.0
var death_msg: String = ""
var stars: PackedVector2Array = PackedVector2Array()
var sparks: Array[Dictionary] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	RenderingServer.set_default_clear_color(Color("#0b1530"))
	for i in range(40):
		stars.append(Vector2(rng.randf_range(0.0, W), rng.randf_range(0.0, 500.0)))
	load_best()
	reset_game()


func rand_seg() -> int:
	var r: float = rng.randf()
	if r < 0.5:
		return 0
	return 1 if r < 0.75 else 2


func reset_game() -> void:
	segs.clear()
	seg_angles.clear()
	for i in range(NUM_SEGS):
		var kind: int = 0 if i < 3 else rand_seg()
		segs.append(kind)
		seg_angles.append(0.0)
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
	seg_angles.remove_at(0)
	segs.append(rand_seg())
	seg_angles.append(rng.randf_range(-0.18, 0.18))
	scroll = -SEG_H
	if segs[0] == side + 1:
		die("Zderzenie z anteną!")
		return
	score += 1
	energy = minf(1.0, energy + 0.06)
	sparks.append({"pos": Vector2(CX + (PLAYER_DX if side == 1 else -PLAYER_DX), PLAYER_Y - 30.0), "life": 0.32})


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
	var target_x: float = CX + (PLAYER_DX if side == 1 else -PLAYER_DX)
	px_vis = lerpf(px_vis, target_x, 1.0 - exp(-delta * 30.0))
	if state == State.PLAY:
		energy -= minf(0.18 + score * 0.002, 0.45) * delta
		if energy <= 0.0:
			energy = 0.0
			die("Zabrakło zasilania!")
	elif state == State.DEAD:
		dead_time += delta
	shake = maxf(0.0, shake - delta)

	for i in range(seg_angles.size()):
		var sway: float = sin(t * 2.0 + float(i)) * 0.02
		seg_angles[i] = lerpf(seg_angles[i], sway, 1.0 - exp(-delta * 3.0))

	for i in range(seg_angles.size()):
		var cy: float = PLAYER_Y - i * SEG_H + scroll
		if segs[i] != 0:
			var dist: float = cy - PLAYER_Y
			if dist < SEG_H * 0.6 and dist > -SEG_H * 0.6:
				var dir: float = -1.0 if segs[i] == 1 else 1.0
				seg_angles[i] = lerpf(seg_angles[i], dir * 0.9, 1.0 - exp(-delta * 10.0))

	for i in range(sparks.size() - 1, -1, -1):
		sparks[i]["life"] -= delta
		if sparks[i]["life"] <= 0.0:
			sparks.remove_at(i)

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
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best = int(cfg.get_value("game", "best", 0))


func save_best() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("game", "best", best)
	cfg.save(SAVE_PATH)


# ---------------------------------------------------------------- pomocnicze do pixel-art

func pix(v: Vector2) -> Vector2:
	return Vector2(round(v.x / PIXEL) * PIXEL, round(v.y / PIXEL) * PIXEL)

func draw_pixel_char(origin: Vector2, pattern: Array, pixel_size: float, color: Color) -> void:
	# pattern: Array of String rows
	for ry in range(pattern.size()):
		var row: String = pattern[ry]
		for rx in range(row.length()):
			if row.substr(rx, 1) == "1":
				var px: Vector2 = pix(origin + Vector2(rx * pixel_size, ry * pixel_size))
				draw_rect(Rect2(px, Vector2(pixel_size, pixel_size)), color)


const PAT_Z: Array = ["11111","00011","00110","01100","11111"]
const PAT_S: Array = ["01111","10000","01110","00001","11110"]
const PAT_T: Array = ["11111","00100","00100","00100","00100"]
const PAT_I: Array = ["11111","00100","00100","00100","11111"]


# ---------------------------------------------------------------- rysowanie

func _draw() -> void:
	var off: Vector2 = Vector2.ZERO
	if shake > 0.0:
		off = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * shake * 25.0
	draw_set_transform(off, 0.0, Vector2.ONE)

	# gradient tła (prostokąty, ograniczona paleta)
	for i in range(16):
		var c: Color = Color("#0b1530").lerp(Color("#2d486b"), float(i) / 15.0)
		draw_rect(Rect2(-20.0, i * 50.0, W + 40.0, 50.0), c)
	for i in range(stars.size()):
		var a: float = 0.5 + 0.5 * sin(t * 2.0 + float(i))
		draw_circle(pix(stars[i]), PIXEL * 0.35, Color(1, 1, 1, a * 0.9))

	# antena / fale - delikatne
	for k in range(3):
		var rad: float = fmod(t * 50.0 + k * 60.0, 180.0)
		draw_arc(Vector2(CX, 90.0), rad, 0.0, TAU, 48, Color(1, 1, 1, (1.0 - rad / 180.0) * 0.20), 2.0)

	# segmenty wieży (w tym kratownica)
	for i in range(-1, NUM_SEGS):
		var cy: float = PLAYER_Y - i * SEG_H + scroll
		if cy < -SEG_H:
			continue
		if i < 0:
			draw_rect(Rect2(CX - TOWER_W * 0.6, cy - SEG_H * 0.5, TOWER_W * 1.2, SEG_H), Color("#6b4a2b"))
		else:
			draw_segment(cy, segs[i], i)

	# ziemia / tło za graczem
	draw_rect(Rect2(-20.0, PLAYER_Y + SEG_H * 0.5, W + 40.0, H), Color("#172f22"))

	# gracz (większy, pixel-art)
	var py: float = PLAYER_Y
	if state == State.DEAD:
		py += minf(dead_time * dead_time * 900.0, 500.0)
	draw_player(px_vis, py)

	# iskry
	for j in range(sparks.size()):
		var sp: Dictionary = sparks[j]
		var p: Vector2 = sp["pos"]
		var life: float = float(sp["life"])
		var a: float = clamp(life / 0.32, 0.0, 1.0)
		for j2 in range(3):
			draw_rect(Rect2(p.x - 2 + j2 * 2, p.y - j2 * 2, 2, 2), Color(1, 0.8, 0.2, a))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# pasek zasilania
	draw_rect(Rect2(60.0, 20.0, 360.0, 22.0), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(60.0, 20.0, 360.0 * energy, 22.0), Color.RED.lerp(Color.GREEN, energy))
	draw_rect(Rect2(60.0, 20.0, 360.0, 22.0), Color.WHITE, false, 2.0)
	txt("ZASILANIE", 60.0, 16, Color.WHITE)

	if state == State.WAIT:
		txt("RADIOSTACJA GLIWICE", 280.0, 36, Color("#f1c40f"))
		txt("Wspinaj się po żelaznej wieży (8-bit)", 330.0, 20)
		txt("i omijaj anteny!", 358.0, 20)
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


func draw_segment(cy: float, kind: int, idx: int) -> void:
	var l: float = CX - TOWER_W * 0.5
	var r: float = CX + TOWER_W * 0.5
	var top_y: float = cy - SEG_H * 0.5
	var bot_y: float = cy + SEG_H * 0.5

	draw_rect(Rect2(l, top_y, TOWER_W, SEG_H), Color("#6b4a2b"))
	draw_line(Vector2(l, top_y), Vector2(r, bot_y), Color("#3e2a17"), 3.0)
	draw_line(Vector2(r, top_y), Vector2(l, bot_y), Color("#3e2a17"), 3.0)
	draw_line(Vector2(l, top_y), Vector2(r, top_y), Color("#3e2a17"), 4.0)
	draw_line(Vector2(l, top_y), Vector2(l, bot_y), Color("#8a6238"), 6.0)
	draw_line(Vector2(r, top_y), Vector2(r, bot_y), Color("#8a6238"), 6.0)

	var step: float = PIXEL * 2.0
	var y: float = top_y
	while y <= bot_y + step:
		draw_line(Vector2(l, y), Vector2(r, y + (r - l)), Color("#2b2b2b"), 1.5)
		draw_line(Vector2(r, y), Vector2(l, y + (r - l)), Color("#2b2b2b"), 1.5)
		y += step

	if kind == 1:
		draw_arm(cy, -1.0, idx)
	elif kind == 2:
		draw_arm(cy, 1.0, idx)


func draw_arm(cy: float, dir: float, idx: int) -> void:
	var base_x: float = CX + dir * TOWER_W * 0.5
	var ang: float = 0.0
	if idx >= 0 and idx < seg_angles.size():
		ang = seg_angles[idx]
	var local: Vector2 = Vector2(ARM_LEN, 0).rotated(ang * dir)
	var tip: Vector2 = Vector2(base_x, cy) + Vector2(local.x * dir, local.y)
	draw_line(Vector2(base_x, cy), tip, Color("#c0392b"), 8.0)
	draw_line(Vector2(base_x, cy - 20.0), tip - Vector2(0, 20.0), Color("#c0392b"), 4.0)
	draw_line(tip - Vector2(0, 8.0), tip + Vector2(0, 12.0), Color("#ecf0f1"), 3.0)
	var blink: float = 0.6 + 0.4 * sin(t * 10.0 + float(idx))
	draw_circle(tip + Vector2(0, 14.0), 6.0, Color(1, 0.2, 0.2, blink))
	for k in range(3):
		var frac: float = float(k + 1) / 4.0
		var p: Vector2 = Vector2(base_x, cy).lerp(tip, frac)
		draw_rect(Rect2(pix(p) - Vector2(PIXEL * 0.75, PIXEL * 0.5), Vector2(PIXEL * 1.5, PIXEL)), Color("#bdc3c7"))


func draw_player(x: float, y: float) -> void:
	var p: float = PIXEL * PLAYER_SCALE
	var base: Vector2 = pix(Vector2(x, y))

	var head_w: int = int(6)
	var head_h: int = int(6)
	var head_origin: Vector2 = base + Vector2(-p * 3.0, -p * 14.0)
	for i in range(head_h):
		for j in range(head_w):
			var pos: Vector2 = pix(head_origin + Vector2(j * p, i * p))
			draw_rect(Rect2(pos, Vector2(p, p)), Color("#f1c27d"))

	for j in range(6):
		var pos2: Vector2 = pix(head_origin + Vector2(j * p, 0))
		draw_rect(Rect2(pos2, Vector2(p, p)), Color("#2c2c2c"))

	var torso_w: int = int(8)
	var torso_h: int = int(6)
	var torso_origin: Vector2 = base + Vector2(-p * 4.0, -p * 8.0)
	for ry in range(torso_h):
		for rx in range(torso_w):
			var col: Color = Color("#e67e22")
			if rx == 0 or rx == torso_w - 1:
				col = Color("#c25f14")
			var pos: Vector2 = pix(torso_origin + Vector2(rx * p, ry * p))
			draw_rect(Rect2(pos, Vector2(p, p)), col)

	var letter_size: float = p
	var letters_origin: Vector2 = torso_origin + Vector2(p, p)
	draw_pixel_char(letters_origin + Vector2(0 * (letter_size * 6), 0), PAT_Z, letter_size, Color("#1b1b1b"))
	draw_pixel_char(letters_origin + Vector2(1 * (letter_size * 6), 0), PAT_S, letter_size, Color("#1b1b1b"))
	draw_pixel_char(letters_origin + Vector2(2 * (letter_size * 6), 0), PAT_T, letter_size, Color("#1b1b1b"))
	draw_pixel_char(letters_origin + Vector2(3 * (letter_size * 6), 0), PAT_I, letter_size, Color("#1b1b1b"))

	var pants_w: int = int(6)
	var pants_h: int = int(4)
	var pants_origin: Vector2 = base + Vector2(-p * 3.0, -p * 2.0)
	for ry in range(pants_h):
		for rx in range(pants_w):
			var pos: Vector2 = pix(pants_origin + Vector2(rx * p, ry * p))
			draw_rect(Rect2(pos, Vector2(p, p)), Color("#2c3e50"))

	var boot_origin: Vector2 = base + Vector2(-p * 2.5, p * 2.0)
	for rx in range(2):
		var pos: Vector2 = pix(boot_origin + Vector2(rx * p * 3.0, 0))
		draw_rect(Rect2(pos, Vector2(p * 2.0, p * 2.0)), Color("#111111"))

	var badge_pos: Vector2 = pix(base + Vector2(p * 2.5, -p * 6.5))
	draw_rect(Rect2(badge_pos, Vector2(p * 0.9, p * 0.9)), Color("#f1c40f"))


func txt(s: String, y: float, size: int, col: Color = Color.WHITE) -> void:
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(2.0, y + 2.0), s, HORIZONTAL_ALIGNMENT_CENTER, W, size, Color(0, 0, 0, 0.6))
	draw_string(font, Vector2(0.0, y), s, HORIZONTAL_ALIGNMENT_CENTER, W, size, col)
