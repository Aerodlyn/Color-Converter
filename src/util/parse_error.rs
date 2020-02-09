//! Represents an error parsing a given string on the command line.
//! 
//! * Author  - Patrick Jahnig (Aerodlyn)
//! * Version - 2019.02.09

use std::fmt;

#[derive (Clone, Debug)]
pub struct ParseError
{
    pub msg: String
}

impl fmt::Display for ParseError
{
    fn fmt (&self, f: &mut fmt::Formatter <'_>) -> fmt::Result
        { return write! (f, "{}", self.msg); }
}
