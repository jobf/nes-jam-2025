

import haxe.io.Path;
import sys.io.File;

using DateTools;

/**
 * haxe --run Deploy
 */

class Deploy{
	public static function main() {
		
		var host_remote = File.getContent("secrets/remote_host");
		var path_remote = File.getContent("secrets/remote_path");

		if(host_remote.length == 0 || path_remote.length == 0){
			trace('Cannot deploy without secrets.');
		}

		var version = Date.now().format("%y%m%d-%H%M");

		var path_local = "_dist/html5/bin";
		var path_remote = '$host_remote:$path_remote/$version';

		trace('deploying to $path_remote');
		Sys.command('scp -r $path_local $path_remote');
	}

}