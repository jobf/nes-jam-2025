/**
 * Calculate how many tiles fit inside a square
 * cd jam && haxe --run TestTilesInSquare && cd ..
 **/


class TestTilesInSquare {
	static function main() {
		for (n in 0...32) {
			var size = n + 1;
			trace('_____' + tilesRequired(size) + ' tiles required for $size square');
		}
	}

	static function tilesRequired(squareSize) {
		var tileSize = 16;
		var multiple = tileSize;

		while (multiple % squareSize != 0) {
			multiple += tileSize;
		}

		return multiple / tileSize;
	}
}


/*

22:28:59:536   Test.hx:5:, 1 tiles required for 1 square
22:28:59:536   Test.hx:5:, 1 tiles required for 2 square
22:28:59:536   Test.hx:5:, 3 tiles required for 3 square
22:28:59:536   Test.hx:5:, 1 tiles required for 4 square
22:28:59:536   Test.hx:5:, 5 tiles required for 5 square
22:28:59:536   Test.hx:5:, 3 tiles required for 6 square
22:28:59:536   Test.hx:5:, 7 tiles required for 7 square
22:28:59:536   Test.hx:5:, 1 tiles required for 8 square
22:28:59:536   Test.hx:5:, 9 tiles required for 9 square
22:28:59:536   Test.hx:5:, 5 tiles required for 10 square
22:28:59:536   Test.hx:5:, 11 tiles required for 11 square
22:28:59:536   Test.hx:5:, 3 tiles required for 12 square
22:28:59:536   Test.hx:5:, 13 tiles required for 13 square
22:28:59:536   Test.hx:5:, 7 tiles required for 14 square
22:28:59:536   Test.hx:5:, 15 tiles required for 15 square
22:28:59:536   Test.hx:5:, 1 tiles required for 16 square
22:28:59:537   Test.hx:5:, 17 tiles required for 17 square
22:28:59:537   Test.hx:5:, 9 tiles required for 18 square
22:28:59:537   Test.hx:5:, 19 tiles required for 19 square
22:28:59:537   Test.hx:5:, 5 tiles required for 20 square
22:28:59:537   Test.hx:5:, 21 tiles required for 21 square
22:28:59:537   Test.hx:5:, 11 tiles required for 22 square
22:28:59:537   Test.hx:5:, 23 tiles required for 23 square
22:28:59:537   Test.hx:5:, 3 tiles required for 24 square
22:28:59:537   Test.hx:5:, 25 tiles required for 25 square
22:28:59:537   Test.hx:5:, 13 tiles required for 26 square
22:28:59:537   Test.hx:5:, 27 tiles required for 27 square
22:28:59:537   Test.hx:5:, 7 tiles required for 28 square
22:28:59:537   Test.hx:5:, 29 tiles required for 29 square
22:28:59:537   Test.hx:5:, 15 tiles required for 30 square
22:28:59:537   Test.hx:5:, 31 tiles required for 31 square
22:28:59:537   Test.hx:5:, 2 tiles required for 32 square

*/
