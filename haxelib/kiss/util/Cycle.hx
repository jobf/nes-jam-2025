package kiss.util;

import haxe.ds.Vector;

using kiss.util.Math;

class Cycle<T>
{
	var items:Vector<T>;
	var head:Int = -1;

	public function new(items:Vector<T>)
	{
		this.items = items;
	}

	public function get():T
	{
		head = (head + 1).wrap(items.length);
		return items[head];
	}
}
