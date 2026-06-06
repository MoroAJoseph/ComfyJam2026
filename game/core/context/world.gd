class_name WorldContext
extends RefCounted

## Time in seconds from the start of the current day
var day_time: float = 0.0

## Normalized time (0.0 to 1.0) where 0.0 is start of day, 0.5 is noon, 1.0 is end of day
var time_ratio: float = 0.0

## Total days passed
var days_passed: int = 0
