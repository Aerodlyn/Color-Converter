package src;

/**
 * Represents the color of a pixel.
 *
 * @author  Patrick Jahnig (Aerodlyn)
 * @version 2020.01.24
 */
final class Color
{
    public var a (default, null): Int;
    public var b (default, null): Int;
    public var g (default, null): Int;
    public var r (default, null): Int;
    
    /**
     * Creates a new Color instance with the given RGBA values.
     * 
     * @param r - The red component (0-255 inclusive)
     * @param g - The green component (0-255 inclusive)
     * @param b - The blue component (0-255 inclusive)
     * @param a - The alpha component (0-255 inclusive)
     */
    public inline function new (r: Int, g: Int, b: Int, a: Int)
    {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }
    
    /**
     * Calculates the brightness of this Color based on the formula found at the given link.
     * Taken from: http://www.nbdtech.com/Blog/archive/2008/04/27/Calculating-the-Perceived-Brightness-of-a-Color.aspx
     *
     * @return The calculated brightness of this Color instance
     */
    public function calculateBrightness (): Int
    {
        return Std.int (
            Math.sqrt (
                  Math.pow (r, 2) * 0.241
                + Math.pow (g, 2) * 0.691
                + Math.pow (b, 2) * 0.068
            )
        );
    }
    
    /**
     * Compares two given Color instances and returns a value indicating which has the greater
     *  brightness.
     *
     * @param a - The first Color instance
     * @param b - The second Color instance
     *
     * @return 1 if x's brightness is greater than y's, -1 if the opposite, or 0 if the two are
     *  equal
     */
    public static function compare (a: Color, b: Color): Int
    {
        var aBrightness: Int = a.calculateBrightness ();
        var bBrightness: Int = b.calculateBrightness ();
        
        return aBrightness > bBrightness ? 1 : aBrightness < bBrightness ? -1 : 0;
    }
    
    /**
     * Creates a new Color instance using RGB values denoted by the given hexadecimal number.
     *  NOTE: Valid values are prepended with '0x' and are either three or six characters
     *  long (after the '0x'). This means that values such as 0x1A3 are equivalent to 0x11AA33.
     * 
     * @param hex - The hexadecimal string to convert into a Color object
     * 
     * @return A new Color instance with RGB values equal to those provided in the given
     *  hexadecimal string
     */
    public static function fromHex (hex: String): Color
    {
        var shortHexReg: EReg = ~/^0x([a-f0-9])([a-f0-9])([a-f0-9])$/i;
        var longHexReg: EReg = ~/^0x([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})$/i;
        
        var usedReg: EReg;
        if (shortHexReg.match (hex))
            usedReg = shortHexReg;
        
        else if (longHexReg.match (hex))
            usedReg = longHexReg;
        
        else
            throw 'The given value \'$hex\' is not a valid color hex code';
        
        var r: String = usedReg.matched (1);
        var g: String = usedReg.matched (2);
        var b: String = usedReg.matched (3);
        
        return new Color (
            Std.parseInt ('0x${ r }${ usedReg == shortHexReg ? r : '' }'),
            Std.parseInt ('0x${ g }${ usedReg == shortHexReg ? g : '' }'),
            Std.parseInt ('0x${ b }${ usedReg == shortHexReg ? b : '' }'),
            255
        );
    }
    
    /**
     * Creates a new Color instance that is the inversion of this Color instance by subtracting
     *  its RGB values from 255.
     * 
     * @return The inversion of this Color instance
     */
    public function invert (): Color
        { return new Color (255 - r, 255 - g, 255 - b, a); }
}
