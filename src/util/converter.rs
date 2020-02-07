//! Utility for converting a singular image using a given set of colors.
//! 
//! * Author  - Patrick Jahnig (Aerodlyn)
//! * Version - 2019.02.06

use image::{ DynamicImage, GenericImageView, ImageBuffer, ImageError, Rgba, RgbaImage };

use std::path::PathBuf;

use super::color::Color;

/// Converts the colors of the image located at the given `PathBuf` using the given `palette`
///     of colors.
/// 
/// # Arguments
/// * `file_path` - The location of the image to convert
/// * `palette`   - The set of `Color` instances to use to convert the image by
pub fn convert (file_path: &PathBuf, palette: &Vec <Color>) -> Result <(), ImageError>
{
    let (source, mut target): (DynamicImage, RgbaImage) = prepare (file_path)?;
    
    for (x, y, pixel) in target.enumerate_pixels_mut ()
    {
        let source_pixel: Rgba <u8> = source.get_pixel (x, y);
        let source_color: Color = Color::new (
            source_pixel [0],
            source_pixel [1],
            source_pixel [2],
            source_pixel [3]
        );
        
        let most_similar: Option <&Color> = Color::find_most_similar (&source_color, palette);
        if let Some (converted_color) = most_similar
        {
            *pixel = Rgba ([
                converted_color.r,
                converted_color.g,
                converted_color.b,
                converted_color.a
            ]);
        }
        
        else
            { *pixel = source_pixel; }
    }
    
    let source_extension: &str = match file_path.extension ()
    {
        Some (value) => value.to_str ().unwrap (),
        None         => ""
    };
    
    let mut target_path: PathBuf = PathBuf::from (file_path);
    target_path.set_extension (format! ("new.{}", source_extension));
    
    target.save (target_path)?;
    
    return Ok (());
}

/// Prepares the image located at the given `PathBuf` for conversion.
/// 
/// # Arguments
/// * `file_path` - The location of the image to prepare for conversion
fn prepare (file_path: &PathBuf) -> Result <(DynamicImage, RgbaImage), ImageError>
{
    let img: DynamicImage = image::open (file_path)?;

    let (w, h): (u32, u32) = img.dimensions ();
    let buf: RgbaImage = ImageBuffer::new (w, h);
    
    return Ok ((img, buf));
}
