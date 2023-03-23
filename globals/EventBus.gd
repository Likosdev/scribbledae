extends Node





signal enemie_defeated(position:Vector2)
signal pickup_collected(position: Vector2, pickup : String)
signal pickup_left(position: Vector2, pickup : String)
signal burger_spawned(position: Vector2, burger : Burger)
signal player_damaged(position: Vector2, health: int)
signal player_defeated(position: Vector2)
signal level_restart
signal player_healed(amount: int)
