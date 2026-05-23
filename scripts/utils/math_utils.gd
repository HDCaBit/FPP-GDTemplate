class_name MathUtils

## Lerp a float with delta-time smoothing
static func smooth_lerp(from: float, to: float, speed: float, delta: float) -> float:
	return lerp(from, to, 1.0 - exp(-speed * delta))

## Lerp a Vector3 with delta-time smoothing
static func smooth_lerp_v3(from: Vector3, to: Vector3, speed: float, delta: float) -> Vector3:
	return from.lerp(to, 1.0 - exp(-speed * delta))

## Remap a value from one range to another
static func remap(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)

## Clamp and remap
static func remap_clamped(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	var t := clampf((value - from_min) / (from_max - from_min), 0.0, 1.0)
	return to_min + t * (to_max - to_min)

## Random direction on the XZ plane
static func random_direction_xz() -> Vector3:
	var angle := randf() * TAU
	return Vector3(cos(angle), 0.0, sin(angle))

## Calculate fall damage based on velocity
static func calculate_fall_damage(fall_velocity: float, threshold: float = 10.0, multiplier: float = 2.0) -> float:
	if absf(fall_velocity) < threshold:
		return 0.0
	return (absf(fall_velocity) - threshold) * multiplier
