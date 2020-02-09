//! Represents a singular color entity parsed from the palette command line option.
//! 
//! * Author  - Patrick Jahnig (Aerodlyn)
//! * Version - 2019.02.09

use regex::Captures;
use regex::Regex;

use std::cmp::Ordering;
use std::panic;

use super::parse_error::ParseError;

#[derive (Debug)]
pub struct Color
{
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8
}

impl Eq for Color {}

impl Ord for Color
{
    /// Compares this `Color` instance with another, by comparing their brightness.
    /// 
    /// # Arguments
    /// * `other` - The other `Color` instance to compare to this one
    fn cmp (&self, other: &Self) -> Ordering
        { return self.calculate_brightness ().cmp (&other.calculate_brightness ()); }
}

impl PartialEq for Color
{
    /// Determines if this `Color` instance is equal to another, by comparing their brightness.
    /// 
    /// # Arguments
    /// * `other` - The other `Color` instance to compare to this one
    fn eq (&self, other: &Self) -> bool
        { return self.calculate_brightness () == other.calculate_brightness (); }
}

impl PartialOrd for Color
{
    /// Compares this `Color` instance with another, by comparing their brightness.
    /// 
    /// # Arguments
    /// * `other` - The other `Color` instance to compare to this one
    fn partial_cmp (&self, other: &Self) -> Option <Ordering>
        { return Some (self.cmp (other)); }
}

impl Color
{
    /// Inverts this `Color` instance by subtracting it's RGB values from 255.
    pub fn invert (&mut self)
    {
        self.r = 255 - self.r;
        self.g = 255 - self.g;
        self.b = 255 - self.b;
    }
    
    /// Calculates the "brightness" of this `Color` instance.
    /// Taken from: http://www.nbdtech.com/Blog/archive/2008/04/27/Calculating-the-Perceived-Brightness-of-a-Color.aspx
    pub fn calculate_brightness (&self) -> u8
    {
        let pow: f32 = 
              (((self.r as u16).pow (2) as f32) * 0.241)
            + (((self.g as u16).pow (2) as f32) * 0.691)
            + (((self.b as u16).pow (2) as f32) * 0.068);
            
        return (pow.sqrt ()) as u8;
    }
    
    /// Creates a new `Color` instance with the given RGBA values.
    /// 
    /// # Arguments
    /// * `r` - The red component of the color
    /// * `g` - The green component of the color
    /// * `b` - The blue component of the color
    /// * `a` - The alpha component of the color
    pub fn new (r: u8, g: u8, b: u8, a: u8) -> Color
        { return Color { r, g, b, a }; }
    
    /// Finds the `Color` in the given palette whose brightness is most similar to the one given.
    /// 
    /// # Arguments
    /// * `original` - The `Color` to find the most similar of
    /// * `palette`  - The collection of `Color` instances to search through for the most similar
    pub fn find_most_similar <'a> (original: &Color, palette: &'a Vec <Color>) -> Option <&'a Color>
    {
        let original_brightness: u8 = original.calculate_brightness ();
        
        let mut most_similar: Option <&Color> = None;
        for color in palette.iter ()
        {
            match most_similar
            {
                Some (prev) =>
                {
                    let color_brightness: u8 = color.calculate_brightness ();
                    
                    if color_brightness < original_brightness
                        { most_similar = Some (color); }
                    
                    else
                    {
                        most_similar =
                            if (color_brightness - original_brightness) < (original_brightness - prev.calculate_brightness ())
                                { Some (color) }
                            else
                                { Some (prev) };
                                
                        break;
                    }
                },
                None        => most_similar = Some (color)
            };
        }
        
        return most_similar;
    }
    
    /// Creates a new `Color` instance using the given hexadecimal string.
    /// 
    /// # Arguments
    /// * `value` - The hexadecimal string to determine the new `Color` instance's RGBA values
    pub fn from_hex (value: &str) -> Result <Color, ParseError>
    {
        let short_hex_reg: Regex = Regex::new (r"(?i)^0x([a-f0-9])([a-f0-9])([a-f0-9])([a-f0-9])?$").unwrap ();
        let long_hex_reg: Regex = Regex::new (r"(?i)^0x([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})?$").unwrap ();
        
        let captures: Option <Captures> = short_hex_reg.captures (value).or (long_hex_reg.captures (value));
        return match captures
        {
            Some (groups) =>
            {
                let r: &str = groups.get (1).unwrap ().as_str ();
                let g: &str = groups.get (2).unwrap ().as_str ();
                let b: &str = groups.get (3).unwrap ().as_str ();
                let a: &str = match groups.get (4)
                {
                    Some (a) => a.as_str (),
                    None     => if r.len () == 1 { "F" } else { "F" }
                };
                
                let color: Color = Color::new (
                    Color::hex_to_u8 (r)?,
                    Color::hex_to_u8 (g)?,
                    Color::hex_to_u8 (b)?,
                    Color::hex_to_u8 (a)?
                );
                Ok (color)
            },
            None => Err (ParseError { msg: format! ("Could not parse '{}' as a hexadecimal value", value) })
        };
    }

    /// Creates a new `Color` instance using the given RGBA string.
    /// 
    /// # Arguments
    /// * `value` - The RGBA string to determine the new `Color` instance's RGBA values
    pub fn from_rgba (value: &str) -> Result <Color, ParseError>
    {
        let reg: Regex = Regex::new (r"^(\d+),(\d+),(\d+)(?:,(\d+))?$").unwrap ();
        return match reg.captures (value)
        {
            Some (groups) =>
            {
                let r: &str = groups.get (1).unwrap ().as_str ();
                let g: &str = groups.get (2).unwrap ().as_str ();
                let b: &str = groups.get (3).unwrap ().as_str ();
                let a: &str = match groups.get (4)
                {
                    Some (a) => a.as_str (),
                    None     => "255"
                };

                return match panic::catch_unwind (||
                {
                    Color::new (
                        r.parse::<u8> ().unwrap (),
                        g.parse::<u8> ().unwrap (),
                        b.parse::<u8> ().unwrap (),
                        a.parse::<u8> ().unwrap ()
                    )
                })
                {
                    Ok (color) => Ok (color),
                    Err (_)    => Err (ParseError { msg: format! ("All numbers in '{}' must be between 0-255", value) })
                };
            },
            None          => Err (ParseError { msg: format! ("Could not parse '{}' as a RGBA value", value) })
        };
    }
    
    /// Takes a hexadecimal part (i.e. 'A' or 'AA') and converts it to a base 10 value.
    /// 
    /// # Arguments
    /// * `value` - The hexadecimal part to convert
    fn hex_to_u8 (value: &str) -> Result <u8, ParseError>
    {
        return match u8::from_str_radix (
            format! ("{}{}", value, if value.len () == 1 { value } else { "" }
        ).as_str (), 16)
        {
            Ok (v)  => Ok (v),
            Err (_) => Err (ParseError { msg: format! ("Could not parse '{}' to a decimal value", value) })
        };
    }
    
    /// Converts this `Color` instance into a hexadecimal string.
    pub fn to_hex (&self) -> String
    {
        return format! (
            "0x{}{}{}{}", 
            Color::u8_to_hex (self.r), 
            Color::u8_to_hex (self.g), 
            Color::u8_to_hex (self.b),
            Color::u8_to_hex (self.a)
        );
    }
    
    /// Converts the given value into a hexadecimal value.
    /// 
    /// # Arguments
    /// * `value` - The value to convert (0-255)
    fn u8_to_hex (value: u8) -> String
    {
        let hex_values: [&str; 16] = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ];
        let mut result: String = String::new ();
        
        let mut counter: u8 = value;
        while counter > 0
        {
            result = format! ("{}{}", hex_values [(counter % 16) as usize], result);
            counter /= 16;
        }
        
        return result;
    }
}

#[cfg (test)]
mod tests
{
    use super::Color;

    #[test]
    fn test_invert ()
    {
        let mut color: Color = Color::new (50, 100, 150, 200);
        color.invert ();

        assert_eq! (205, color.r);
        assert_eq! (155, color.g);
        assert_eq! (105, color.b);
        assert_eq! (200, color.a);
    }

    #[test]
    fn test_calculate_brightness ()
    {
        let color: Color = Color::new (50, 100, 150, 200);
        assert_eq! (95, color.calculate_brightness ());
    }

    #[test]
    fn test_new ()
    {
        let color: Color = Color::new (50, 100, 150, 200);
        
        assert_eq! (50, color.r);
        assert_eq! (100, color.g);
        assert_eq! (150, color.b);
        assert_eq! (200, color.a);
    }

    #[test]
    fn test_find_most_similar ()
    {
        let palette: Vec <Color> = vec! (
            Color::new (50, 100, 150, 200),
            Color::new (55, 105, 155, 205)
        );

        // Should pick the same color
        let test_color_1: Color = Color::new (50, 100, 150, 200);
        let test_result_1: Option <&Color> = Color::find_most_similar (&test_color_1, &palette);
        assert! (test_result_1.is_some ());
        assert_eq! (&test_color_1, test_result_1.unwrap ());
    }
}
