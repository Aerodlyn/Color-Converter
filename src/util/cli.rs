//! Utility for command line options.
//! See: https://docs.rs/structopt/0.3.9/structopt/
//! 
//! * Author  - Patrick Jahnig (Aerodlyn)
//! * Version - 2019.02.06

use std::path::PathBuf;

use structopt::StructOpt;

use super::color::Color;

#[derive (Debug, StructOpt)]
pub struct Cli
{
    /// Set to invert the color inputs
    #[structopt (short, long)]
    pub invert: bool,
    
    /// The file path of the image to convert the colors of
    #[structopt (parse (from_os_str))]
    pub image: PathBuf,
    
    /// The color inputs to use, written as: 0xABCDEF 0x111 0xaebbae ... 
    #[structopt (parse (try_from_str = Color::from_hex))]
    pub palette: Vec <Color>
}

impl Cli
{
    /// Creates a new `Cli` instance, and adjusts the given palette by inverting if the invert flag
    ///     was set, and then sorting it.
    pub fn new () -> Cli
    {
        let mut cli = Cli::from_args ();
        cli.adjust_palette ();
        
        return cli;
    }
    
    /// Adjusts the palette by inverting each color if this `Cli` instance has the invert flag set
    ///     and by sorting it.
    fn adjust_palette (&mut self)
    {
        if self.invert
        {
            for color in self.palette.iter_mut ()
                { color.invert (); }
        }
        
        self.palette.sort ();
    }
}
