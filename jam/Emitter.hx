import nes.Tiles;
import kiss.util.Math;

using kiss.util.Math.Grid2d;

abstract class Emitter
{
	var particles:Array<Particle> = [];

	public var x_start:Float;
	public var y_start:Float;
	var tilesInColumn = 32;

	public var isEmitting:Bool = true;

	public function new() {}

	public function clear()
	{
		for (particle in particles)
		{
			particle.sprite.changeTile(TileSetter.EmptySpriteId);
		}
	}

	
	public function update()
	{
		var count = particles.length;
		while (count-- > 0)
		{
			var p = particles[count];
			p.x_old = p.x;
			p.x += p.velX;
			p.velX += p.velX * p.accX;

			p.y_old = p.y;
			p.y += p.velY;
			p.velY += p.velY * p.accY;
			p.age++;
			updateParticle(p);
			if (!p.sprite.isUsed)
			{
				p.sprite.changeTile(TileSetter.EmptySpriteId);
				p.velY = 0;
				p.x = -1000;
				p.y = -1000;
				p.x_old = -1000;
				p.y_old = -1000;
				p.sprite.move(-1000, -1000);
				particles.remove(p);
			}
		}
	}

	public function draw(t:Float)
	{
		for (p in particles)
		{
			var x = lerp(p.x_old, p.x, t);
			var y = lerp(p.y_old, p.y, t);
			var next_x = p.x < p.x_old ? Math.ceil(x) : Math.floor(x);
			var next_y = p.y < p.y_old ? Math.ceil(y) : Math.floor(y);
			p.sprite.move(next_x, next_y);
		}
	}

	public function reset()
	{
		particles = [];
	}

	abstract function emitParticle(sprite:Sprite):Particle;

	abstract function updateParticle(p:Particle):Void;
}

enum BubbleType
{
	AIR;
	SOAP;
}

@:publicFields
class Particle
{
	var sprite:Sprite;
	var x:Float;
	var y:Float;
	var x_old:Float;
	var y_old:Float;
	var velX:Float = 0;
	var velY:Float = 0;
	var accX:Float = 0;
	var accY:Float = 0;
	var age:Int = 0;

	function new(x:Float, y:Float, sprite:Sprite)
	{
		this.x = x;
		this.y = y;
		this.x_old = x;
		this.y_old = y;

		this.sprite = sprite;

		sprite.move(x, y);
	}
}

class Bubbler extends Emitter
{
	public var waterLevel:Int = 0;

	public var mode:BubbleType = AIR;
	public var collisions:Array<Int>;

	public function emitParticle(sprite:Sprite):Particle
	{
		if (sprite == null)
		{
			return null;
		}

		sprite.changeTile(49);
		sprite.tileB.changeBgPalette(0);
		sprite.tileF.changeBgPalette(0);

		var particle = new Particle(x_start, y_start, sprite);
		particle.velX = 0.0;
		particle.velY = mode == SOAP ? 0 : -toPixelsPerFrame(50);
		particle.accX = 0.0;
		particle.accY = 0.0;
		particles.push(particle);
		return particle;
	}

	static var solidTile = 50;
	static var width = 2;

	public function solidfy()
	{
		for (p in particles)
		{
			if (mode == SOAP && p.sprite.tileF.tile != solidTile)
			{
				p.sprite.changeTile(solidTile);
				p.velY = 0;
				var bubbleTop = p.y - 8;
				var bubbleLeft = p.x - 8;
				var c = Math.floor(bubbleLeft / 8);
				var r = Math.floor(bubbleTop / 8);
				p.x = (c * 8) + 8;
				p.y = (r * 8) + 8;
				p.x_old = p.x;
				p.y_old = p.y;
				for (n in 0...width)
				{
					var i = tilesInColumn.index(c + n, r);
					if (i > 0)
					{
						collisions[i] = 2;
					}
				}
			}
		}
	}

	public function updateParticle(p:Particle)
	{
		if (isOutsideLevel(p.y))
		{
			p.sprite.isUsed = false;
		}
		else
		{
			if (mode == SOAP)
			{
				if (p.age > 5 && p.sprite.tileF.tile != solidTile)
				{
					p.velY = -toPixelsPerFrame(50);
				}
			}
			else
			{
				if (!isUnderWater(p.y))
				{
					trace('no longer under water');
					p.sprite.isUsed = false;
				}
			}
		}
	}

	inline function isOutsideLevel(y:Float):Bool
	{
		return y < -tilesInColumn;
	}

	function isUnderWater(y:Float):Bool
	{
		return Std.int((y - 16) / 16) > waterLevel;
	}
}

class Breather extends Emitter
{
	public var waterLevel:Int = 0;

	public function emitParticle(sprite:Sprite):Particle
	{
		if (sprite == null)
		{
			return null;
		}

		sprite.changeTile(48);
		sprite.tileB.changeBgPalette(0);
		sprite.tileF.changeBgPalette(0);

		var particle = new Particle(x_start, y_start, sprite);
		particle.velX = 0.0;
		particle.velY = -toPixelsPerFrame(75);
		particle.accX = 0.0;
		particle.accY = 0.0;
		particles.push(particle);
		return particle;
	}

	public function updateParticle(p:Particle)
	{
		if (isOutsideLevel(p.y))
		{
			p.sprite.isUsed = false;
		}
		else
		{
			if (!isUnderWater(p.y))
			{
				// trace('no longer under water');
				p.sprite.isUsed = false;
			}
		}
	}

	inline function isOutsideLevel(y:Float):Bool
	{
		return y < -tilesInColumn;
	}

	function isUnderWater(y:Float):Bool
	{
		return Std.int((y - 16) / 16) > waterLevel;
	}
}

class Kisser extends Emitter
{
	public function emitParticle(sprite:Sprite):Particle
	{
		if (sprite == null)
		{
			return null;
		}
		sprite.changeTile(74);
		sprite.changePalette(2);

		var particle = new Particle(x_start, y_start, sprite);
		particle.velX = 0.0;
		particle.velY = -toPixelsPerFrame(100);
		particle.accX = 0.0;
		particle.accY = 0.0;
		particles.push(particle);
		return particle;
	}

	public function updateParticle(p:Particle)
	{
		if (p.age > 5)
		{
			p.sprite.isUsed = false;
		}
	}
}

class Soaper extends Emitter
{
	public var waterLevel:Int = 0;

	var mode:BubbleType = AIR;

	public function emitParticle(sprite:Sprite):Particle
	{
		if (sprite == null)
		{
			return null;
		}

		// weird stuff with soap so we just hiding it for now
		sprite.changeTile(TileSetter.EmptySpriteId);

		var particle = new Particle(x_start + 8, y_start + 8, sprite);
		particle.velX = 0.0;
		particle.velY = toPixelsPerFrame(50);
		particle.accX = 0.0;
		particle.accY = 0.0;
		particles.push(particle);
		return particle;
	}

	public function updateParticle(p:Particle)
	{
		if (isOutsideLevel(p.y))
		{
			p.sprite.isUsed = false;
		}
	}

	inline function isOutsideLevel(y:Float):Bool
	{
		return y > 256;
	}
}
