package src;

/**
 * Represents a specific option typed into the command line interface for Color Converter, typed
 *  along the lines of -k, --key, -k=value, --key=value, -k value, or --key value.
 *
 * @param T - the underlying type of the command line option
 *
 * @author  Patrick Jahnig (Aerodlyn)
 * @version 2020.02.01
 */
class CommandLineOption <T>
{
    public var value (default, null): T;
    
    /**
     * Creates a new instance of {@link CommandLineOption}.
     *
     * @param defaultValue - The default value to give this option in the case that no value
     *  was typed
     */
    private function new (defaultValue: T)
        { value = defaultValue; }

    /**
     * Sets the value of this option to the given value.
     *
     * @param value - The value to set this option to
     */
    public final function set (value: T): Void
        { this.value = value; }
}

/**
 * The boolean variant of a command line option.
 *
 * @author  Patrick Jahnig (Aerodlyn)
 * @version 2020.02.01
 */
final class BooleanCommandLineOption extends CommandLineOption <Bool>
{
    public function new ()
        { super (false); }
}

/**
 * The string variant of a command line option.
 *
 * @author  Patrick Jahnig (Aerodlyn)
 * @version 2020.02.01
 */
final class StringCommandLineOption extends CommandLineOption <String>
{
    public function new ()
        { super (""); }
}
