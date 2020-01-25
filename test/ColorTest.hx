package test;

import src.Color;

import utest.Assert;
import utest.Test;

final class ColorTest extends Test
{
    public function testFromHex ()
    {
        var color: Color = Color.fromHex ("0xFAE");
        Assert.equals (255, color.r);
        Assert.equals (170, color.g);
        Assert.equals (238, color.b);
        Assert.equals (255, color.a);
        
        color = Color.fromHex ("0x1ABE15");
        Assert.equals (26, color.r);
        Assert.equals (190, color.g);
        Assert.equals (21, color.b);
        Assert.equals (255, color.a);
        
        color = Color.fromHex ("0x1abe15");
        Assert.equals (26, color.r);
        Assert.equals (190, color.g);
        Assert.equals (21, color.b);
        Assert.equals (255, color.a);
        
        color = Color.fromHex ("0x20bEeF");
        Assert.equals (32, color.r);
        Assert.equals (190, color.g);
        Assert.equals (239, color.b);
        Assert.equals (255, color.a);
        
        Assert.raises (() -> Color.fromHex ("0xF"), String);
        Assert.raises (() -> Color.fromHex ("0xFF"), String);
        Assert.raises (() -> Color.fromHex ("0xFFFF"), String);
        Assert.raises (() -> Color.fromHex ("0xFFFFF"), String);
        Assert.raises (() -> Color.fromHex ("0xFFFGAE"), String);
        Assert.raises (() -> Color.fromHex ("FFF"), String);
    }
}
