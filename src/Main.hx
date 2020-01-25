package src;

import haxe.ds.Option;

final class Main
{
    private function new (args: Array <String>)
    {
        var arguments: Map <String, Any> = [
            "invert"  => false,
            "palette" => []
        ];
        
        var options: Map <String, String> = [
            "--invert" => "invert",
            "-i"       => "invert"
        ];
        
        var index: Int = 0;
        while (index < args.length)
        {
            var key: String = args [index];
            
            // Attempt to split k=v
            var reg: EReg = ~/^(--?[a-z]+)=(.*?)$/ig;
            var value: Option <String> =
                try
                {
                    if (reg.match (key))
                    {
                        key = reg.matched (1);
                        Some (reg.matched (2));
                    }
                    
                    else
                    {
                        reg = ~/^--?.*$/ig;
                        reg.match (args [index + 1]) ? None : Some (args [++index]);
                    }
                }
                
                catch (ex: Any)
                    { None; }
            
            arguments [options [key]] =
                switch (value)
                {
                    case Some (v):
                        v;
                    
                    case None:
                        '';
                }
            
            index++;
        }
        
        trace (arguments);
    }
    
    public static function main (): Void
        { new Main (Sys.args ()); }
}
