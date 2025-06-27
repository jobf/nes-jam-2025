import nes.Nametable;
import utest.Assert;
import utest.Test;
import utest.ui.Report;
import utest.Runner;

class UnitTests {
	public static function main() {
		var runner = new Runner();
		runner.addCase(new NametableTests());
		Report.create(runner);
		runner.run();
	}
}

class NametableTests extends Test {
	// function test_fail(){
	// 	Assert.isTrue(false);
	// }

	function test_TileIndex_default(){
		var index:TileIndex = 123456789;
		Assert.equals(index.layer(), 0);
		Assert.equals(index.index(), 123456789);
	}

	function test_TileIndex_front(){
		var index = new TileIndex(1, 123456789);
		Assert.equals(index.layer(), 1);
		Assert.equals(index.index(), 123456789);
	}

	function test_TileIndex_back(){
		var index = new TileIndex(0, 123456789);
		Assert.equals(index.layer(), 0);
		Assert.equals(index.index(), 123456789);
	}

	function test_PaletteIndex_clamp_to_0(){
		var index:PaletteIndex = -3000;
		Assert.equals(0, index);
	}

	function test_PaletteIndex_clamp_to_3(){
		var index:PaletteIndex = 3000;
		Assert.equals(3, index);
	}
}
