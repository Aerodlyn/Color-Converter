package src;

import src.CommandLineOptionMap;

final class Main
{
    private var options: CommandLineOptionMap;

    private function new (args: Array <String>)
    {
        options = new CommandLineOptionMap ();
        
        var index: Int = 0;
        while (index < args.length)
        {
            var key: String = args [index];
            
            // Attempt to split k=v/k v
            var reg: EReg = ~/^(--?[a-z]+)=(.*?)$/ig;
            var value: Null <String> =
                try
                {
                    if (reg.match (key))
                    {
                        key = reg.matched (1);
                        reg.matched (2);
                    }
                    
                    else
                    {
                        reg = ~/^--?.*$/ig;
                        reg.match (args [index + 1]) ? null : args [++index];
                    }
                }
                
                catch (ex: Any)
                    { null; }
            try
                { options.setCommandLineOption (key, value); }

            catch (ex: String)
            {
                // TODO: Attempt to parse into a palette
                Sys.println (ex);
                Sys.exit (1);
            }
            
            index++;
        }
    }
    
    public static function main (): Void
        { new Main (Sys.args ()); }
}
