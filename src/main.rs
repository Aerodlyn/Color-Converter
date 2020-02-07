mod util;
use util::cli::Cli;
use util::converter;

fn main ()
{
    let cli: Cli = Cli::new ();
    converter::convert (&cli.image, &cli.palette).unwrap ();
}
