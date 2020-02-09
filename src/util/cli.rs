//! Utility for command line options.
//! See: https://docs.rs/structopt/0.3.9/structopt/
//! 
//! * Author  - Patrick Jahnig (Aerodlyn)
//! * Version - 2019.02.09

use regex::Regex;

use std::path::PathBuf;

use structopt::StructOpt;

use super::color::Color;
use super::parse_error::ParseError;

#[derive (Debug, StructOpt)]
pub struct Cli
{
    /// Set to invert the color inputs
    #[structopt (short, long)]
    pub invert: bool,
    
    /// The file path of the image to convert the colors of
    #[structopt (parse (from_os_str))]
    pub image: PathBuf,
    
    /// The color inputs to use, written as: 0xABCDEF 0x111 0xaebbaebb ... or 255,70,120,255
    ///     189,222,89 20,20,20,255 ...
    #[structopt (parse (try_from_str = Cli::parse_color))]
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

    /// Attempts to parse the given value as a `Color`. Valid values are written either as
    ///     0x???, 0x????, 0x??????, 0x????????, ?,?,?, or ?,?,?,?.
    /// 
    /// # Arguments
    /// * `value` - The value to parse into a `Color`
    fn parse_color (value: &str) -> Result <Color, ParseError>
    {
        let rgba_reg: Regex = Regex::new (r"^\d\d?\d?,\d\d?\d?,\d\d?\d?(?:,\d\d?\d?)?$").unwrap ();
        let hex_reg: Regex = Regex::new (r"^0x\w\w?\w\w?\w\w?$").unwrap ();

        return if rgba_reg.is_match (value)
            { Color::from_rgba (value) }
        else if hex_reg.is_match (value)
            { Color::from_hex (value) }
        else
            { Err (ParseError { msg: format! ("The given value '{}' does not match a valid format", value) }) };
    }
}
