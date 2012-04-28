package;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Stage;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
#if flash
import flash.media.SoundMixer;
#end
import nme.media.SoundTransform;
import nme.system.System;
import nme.utils.ByteArray;
import haxe.Timer;

/**
 * Static catch-all class used to access global properties and functions.
 */
class Utils
{
	/**
	 * The HaxePunk major version.
	 */
	public static inline var VERSION:String = "2.5.0";

	/**
	 * The standard layer used since only flash can handle negative indicies in arrays, set your layers to some offset of this
	 */
	public static inline var BASELAYER:Int = 10;

	/**
	 * Flash equivalent: Number.MAX_VALUE
	 */
#if flash
	public static inline var NUMBER_MAX_VALUE = untyped __global__["Number"].MAX_VALUE;
#else
	public static inline var NUMBER_MAX_VALUE = 179 * Math.pow(10, 306); // 1.79e+308
#end

	/**
	 * The color black defined for neko (BitmapInt32) or flash (Int)
	 */
#if neko
	public static inline var blackColor = { rgb: 0x000000, a: 1 }; // BitmapInt32
#else
	public static inline var blackColor = 0xFF000000;
#end

	/**
	 * Width of the game.
	 */
	public static var width:Int;

	/**
	 * Height of the game.
	 */
	public static var height:Int;

	/**
	 * If the game is running at a fixed framerate.
	 */
	public static var fixed:Bool;

	/**
	 * The framerate assigned to the stage.
	 */
	public static var frameRate:Float = 0;

	/**
	 * The framerate assigned to the stage.
	 */
	public static var assignedFrameRate:Float;

	/**
	 * Time elapsed since the last frame (non-fixed framerate only).
	 */
	public static var elapsed:Float;

	/**
	 * Timescale applied to HXP.elapsed (non-fixed framerate only).
	 */
	public static var rate:Float = 1;

	/**
	 * A rectangle representing the size of the screen.
	 */
	public static var bounds:Rectangle;

	/**
	 * The default font file to use
	 */
#if nme
	public static var defaultFont:String = "font/04B_03__.ttf";
#else
	public static var defaultFont:String = "default";
#end

	/**
	 * Point used to determine drawing offset in the render loop.
	 */
	public static var camera:Point = new Point();

	public static function toBoolean(s:String):Bool
	{
		return (s == "true") ? true : false;
	}
		
	/**
	 * Empties an array of its' contents
	 * @param array filled array
	 */
	public static inline function clear(array:Array<Dynamic>)
	{
		var i:Int;
		for (i in 0...array.length)
			array.pop();
	}

	/**
	 * Sets the camera position.
	 * @param	x	X position.
	 * @param	y	Y position.
	 */
	public static inline function setCamera(x:Float = 0, y:Float = 0)
	{
		camera.x = x;
		camera.y = y;
	}

	/**
	 * Resets the camera position.
	 */
	public static inline function resetCamera()
	{
		camera.x = camera.y = 0;
	}

	/**
	 * Global volume factor for all sounds, a value from 0 to 1.
	 */
	public static var volume(getVolume, setVolume):Float;
	private static inline function getVolume():Float { return _volume; }
	private static function setVolume(value:Float):Float
	{
		if (value < 0) value = 0;
		if (_volume == value) return value;
		_soundTransform.volume = _volume = value;
		#if flash
		SoundMixer.soundTransform = _soundTransform;
		#end
		return _volume;
	}

	/**
	 * Global panning factor for all sounds, a value from -1 to 1.
	 */
	public static var pan(getPan, setPan):Float;
	private static inline function getPan():Float { return _pan; }
	private static function setPan(value:Float):Float
	{
		if (value < -1) value = -1;
		if (value > 1) value = 1;
		if (_pan == value) return value;
		_soundTransform.pan = _pan = value;
		#if flash
		SoundMixer.soundTransform = _soundTransform;
		#end
		return _pan;
	}

	/**
	 * Randomly chooses and returns one of the provided values.
	 * @param	objs		The Objects you want to randomly choose from. Can be ints, Floats, Points, etc.
	 * @return	A randomly chosen one of the provided parameters.
	 */
	public static inline function choose(objs:Array<Dynamic>):Dynamic
	{
		return objs[rand(objs.length)];
	}

	/**
	 * Finds the sign of the provided value.
	 * @param	value		The Float to evaluate.
	 * @return	1 if value > 0, -1 if value < 0, and 0 when value == 0.
	 */
	public static inline function sign(value:Float):Int
	{
		return value < 0 ? -1 : (value > 0 ? 1 : 0);
	}

	/**
	 * Approaches the value towards the target, by the specified amount, without overshooting the target.
	 * @param	value	The starting value.
	 * @param	target	The target that you want value to approach.
	 * @param	amount	How much you want the value to approach target by.
	 * @return	The new value.
	 */
	public static inline function approach(value:Float, target:Float, amount:Float):Float
	{
		return value < target ? (target < value + amount ? target : value + amount) : (target > value - amount ? target : value - amount);
	}

	/**
	 * Linear interpolation between two values.
	 * @param	a		First value.
	 * @param	b		Second value.
	 * @param	t		Interpolation factor.
	 * @return	When t=0, returns a. When t=1, returns b. When t=0.5, will return halfway between a and b. Etc.
	 */
	public static inline function lerp(a:Float, b:Float, t:Float = 1):Float
	{
		return a + (b - a) * t;
	}

	/**
	 * Linear interpolation between two colors.
	 * @param	fromColor		First color.
	 * @param	toColor			Second color.
	 * @param	t				Interpolation value. Clamped to the range [0, 1].
	 * return	RGB component-interpolated color value.
	 */
	public static inline function colorLerp(fromColor:Int, toColor:Int, t:Float = 1):Int
	{
		if (t <= 0) { return fromColor; }
		if (t >= 1) { return toColor; }
		var a:Int = fromColor >> 24 & 0xFF,
			r:Int = fromColor >> 16 & 0xFF,
			g:Int = fromColor >> 8 & 0xFF,
			b:Int = fromColor & 0xFF,
			dA:Int = (toColor >> 24 & 0xFF) - a,
			dR:Int = (toColor >> 16 & 0xFF) - r,
			dG:Int = (toColor >> 8 & 0xFF) - g,
			dB:Int = (toColor & 0xFF) - b;
		a += Std.int(dA * t);
		r += Std.int(dR * t);
		g += Std.int(dG * t);
		b += Std.int(dB * t);
		return a << 24 | r << 16 | g << 8 | b;
	}

	/**
	 * Steps the object towards a point.
	 * @param	object		Object to move (must have an x and y property).
	 * @param	x			X position to step towards.
	 * @param	y			Y position to step towards.
	 * @param	distance	The distance to step (will not overshoot target).
	 */
	public static function stepTowards(object:Dynamic, x:Float, y:Float, distance:Float = 1)
	{
		point.x = x - object.x;
		point.y = y - object.y;
		if (point.length <= distance)
		{
			object.x = x;
			object.y = y;
			return;
		}
		point.normalize(distance);
		object.x += point.x;
		object.y += point.y;
	}

	/**
	 * Anchors the object to a position.
	 * @param	object		The object to anchor.
	 * @param	anchor		The anchor object.
	 * @param	distance	The max distance object can be anchored to the anchor.
	 */
	public static inline function anchorTo(object:Dynamic, anchor:Dynamic, distance:Float = 0)
	{
		point.x = object.x - anchor.x;
		point.y = object.y - anchor.y;
		if (point.length > distance) point.normalize(distance);
		object.x = anchor.x + point.x;
		object.y = anchor.y + point.y;
	}

	/**
	 * Finds the angle (in degrees) from point 1 to point 2.
	 * @param	x1		The first x-position.
	 * @param	y1		The first y-position.
	 * @param	x2		The second x-position.
	 * @param	y2		The second y-position.
	 * @return	The angle from (x1, y1) to (x2, y2).
	 */
	public static inline function angle(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		var a:Float = Math.atan2(y2 - y1, x2 - x1) * DEG;
		return a < 0 ? a + 360 : a;
	}

	/**
	 * Sets the x/y values of the provided object to a vector of the specified angle and length.
	 * @param	object		The object whose x/y properties should be set.
	 * @param	angle		The angle of the vector, in degrees.
	 * @param	length		The distance to the vector from (0, 0).
	 * @param	x			X offset.
	 * @param	y			Y offset.
	 */
	public static inline function angleXY(object:Dynamic, angle:Float, length:Float = 1, x:Float = 0, y:Float = 0)
	{
		angle *= RAD;
		object.x = Math.cos(angle) * length + x;
		object.y = Math.sin(angle) * length + y;
	}

	/**
	 * Rotates the object around the anchor by the specified amount.
	 * @param	object		Object to rotate around the anchor.
	 * @param	anchor		Anchor to rotate around.
	 * @param	angle		The amount of degrees to rotate by.
	 */
	public static inline function rotateAround(object:Dynamic, anchor:Dynamic, angle:Float = 0, relative:Bool = true)
	{
		if (relative) angle += Utils.angle(anchor.x, anchor.y, object.x, object.y);
		Utils.angleXY(object, angle, Utils.distance(anchor.x, anchor.y, object.x, object.y), anchor.x, anchor.y);
	}

	/**
	 * Find the distance between two points.
	 * @param	x1		The first x-position.
	 * @param	y1		The first y-position.
	 * @param	x2		The second x-position.
	 * @param	y2		The second y-position.
	 * @return	The distance.
	 */
	public static inline function distance(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float
	{
		return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
	}

	public static inline function distanceSquared(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float
	{
		return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
	}

	/**
	 * Find the distance between two rectangles. Will return 0 if the rectangles overlap.
	 * @param	x1		The x-position of the first rect.
	 * @param	y1		The y-position of the first rect.
	 * @param	w1		The width of the first rect.
	 * @param	h1		The height of the first rect.
	 * @param	x2		The x-position of the second rect.
	 * @param	y2		The y-position of the second rect.
	 * @param	w2		The width of the second rect.
	 * @param	h2		The height of the second rect.
	 * @return	The distance.
	 */
	public static function distanceRects(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Float
	{
		if (x1 < x2 + w2 && x2 < x1 + w1)
		{
			if (y1 < y2 + h2 && y2 < y1 + h1) return 0;
			if (y1 > y2) return y1 - (y2 + h2);
			return y2 - (y1 + h1);
		}
		if (y1 < y2 + h2 && y2 < y1 + h1)
		{
			if (x1 > x2) return x1 - (x2 + w2);
			return x2 - (x1 + w1);
		}
		if (x1 > x2)
		{
			if (y1 > y2) return distance(x1, y1, (x2 + w2), (y2 + h2));
			return distance(x1, y1 + h1, x2 + w2, y2);
		}
		if (y1 > y2) return distance(x1 + w1, y1, x2, y2 + h2);
		return distance(x1 + w1, y1 + h1, x2, y2);
	}

	/**
	 * Find the distance between a point and a rectangle. Returns 0 if the point is within the rectangle.
	 * @param	px		The x-position of the point.
	 * @param	py		The y-position of the point.
	 * @param	rx		The x-position of the rect.
	 * @param	ry		The y-position of the rect.
	 * @param	rw		The width of the rect.
	 * @param	rh		The height of the rect.
	 * @return	The distance.
	 */
	public static function distanceRectPoint(px:Float, py:Float, rx:Float, ry:Float, rw:Float, rh:Float):Float
	{
		if (px >= rx && px <= rx + rw)
		{
			if (py >= ry && py <= ry + rh) return 0;
			if (py > ry) return py - (ry + rh);
			return ry - py;
		}
		if (py >= ry && py <= ry + rh)
		{
			if (px > rx) return px - (rx + rw);
			return rx - px;
		}
		if (px > rx)
		{
			if (py > ry) return distance(px, py, rx + rw, ry + rh);
			return distance(px, py, rx + rw, ry);
		}
		if (py > ry) return distance(px, py, rx, ry + rh);
		return distance(px, py, rx, ry);
	}

	/**
	 * Clamps the value within the minimum and maximum values.
	 * @param	value		The Float to evaluate.
	 * @param	min			The minimum range.
	 * @param	max			The maximum range.
	 * @return	The clamped value.
	 */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		if (max > min)
		{
			value = value < max ? value : max;
			return value > min ? value : min;
		}
		value = value < min ? value : min;
		return value > max ? value : max;
	}

	/**
	 * Clamps the object inside the rectangle.
	 * @param	object		The object to clamp (must have an x and y property).
	 * @param	x			Rectangle's x.
	 * @param	y			Rectangle's y.
	 * @param	width		Rectangle's width.
	 * @param	height		Rectangle's height.
	 */
	public static inline function clampInRect(object:Dynamic, x:Float, y:Float, width:Float, height:Float, padding:Float = 0)
	{
		object.x = clamp(object.x, x + padding, x + width - padding);
		object.y = clamp(object.y, y + padding, y + height - padding);
	}

	/**
	 * Transfers a value from one scale to another scale. For example, scale(.5, 0, 1, 10, 20) == 15, and scale(3, 0, 5, 100, 0) == 40.
	 * @param	value		The value on the first scale.
	 * @param	min			The minimum range of the first scale.
	 * @param	max			The maximum range of the first scale.
	 * @param	min2		The minimum range of the second scale.
	 * @param	max2		The maximum range of the second scale.
	 * @return	The scaled value.
	 */
	public static inline function scale(value:Float, min:Float, max:Float, min2:Float, max2:Float):Float
	{
		return min2 + ((value - min) / (max - min)) * (max2 - min2);
	}

	/**
	 * Transfers a value from one scale to another scale, but clamps the return value within the second scale.
	 * @param	value		The value on the first scale.
	 * @param	min			The minimum range of the first scale.
	 * @param	max			The maximum range of the first scale.
	 * @param	min2		The minimum range of the second scale.
	 * @param	max2		The maximum range of the second scale.
	 * @return	The scaled and clamped value.
	 */
	public static function scaleClamp(value:Float, min:Float, max:Float, min2:Float, max2:Float):Float
	{
		value = min2 + ((value - min) / (max - min)) * (max2 - min2);
		if (max2 > min2)
		{
			value = value < max2 ? value : max2;
			return value > min2 ? value : min2;
		}
		value = value < min2 ? value : min2;
		return value > max2 ? value : max2;
	}

	/**
	 * The random seed used by FP's random functions.
	 */
	public static var randomSeed(getRandomSeed, setRandomSeed):Int;
	private static inline function getRandomSeed():Int { return _getSeed; }
	private static inline function setRandomSeed(value:Int):Int
	{
		_seed = Std.int(clamp(value, 1.0, 2147483646.0));
		_getSeed = _seed;
		return _seed;
	}

	/**
	 * Randomizes the random seed using Flash's Math.random() function.
	 */
	public static inline function randomizeSeed()
	{
		randomSeed = Std.int(2147483647.0 * Math.random());
	}

	/**
	 * A pseudo-random Float produced using FP's random seed, where 0 <= Float < 1.
	 */
	public static var random(getRandom, null):Float;
	private static inline function getRandom():Float
	{
		_seed = Std.int((_seed * 16807.0) % 2147483647.0);
		return _seed / 2147483647.0;
	}

	/**
	 * Returns a pseudo-random Int.
	 * @param	amount		The returned Int will always be 0 <= Int < amount.
	 * @return	The Int.
	 */
	public static inline function rand(amount:Int):Int
	{
		_seed = Std.int((_seed * 16807.0) % 2147483647.0);
		return Std.int((_seed / 2147483647.0) * amount);
	}

	private static function indexOf<T>(a:Array<T>, v:T):Int
	{
		var i = 0;
		for( v2 in a ) {
			if( v == v2 )
				return i;
			i++;
		}
		return -1;
	}

	/**
	 * Returns the next item after current in the list of options.
	 * @param	current		The currently selected item (must be one of the options).
	 * @param	options		An array of all the items to cycle through.
	 * @param	loop		If true, will jump to the first item after the last item is reached.
	 * @return	The next item in the list.
	 */
	public static inline function next<T>(current:T, options:Array<T>, loop:Bool = true):Dynamic
	{
		if (loop)
			return options[(indexOf(options, current) + 1) % options.length];
		else
			return options[Std.int(Math.max(indexOf(options, current) + 1, options.length - 1))];
	}

	/**
	 * Returns the item previous to the current in the list of options.
	 * @param	current		The currently selected item (must be one of the options).
	 * @param	options		An array of all the items to cycle through.
	 * @param	loop		If true, will jump to the last item after the first is reached.
	 * @return	The previous item in the list.
	 */
	public static inline function prev<T>(current:T, options:Array<T>, loop:Bool = true):Dynamic
	{
		if (loop)
			return options[((indexOf(options, current) - 1) + options.length) % options.length];
		else
			return options[Std.int(Math.max(indexOf(options, current) - 1, 0))];
	}

	/**
	 * Swaps the current item between a and b. Useful for quick state/string/value swapping.
	 * @param	current		The currently selected item.
	 * @param	a			Item a.
	 * @param	b			Item b.
	 * @return	Returns a if current is b, and b if current is a.
	 */
	public static inline function swap(current:Dynamic, a:Dynamic, b:Dynamic):Dynamic
	{
		return current == a ? b : a;
	}

	/**
	 * Creates a color value by combining the chosen RGB values.
	 * @param	R		The red value of the color, from 0 to 255.
	 * @param	G		The green value of the color, from 0 to 255.
	 * @param	B		The blue value of the color, from 0 to 255.
	 * @return	The color Int.
	 */
	public static inline function getColorRGB(R:Int = 0, G:Int = 0, B:Int = 0):Int
	{
		return R << 16 | G << 8 | B;
	}

	/**
	 * Creates a color value with the chosen HSV values.
	 * @param	h		The hue of the color (from 0 to 1).
	 * @param	s		The saturation of the color (from 0 to 1).
	 * @param	v		The value of the color (from 0 to 1).
	 * @return	The color Int.
	 */
	public static function getColorHSV(h:Float, s:Float, v:Float):Int
	{
		h = Std.int(h * 360);
		var hi:Int = Math.floor(h / 60) % 6,
			f:Float = h / 60 - Math.floor(h / 60),
			p:Float = (v * (1 - s)),
			q:Float = (v * (1 - f * s)),
			t:Float = (v * (1 - (1 - f) * s));
		switch (hi)
		{
			case 0: return Std.int(v * 255) << 16 | Std.int(t * 255) << 8 | Std.int(p * 255);
			case 1: return Std.int(q * 255) << 16 | Std.int(v * 255) << 8 | Std.int(p * 255);
			case 2: return Std.int(p * 255) << 16 | Std.int(v * 255) << 8 | Std.int(t * 255);
			case 3: return Std.int(p * 255) << 16 | Std.int(q * 255) << 8 | Std.int(v * 255);
			case 4: return Std.int(t * 255) << 16 | Std.int(p * 255) << 8 | Std.int(v * 255);
			case 5: return Std.int(v * 255) << 16 | Std.int(p * 255) << 8 | Std.int(q * 255);
			default: return 0;
		}
		return 0;
	}

	/**
	 * Finds the red factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getRed(color:Int):Int
	{
		return color >> 16 & 0xFF;
	}

	/**
	 * Finds the green factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getGreen(color:Int):Int
	{
		return color >> 8 & 0xFF;
	}

	/**
	 * Finds the blue factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getBlue(color:Int):Int
	{
		return color & 0xFF;
	}

	/**
	 * Fetches a stored BitmapData object represented by the source.
	 * @param	source		Embedded Bitmap class.
	 * @return	The stored BitmapData object.
	 */
	public static function getBitmap(source:Dynamic):BitmapData
	{
		var name:String = Std.string(source);
		if (_bitmap.exists(name))
			return _bitmap.get(name);

#if nme
		var data:BitmapData = nme.Assets.getBitmapData(source);
#else
		var data:BitmapData = source.bitmapData;
#end
		if (data != null)
			_bitmap.set(name, data);

		return data;
	}

	/**
	 * Creates BitmapData based on platform specifics
	 */
	public static function createBitmap(width:Int, height:Int, ?transparent:Bool = false, ?color:Int = 0):BitmapData
	{
#if flash
	#if flash8
		var sizeError:Bool = (width > 2880 || height > 2880);
	#else
		var sizeError:Bool = (width * height > 16777215 || width > 8191 || height > 8191); // flash 10 requires size to be under 16,777,215
	#end
		if (sizeError)
		{
			trace("BitmapData is too large (" + width + ", " + height + ")");
			return null;
		}
#end // flash

		return new BitmapData(width, height, transparent, Utils.convertColor(color));
	}

	/**
	 * Converts a color to platform specific type (BitmapInt32)
	 */
	public static inline function convertColor(color:Int):Dynamic
	{
#if neko
		return { rgb: color, a: 1 };
#else
		return color; // do nothing
#end
	}

#if hardware
	public static function getBitmapIndex(source:Dynamic):Int
	{
		var name:String = Std.string(source);
		if (_bitmapIndex.exists(name))
			return _bitmapIndex.get(name);

		trace('Could not find the image : ' + Std.string(source));
		return -1;
	}

	/**
	 * Takes a bitmapdata and creates the tilesheet has an optional parameter which can take the string from the SpriteSheetPacker found here
	 * http://spritesheetpacker.codeplex.com/ which will generate the rectangles as well
	 * @param	source
	 * @param	?rectangleData	 A string where a rectangle is formatted as 'name = x y width height\n'
	 */
	public static function loadTilesheet(source:BitmapData, ?rectangleData:String):Void
	{
		HXP.tilesheet = new nme.display.Tilesheet(source);

		if (rectangleData != null)
		{

			var array:Array<String> = rectangleData.split('\n');

			for (ii in 0...array.length)
			{

				var data = array[ii].split(' ');
				var name = data[0];

				var rectangle = new Rectangle(Std.parseInt(data[2]), Std.parseInt(data[3]), Std.parseInt(data[4]), Std.parseInt(data[5]));

				HXP.sheetRectangles.push(rectangle);
				HXP.tilesheet.addTileRect(rectangle);

				HXP._bitmapIndex.set(name, ii);
			}
		}
	}
#end // hardware

	/**
	 * Sets a time flag.
	 * @return	Time elapsed (in milliseconds) since the last time flag was set.
	 */
	public static inline function timeFlag():Float
	{
		var t:Float = Timer.stamp(),
			e:Float = t - _time;
		_time = t;
		return e;
	}

	/**
	 * Gets an array of frame indices.
	 * @param	from	Starting frame.
	 * @param	to		Ending frame.
	 * @param	skip	Skip amount every frame (eg. use 1 for every 2nd frame).
	 */
	public static function frames(from:Int, to:Int, skip:Int = 0):Array<Int>
	{
		var a:Array<Int> = new Array<Int>();
		skip ++;
		if (from < to)
		{
			while (from <= to)
			{
				a.push(from);
				from += skip;
			}
		}
		else
		{
			while (from >= to)
			{
				a.push(from);
				from -= skip;
			}
		}
		return a;
	}

	/**
	 * Shuffles the elements in the array.
	 * @param	a		The Object to shuffle (an Array or Vector).
	 */
	public static function shuffle(a:Dynamic)
	{
		if (Std.is(a, Array))
		{
			var i:Int = a.length, j:Int, t:Dynamic;
			while (--i > 0)
			{
				t = a[i];
				a[i] = a[j = Utils.rand(i + 1)];
				a[j] = t;
			}
		}
	}

	public static var time(null, setTime):Float;
	private static inline function setTime(value:Float):Float {
		_time = value;
		return _time;
	}

	// Time information.
	private static var _time:Float;
	public static var _updateTime:Float;
	public static var _renderTime:Float;
	public static var _gameTime:Float;
	public static var _flashTime:Float;

	// Bitmap storage.
	private static var _bitmap:Hash<BitmapData> = new Hash<BitmapData>();

	// Pseudo-random number generation (the seed is set in Engine's contructor).
	private static var _seed:Int = 0;
	private static var _getSeed:Int;

	// Volume control.
	private static var _volume:Float = 1;
	private static var _pan:Float = 0;
	private static var _soundTransform:SoundTransform = new SoundTransform();




	// Used for rad-to-deg and deg-to-rad conversion.
	public static inline var DEG:Float = -180 / Math.PI;
	public static inline var RAD:Float = Math.PI / -180;

	// Global Flash objects.
	public static var stage:Stage;
	
	// Global objects used for rendering, collision, etc.
	public static var point:Point = new Point();
	public static var point2:Point = new Point();
	public static var zero:Point = new Point();
	public static var rect:Rectangle = new Rectangle();
	public static var matrix:Matrix = new Matrix();
	public static var sprite:Sprite = new Sprite();


	#if hardware
	/**
	 * Currently only one tilesheet for simplicity, should probably be a list later on (and not static?)
	 */
	public static var tilesheet:nme.display.Tilesheet;

	/**
	 * Stores the x, y, ID, flags... which are then passed through NME
	 */
	public static var tileData:Array<Float> = new Array<Float>();

	/**
	 * Stores the rectangles in an array where the index is the respective ID that the rectangle has in the tilesheet
	 */
	static public var sheetRectangles:Array<Rectangle> = new Array<Rectangle>();

	/**
	 * Flags are added with
	 * flags = TILE_SCALE | TILE_ROTATION | TILE_RGB;
	 */
	public static var tilesheetFlags:Int = 0;

	static private var _bitmapIndex:Hash<Int> = new Hash<Int>();

	/**
	 * @private Used internally, used to determine which index to set the data in tileData
	 */
	public static var currentPos:Int = 0;
	/**
	 * Used to determine if there are less objects to render, ïf there are then we need to splice the array so that we dont render any
	 * entities which have been removed
	 */
	public static var previousLength = 0;

	/**
	 * Flags that are copied over from the nme.display.Tilesheet class for easier access
	 */
	public static inline var TILE_SCALE = 0x0001;
	public static inline var TILE_ROTATION = 0x0002;
	public static inline var TILE_RGB = 0x0004;
	public static inline var TILE_ALPHA = 0x0008;
	#end
}