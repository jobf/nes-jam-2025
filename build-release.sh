# pre-process assets for distribution
haxelib run ldtk-crush jam/assets/levels.ldtk Tiles jam/assets-final
# build final 
lime build html5 -clean -final
# zip for release
(cd _dist/html5/bin; zip -r ../../../release.zip ./)