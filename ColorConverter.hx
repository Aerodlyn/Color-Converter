import format.png.Reader;
import format.png.Tools;
import format.png.Writer;
import sys.io.File;
import sys.FileSystem;

/**
 * Represents the color of a pixel.
 *
 * @author  Patrick Jahnig (Aerodlyn)
 * @version 2020.01.17
 */
private class Color
{
    public var  r:          Int; 
    public var  g:          Int; 
    public var  b:          Int; 
    public var  a:          Int;

    private var brightness: Int;

    private function new (r: Int, g: Int, b: Int, a: Int)
    {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;

        calculateBrightness ();
    }

    public function getBrightness (): Int
        { return brightness; }

    /**
     * Compares two given Color instances and returns a value indicating which has the greater brightness.
     *
     * @param x - The first Color instance
     * @param y - The second Color instance
     *
     * @return 1 if x's brightness is greater than y's, -1 if the opposite, or 0 if the two are equal
     */
    public static function compare (x: Color, y: Color): Int 
    { 
        var xBrightness = x.getBrightness (),
            yBrightness = y.getBrightness ();

        return xBrightness > yBrightness ? 1 : xBrightness < yBrightness ? -1 : 0;
    }

    /**
     * Calculates the brightness of this Color based on the formula found at the given link.
     * Taken from: http://www.nbdtech.com/Blog/archive/2008/04/27/Calculating-the-Perceived-Brightness-of-a-Color.aspx
     */
    private function calculateBrightness () : Void
    {
        brightness = Std.int (Math.sqrt (Math.pow (this.r, 2) * 0.241 
            + Math.pow (this.g, 2) * 0.691 
            + Math.pow (this.b, 2) * 0.068));
    }

    public static function fromInt (r: Int, g: Int, b: Int, a: Int): Color
        { return new Color (r, g, b, a); }

    public static function fromString (r: String, g: String, b: String, a: String): Color
        { return new Color (Std.parseInt (r), Std.parseInt (g), Std.parseInt (b), Std.parseInt (a)); }

    /**
     * Returns the String representation of this Color instance.
     *
     * @return The String representation of this Color
     */
    public function toString (): String
        { return Std.string (getBrightness ()); }
}

/**
 * Takes a series of image file locations and a color palette, and converts each pixel in each image to match one of the colors 
 *  given in the palettes based on the level of darkness of the pixel.
 *
 * @author  Patrick Jahnig (Aerodlyn)
 * @version 2020.01.17
 */
class ColorConverter
{
    private static var PIXEL_PARTS: Int = 4;

    public static function main () : Void
    {
        var inverse: Bool = Sys.args ().indexOf ("-i") != -1;

        // Print help if no arguments were given or -h is a given argument
        if (Sys.args ().length == 0 || Sys.args ().indexOf ("-h") != -1)
            printHelp ();

        // Check that at least one (maybe not valid) color is given in the palette
        var index = 0;
        while (Std.parseInt (Sys.args () [index]) == null && index < Sys.args ().length)
            index++;

        if (index == Sys.args ().length)
            writeError ("Error: At least one color must be given in palette_list");

        var palettes = new Array <Color> ();
        for (p in Sys.args () [index].split (","))
        {
            var ps = p.split (" ");
            var start = ps [0] == "" ? 1 : 0;

            // Check if the valid number of values have been given
            // NOTE: Technically five values are given (if the first characters are spaces) so check if that is the case
            if (ps.length == 4 || (start == 1 && ps.length == 5))
                palettes.push (Color.fromString (ps [start], ps [start + 1], ps [start + 2], ps [start + 3]));
            
            else
                writeError ("Error: Invalid number of values given in palette color: " + ps);
        }

        palettes.sort (Color.compare);
        if (inverse)
            palettes.reverse ();

        for (i in index + 1...Sys.args ().length)
            convertImage (Sys.args () [i], palettes, inverse);
    }

    /**
     * Converts the pixels contained in the image located at the given path.
     *
     * @param path      - The location of the image to convert
     * @param palettes  - The Array of Color instances to use to convert pixel colors to
     * @param inverse   - Whether to swap bright colors with dark
     */
    static private function convertImage (path: String, palettes: Array <Color>, inverse: Bool) : Void
    {
        if (FileSystem.exists (path))
        {
            var handle = File.read (path, true);
            var img = new Reader (handle).read ();

            var header = Tools.getHeader (img);
            var bytes = Tools.extract32 (img);

            var output = File.write (path.substring (0, path.lastIndexOf (".")) + ".new.png", true);
            var writer = new Writer (output);

            for (i in 0...Std.int (bytes.length / 4))
            {
                var b = bytes.get (i * PIXEL_PARTS),
                    g = bytes.get (i * PIXEL_PARTS + 1),
                    r = bytes.get (i * PIXEL_PARTS + 2),
                    a = bytes.get (i * PIXEL_PARTS + 3);
                
                // Skip this pixel if it is transparent
                if (a == 0)
                    continue;

                var color = getEquivalentColorFromPalette (Color.fromInt (r, g, b, a), palettes, inverse);

                bytes.set (i * PIXEL_PARTS, color.b);
                bytes.set (i * PIXEL_PARTS + 1, color.g);
                bytes.set (i * PIXEL_PARTS + 2, color.r);
                bytes.set (i * PIXEL_PARTS + 3, color.a);
            }

            writer.write (Tools.build32BGRA (header.width, header.height, bytes));
            
            handle.close ();
            output.close ();
        }

        else
            Sys.println ("A file was not found at: " + path);
    }

    /**
     * Prints the help dialog and exits.
     */
    private static function printHelp () : Void 
    {
        Sys.println ("Usage: [-h] palette_list file_list...\n");
        Sys.println ("The options are as follows:\n");
        Sys.println ("-h            Prints this dialog\n");
        Sys.println ("The required arguments are as follows:\n");
        Sys.println ("palette_list  A comma separated list of values formatted like so: \"red green blue alpha, ...\"");
        Sys.println ("              Each part represents a component of a color. Colors should be sorted darkest to lightest.");

        Sys.exit (0);
    }

    /**
     * Writes the given String to standard error and exits with return code 1.
     *
     * @param msg - The message to write to standard error
     */
    private static function writeError (msg: String) : Void
    {
        Sys.println (msg);
        Sys.exit (1);
    }

    /**
     * Finds the equivalent Color from the given palette colors for the given Color. This equivalent value is defined as the 
     *  smallest difference in brightness for the given Color and any palette color.
     *
     * @param value     - The Color to find an equivalent value for
     * @param palettes  - The Array of Color values that represents the palette of colors to use
     * @param inverse   - Whether to swap bright colors with dark
     *
     * @return The Color from the palette that was found to be equivalent to the given Color
     */
    static private function getEquivalentColorFromPalette (value: Color, palettes: Array <Color>, inverse: Bool) : Color
    {
        var valueBrightness = value.getBrightness ();
        if (inverse)
            valueBrightness = 255 - valueBrightness;

        var lower: Color = palettes [0];
        var higher: Color = lower;

        for (index in (1...palettes.length))
        {
            higher = palettes [index];
            if (higher.getBrightness () < valueBrightness)
                lower = higher;
        }

        var lowerDiff = valueBrightness - lower.getBrightness (),
            higherDiff = higher.getBrightness () - valueBrightness;

        return lowerDiff < higherDiff ? lower : higher;
    }
}
