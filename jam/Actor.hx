import nes.Tiles;
import kiss.graphics.AnimateTile;
import kiss.physics.Movement;
import kiss.util.Math;

@:publicFields
class Actor
{
	public var sprite(default, null):Sprite;
	public var sprite_offset_y:Float = -11;
	public var movement(default, null):PlatformerMovement;

	var position_x_previous:Float;
	var position_y_previous:Float;

	public var facing:Int = 1;
	public var is_moving_x(get, never):Bool;

	var hitEdgeX:Bool;
	var hitEdgeY:Bool;

	public var isReachedGoal:Bool = false;

	var animation:AnimateTile;

	public var isOverlappingEntity:Bool;

	var isMovementHeld:Bool;

	function get_is_moving_x():Bool
	{
		return movement.velocity.delta_x != 0;
	}

	public var velocity_x_max:Float = 0.3;
	public var velocity_y_max:Float = 0.5;

	var is_jumping:Bool = false;
	var jump_velocity:Float = -0.85;

	public function new(sprite:Sprite, grid_x:Int, grid_y:Int, cell_size_px:Int, stats:EntityStats, getCollisionId:(grid_x:Int, grid_y:Int) -> Int)
	{
		this.sprite = sprite;
		sprite.changeTile(0);
		sprite.isUsed = true;
		@:privateAccess
		sprite.tileB.pivotX = 0.5;
		@:privateAccess
		sprite.tileF.pivotX = 0.5;
		@:privateAccess
		sprite.tileB.pivotY = 0.5;
		@:privateAccess
		sprite.tileF.pivotY = 0.5;

		var config:JumpConfig = {
			height_tiles_max: stats.jumpHeightTilesMax,
			ascent_step_count: stats.jumpFramesAscent,
			buffer_step_count: stats.jumpFramesBuffer,
			coyote_step_count: stats.jumpFramesCoyote
		}
		movement = new PlatformerMovement(grid_x, grid_y, cell_size_px, getCollisionId);
		var anims:Map<String, TileConfig> = [
			"idle" => {
				frames: [0],
				frame_rate: 1000
			},
			"jump" => {
				mode: FRAME,
				frames: [8],
				frame_rate: msToFrames(Std.int((1 / 1) * 1000))
			},
			"walk" => {
				frames: [1, 2, 3],
				frame_rate: msToFrames(Std.int((1 / 6) * 1000))
			},
			"kiss" => {
				frames: range(24, 24 + 5),
				frame_rate: msToFrames(Std.int((1 / 12) * 1000))
			}
		];

		animation = new AnimateTile(anims, tile_index ->
		{
			sprite.changeTile(tile_index);
		});

		movement.position.x_previous = movement.position.x;
		movement.position.y_previous = movement.position.y;

	}

	var getFront:(grid_x:Int, grid_y:Int) -> Int;

	public function update()
	{
		animation.step();

		movement.position.x_previous = movement.position.x;
		movement.position.y_previous = movement.position.y;

		if (movement.velocity.direction != 0)
		{
			// accelerate horizontally
			movement.velocity.delta_x += (movement.velocity.direction * movement.velocity.acceleration_x);
		}

		movement.update();
	}

	public function draw(step_ratio:Float)
	{
		var x = lerp(movement.position.x_previous, movement.position.x, step_ratio);
		var y = lerp(movement.position.y_previous, movement.position.y, step_ratio) + sprite_offset_y;

		sprite.move(x, y);

		sprite.flipX(facing != 1);
	}

	public function move_in_direction_x(direction:Int)
	{
		isMovementHeld = true;
		movement.directionOfTravel = direction;
		facing = direction;
		movement.velocity.direction = direction;

		if (!isOverlappingEntity)
		{
			animation.play_animation("walk");
		}
	}

	public function stop_x()
	{
		isMovementHeld = false;
		movement.velocity.direction = 0;

		if (!isOverlappingEntity)
		{
			animation.play_animation("idle");
		}
	}

	public function jump()
	{
		movement.press_jump();
		animation.play_animation("jump");
	}

	public function drop()
	{
		movement.release_jump();
		if (isMovementHeld)
		{
			animation.play_animation("walk");
		}
		else
		{
			animation.play_animation("idle");
		}
	}

	public function is_in_cell(column:Int, row:Int)
	{
		return movement.position.grid_x == column && movement.position.grid_y == row;
	}

	public function clearJumpBuffer()
	{
		movement.coyote_steps_remaining = 0;
		movement.buffer_step_count_remaining = 0;
		movement.directionOfTravel = 0;
		movement.velocity.delta_x = 0;
		movement.velocity.delta_y = 0;
	}

}

@:publicFields
@:structInit
class EntityStats
{
	var jumpFramesAscent:Int;
	var jumpFramesDescent:Int;
	var jumpFramesCoyote:Int;
	var jumpFramesBuffer:Int;
	var jumpHeightTilesMax:Int;
	var jumpHeightTilesMin:Int;
	// var speedHorizontal:Float;
	// var frictionHorizontal:Float;
}
