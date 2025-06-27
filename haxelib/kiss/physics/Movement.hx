package kiss.physics;

/**
	Based on deepnight blog posts from 2013
	movement logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-1-basics/
	overlap logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-2-collisions/
**/
class DeepnightMovement
{
	public var position(default, null):Position;
	public var velocity(default, null):Velocity;
	public var size(default, null):Size;
	public var events(default, null):Events;

	// velocity.delta_y is incremented by this each frame
	public var gravity:Float = 0.05;

	var has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Int;

	public var neighbours:Neighbours;

	public function new(grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Int)
	{
		var grid_cell_ratio_x = 0.5;
		var grid_cell_ratio_y = 0.5;

		var x = (grid_x + grid_cell_ratio_x) * tile_size;
		var y = (grid_y + grid_cell_ratio_y) * tile_size;

		position = {
			grid_x: grid_x,
			grid_y: grid_y,
			grid_cell_ratio_x: grid_cell_ratio_x,
			grid_cell_ratio_y: grid_cell_ratio_y,
			x: x,
			y: y,
			x_previous: x,
			y_previous: y
		}

		size = {
			tile_size: tile_size,
			radius: tile_size / 2
		}

		velocity = {

		}

		neighbours = {}

		events = {}

		this.has_wall_tile_at = has_wall_tile_at;
	}

	public function teleport_to(x:Float, y:Float)
	{
		position.x = x;
		position.y = y;
		position.grid_x = Std.int(x / size.tile_size);
		position.grid_y = Std.int(y / size.tile_size);
		position.grid_cell_ratio_x = 0.5;
		position.grid_cell_ratio_y = 0.5;
	}

	public function teleport_to_grid(cell:Float, row:Float)
	{
		position.x = (cell * size.tile_size) + 4;
		position.y = (row * size.tile_size) + 4;
		position.x_previous = position.x;
		position.y_previous = position.y;
		position.grid_x = Std.int(cell);
		position.grid_y = Std.int(row);
		position.grid_cell_ratio_x = 0.5;
		position.grid_cell_ratio_y = 0.5;
	}

	public function overlaps(other:DeepnightMovement):Bool
	{
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return distance_squared <= max_distance * max_distance;
	}

	public function overlaps_by(other:DeepnightMovement):Float
	{
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return (max_distance * max_distance) - distance_squared;
	}

	public function update()
	{
		update_movement_horizontal(velocity.delta_x);
		update_movement_vertical(velocity.delta_y);
		update_neighbours();
		update_gravity();
		update_collision();
		update_position();
	}

	inline function update_movement_horizontal(delta:Float)
	{
		position.grid_cell_ratio_x += delta;
	}

	inline function update_movement_vertical(delta:Float)
	{
		position.grid_cell_ratio_y += delta;
	}

	inline function update_neighbours()
	{
		neighbours.is_wall_left = has_wall_tile_at(position.grid_x - 1, position.grid_y);
		neighbours.is_wall_right = has_wall_tile_at(position.grid_x + 1, position.grid_y);
		neighbours.is_wall_up = has_wall_tile_at(position.grid_x, position.grid_y - 1);
		neighbours.is_wall_down = has_wall_tile_at(position.grid_x, position.grid_y + 1);
		neighbours.wall_here = has_wall_tile_at(position.grid_x, position.grid_y);
	}

	inline function update_gravity()
	{
		velocity.delta_y += gravity;
	}

	inline function update_collision()
	{
		// Left collision
		if (position.grid_cell_ratio_x < size.edge_left && neighbours.is_wall_left == 1 && neighbours.wall_here == 0)
		{
			position.grid_cell_ratio_x = size.edge_left; // clamp position
			if (events.on_collide != null)
			{
				events.on_collide(-1, 0);
			}
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Right collision
		if (position.grid_cell_ratio_x > size.edge_right && neighbours.is_wall_right == 1 && neighbours.wall_here == 0)
		{
			position.grid_cell_ratio_x = size.edge_right; // clamp position
			if (events.on_collide != null)
			{
				events.on_collide(1, 0);
			}
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Ceiling collision
		if (position.grid_cell_ratio_y < size.edge_top && neighbours.is_wall_up == 1 && neighbours.wall_here == 0)
		{
			position.grid_cell_ratio_y = size.edge_top; // clamp position
			if (events.on_collide != null)
			{
				events.on_collide(0, -1);
			}
			velocity.delta_y = 0; // stop vertical movement
		}

		// Floor collision
		if (position.grid_cell_ratio_y > size.edge_bottom && neighbours.is_wall_down >= 1 && velocity.delta_y > 0)
		{
			position.grid_cell_ratio_y = size.edge_bottom; // clamp position
			if (events.on_collide != null)
			{
				events.on_collide(0, 1);
			}
			velocity.delta_y = 0; // stop vertical movement
			velocity.stepY = 0;
		}
	}

	function update_position()
	{
		// advance position.grid position if crossing edge

		if (has_wall_tile_at(position.grid_x + 1, position.grid_y) == 0)
		{
			while (position.grid_cell_ratio_x > 1)
			{
				position.grid_cell_ratio_x--;
				position.grid_x++;
			}
		}

		if (has_wall_tile_at(position.grid_x - 1, position.grid_y) == 0)
		{
			while (position.grid_cell_ratio_x < 0)
			{
				position.grid_cell_ratio_x++;
				position.grid_x--;
			}
		}

		// resulting position
		position.x = (position.grid_x + position.grid_cell_ratio_x) * size.tile_size;

		// advance position.grid position if crossing edge
		if (has_wall_tile_at(position.grid_x, position.grid_y + 1) == 0)
		{
			while (position.grid_cell_ratio_y > 1)
			{
				position.grid_y++;
				position.grid_cell_ratio_y--;
			}
		}
		var tileAbove = has_wall_tile_at(position.grid_x, position.grid_y - 1);
		if (tileAbove == 0 || tileAbove == 2 && position.y < position.y_previous)
		{
			while (position.grid_cell_ratio_y < 0)
			{
				position.grid_y--;
				position.grid_cell_ratio_y++;
			}
		}

		// resulting position
		position.y = (position.grid_y + position.grid_cell_ratio_y) * size.tile_size;
	}
}

@:structInit
@:publicFields
class Position
{
	// tile map coordinates
	var grid_x:Int;
	var grid_y:Int;

	// ratios are 0.0 to 1.0  (position inside grid cell)
	var grid_cell_ratio_x:Float;
	var grid_cell_ratio_y:Float;

	// previous pixel coordinates
	var x_previous:Float;
	var y_previous:Float;

	// current pixel coordinates
	var x:Float;
	var y:Float;
}

@:structInit
@:publicFields
class Velocity
{
	public var stepX:Float = 0;
	public var stepY:Float = 0;
	var direction:Int = 0;
	// applied to grid cell ratio each frame
	var delta_x:Float = 0;
	var delta_y:Float = 0;
	var acceleration_x:Float = 0.095;

	// friction applied each frame 0.0 for none, 1.0 for maximum
	var friction_x:Float = 0.30;
	var friction_y:Float = 0.06;
}

@:structInit
@:publicFields
class Size
{
	var edge_left:Float = 0.3;
	var edge_right:Float = 0.7;
	var edge_top:Float = 0.2;
	var edge_bottom:Float = 0.5;
	var tile_size:Int;
	var radius:Float;
}

@:structInit
@:publicFields
class Events
{
	var on_collide:(side_x:Int, side_y:Int) -> Void = null;
}

@:structInit
@:publicFields
class Neighbours
{
	var is_wall_left:Int = 0;
	var is_wall_right:Int = 0;
	var is_wall_up:Int = 0;
	var is_wall_down:Int = 0;
	var wall_here:Int = 0;
}

/*
	This extension of the base movement adds extra functionality typically found in platformer physics

	- predictable jump variables : intuitively adjust the height and duration of a jump to derive y velocity
	- control jump descent : release the jump button before jump apex to descend early
	- faster jump descent : descend from jump apex faster than ascent

	- coyote time : allows jump to be performed a short time after leaving the edge of platform
	- jump buffer : allows jump button press to to be registered before touching ground

 */
class PlatformerMovement extends DeepnightMovement
{
	public var jump_config(default, null):JumpConfig;

	/** y velocity of jump ascent. measured in tiles per step **/
	var velocity_jump:Float;

	/** game steps remaining until jump buffer time ends**/
	public var buffer_step_count_remaining:Int = 0;

	/** game steps remaining until coyote time ends**/
	public var coyote_steps_remaining:Int = 0;

	/** true during the ascent and descent of a jump **/
	var is_jump_in_progress:Bool = false;

	/** true when no vertical movement is possible towards floor **/
	var is_on_ground:Bool = true;

	public var directionOfTravel:Int = 0;

	public function new(grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Int)
	{
		super(grid_x, grid_y, tile_size, has_wall_tile_at);
		jump_config = {}

		// y velocity is determined by jump velocity and gravity so set friction to 0
		velocity.friction_y = 0;

		// calculate gravity
		var jumpFramesSquared = jump_config.ascent_step_count * jump_config.ascent_step_count;
		gravity = (2 * jump_config.height_tiles_max) / jumpFramesSquared;

		// calculate jump velocity
		velocity_jump = -(gravity * jump_config.ascent_step_count);
	}

	/** called from jump button or key press **/
	public function press_jump()
	{
		// jump ascent phase can start if we are on the ground or coyote time did not finish

		var is_within_coyote_time = coyote_steps_remaining > 0;
		if (is_on_ground || is_within_coyote_time)
		{
			ascend();
		}
		else
		{
			// if jump was pressed but could not be performed begin jump buffer
			buffer_step_count_remaining = jump_config.buffer_step_count;
		}
	}

	/** called from jump button or key release **/
	public function release_jump()
	{
		descend();
	}

	/** begin jump ascent phase **/
	inline function ascend()
	{
		// set ascent velocity
		velocity.delta_y = velocity_jump;

		// if we are in ascent phase then jump is in progress
		is_jump_in_progress = true;

		// reset coyote time because we left the ground with a jump
		coyote_steps_remaining = 0;
	}

	/** begin jump descent phase **/
	inline function descend()
	{
		// set descent velocity
		// velocity.delta_y = gravity;//velocity_descent;
	}

	override function update()
	{
		/* 
			most of the update logic for the movement is called from the super class
			however we also perform extra jump logic
		 */

		// jump logic
		//------------

		// count down every step
		coyote_steps_remaining--;
		buffer_step_count_remaining--;

		if (is_on_ground)
		{
			// if we are on the ground then a jump is not in progress or has finished
			is_jump_in_progress = false;

			// reset coyote step counter every step that we are on the ground
			coyote_steps_remaining = jump_config.coyote_step_count;

			// jump ascent phase can be triggered if we are on the ground and jump buffer is in progress
			if (buffer_step_count_remaining > 0)
			{
				// trigger jump ascent phase
				ascend();
				// reset jump step counter because jump buffer has now ended
				buffer_step_count_remaining = 0;
			}
		}

		// movement logic
		//----------------
		var steps = Math.ceil((Math.abs(velocity.delta_x) + Math.abs(velocity.delta_y)) / 0.33);
		if (steps > 10)
			steps = 10;
		if (steps > 0)
		{
			velocity.stepX = velocity.delta_x / steps;
			velocity.stepY = velocity.delta_y / steps;

			while (steps > 0)
			{
				// change position within grid cell by velocity
				super.update_movement_horizontal(velocity.stepX);
				super.update_movement_vertical(velocity.stepY);

				// check for adjacent tiles
				super.update_neighbours();

				// stop movement if colliding with a tile
				super.update_collision();

				// if delta_y is 0 and there is a wall tile below then movement stopped
				// because we collided with the ground
				is_on_ground = velocity.delta_y == 0 && neighbours.is_wall_down > 0;

				// update position within grid and cell
				super.update_position();

				steps--;
			}

			// todo as part of substep? would be better but not really needed...?
			update_gravity();

			velocity.delta_x *= (1.0 - velocity.friction_x);
		}
	}
}

@:structInit
class JumpConfig
{
	/** maximum height of jump, measured in tiles **/
	public var height_tiles_max:Float = 3.1;

	/** duration of jump ascent time, measured in game update steps **/
	public var ascent_step_count = 10;

	/** duration of jump buffer time, measured in game steps**/
	public var buffer_step_count:Int = 5;

	/** duration of coyote time, measured in game steps**/
	public var coyote_step_count:Int = 5;
}
