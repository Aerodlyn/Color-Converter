package src;

import src.CommandLineOption;

typedef CommandLineOptionResult = {
    var type   : String;
    var option : CommandLineOption <Any>;
}

/**
 * Represents the collection of all command line options.
 *
 * @author  Patrick Jahnig (Aerodlyn)
 * @version 2020.02.01
 */
final class CommandLineOptionMap
{
    private var options: Map <String, CommandLineOption <Any>>;

    /**
     * Creates a new {@link CommandLineOptionMap} instance with the following options:
     *  -i/--invert (boolean)
     *  -p/--palette (string)
     */
    public function new ()
    {
        options = new Map <String, CommandLineOption <Any>> ();

        var invert: BooleanCommandLineOption = new BooleanCommandLineOption ();
        options.set ("--invert", cast invert);
        options.set ("-i", cast invert);

        var palette: StringCommandLineOption = new StringCommandLineOption ();
        options.set ("--palette", cast palette);
        options.set ("-p", cast palette);
    }

    /**
     * Sets the command line option with the given key with the given value. If the given value
     *  is null, then the options default value is used.
     *
     * @param key   - The option to set the value of
     * @param value - The value to the set the option to, can be null
     *
     * @throws String if either the given key doesn't match a valid option, the type of the
     *  option couldn't be determined, or an invalid value for the option was given
     */
    public function setCommandLineOption (key: String, ?value: String): Void
    {
        var result: CommandLineOptionResult = getCommandLineOption (key);
        switch (result.type)
        {
            case "src.BooleanCommandLineOption":
                var parsed: Bool =
                {
                    if (value == null)
                        true;

                    else
                    {
                        switch (value = value.toLowerCase ())
                        {
                            case "true":
                                true;
                            case "false":
                                false;
                            default:
                                throw 'Invalid value \'$value\' for boolean option';
                        };
                    }
                };

                cast (result.option, BooleanCommandLineOption).set (parsed);

            case "src.StringCommandLineOption":
                cast (result.option, StringCommandLineOption).set (value == null ? "" : value);

            default:
                throw "oops";
        }
    }

    /**
     * Returns the option and it's type that is stored under the given key.
     *
     * @param key - The name of the option to retrieve
     *
     * @returns The option itself and it's type
     * @throws String if the key does not match any valid option
     */
    public function getCommandLineOption (key: String): CommandLineOptionResult
    {
        var option: CommandLineOption <Any> = options.get (key);
        if (option == null)
            throw 'Unknown input option \'$key\'';

        return {
            type: Type.getClassName (Type.getClass (option)),
            option: option
        };
    }
}
