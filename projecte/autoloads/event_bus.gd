extends Node

signal player_health_changed(current: float, max_health: float)
signal xp_gained(amount: int)
signal player_leveled_up(options: Array[UpgradeData])
signal upgrade_selected(upgrade: UpgradeData)
signal enemy_died(position: Vector3, enemy_type: String)
signal run_ended(stats: Dictionary)
signal game_paused(is_paused: bool)
