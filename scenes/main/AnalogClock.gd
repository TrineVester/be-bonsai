class_name AnalogClock
extends Control


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var center := size / 2.0
	var r      := minf(size.x, size.y) / 2.0 - 2.0
	var white  := Color(1.0, 1.0, 1.0, 0.90)
	var dim    := Color(1.0, 1.0, 1.0, 0.25)

	draw_arc(center, r, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.15), 1.0)

	for h in 12:
		var angle := h / 12.0 * TAU - PI * 0.5
		var dir   := Vector2(cos(angle), sin(angle))
		var tick_len := 5.0 if (h % 3 == 0) else 3.0
		draw_line(center + dir * (r - tick_len), center + dir * r, dim, 1.5)

	var hour   := GameClock.get_hour() % 12
	var minute := GameClock.get_minute()

	var h_angle := (float(hour) + float(minute) / 60.0) / 12.0 * TAU - PI * 0.5
	draw_line(center, center + Vector2(cos(h_angle), sin(h_angle)) * r * 0.5,
			white, 2.0, true)

	var m_angle := float(minute) / 60.0 * TAU - PI * 0.5
	draw_line(center, center + Vector2(cos(m_angle), sin(m_angle)) * r * 0.75,
			white, 1.5, true)

	draw_circle(center, 2.0, white)
