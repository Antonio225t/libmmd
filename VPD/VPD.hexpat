#pragma author Antonio225
#pragma description VPD Vocaloid Pose Data (.vpd)
#pragma pattern_limit 0xFFFFFFFF
#pragma array_limit 0xFFFFFFFF
#pragma endian little

#include <std/io.pat>
#include <std/string.pat>



fn read_spaces(u8 numbers) {
    u8 skip = 0;
    u32 size = 0;
    while (skip < numbers) {
        char lb @ $;
        $ += 1;
        if (lb != 0x20) {
            skip += 1;
        }
        size += 1;
    }
    return size;
};

fn read_until_u8(u8 ch, u8 numbers) {
    u8 skip = 0;
    u32 size = 0;
    while (skip < numbers) {
        char lb @ $;
        $ += 1;
        if (lb == ch) {
            skip += 1;
        }
        size += 1;
    }
    return size-1;
};

fn read_until_u16(u16 ch, u8 numbers) {
    u8 skip = 0;
    u32 size = 0;
    while (skip < numbers) {
        char lb @ $;
        $ += 1;
        if (lb == ch) {
            skip += 1;
        }
        size += 1;
    }
    return size+1;
};



struct Vec3 {
    char X[read_until_u8(0x2C, 1)];
    padding[1];
    char Y[read_until_u8(0x2C, 1)];
    padding[1];
    char Z[read_until_u8(0x3B, 1)];
    padding[read_until_u16(0x0A0D, 1)];
};

struct Vec4 {
    char X[read_until_u8(0x2C, 1)];
    padding[1];
    char Y[read_until_u8(0x2C, 1)];
    padding[1];
    char Z[read_until_u8(0x2C, 1)];
    padding[1];
    char W[read_until_u8(0x3B, 1)];
    padding[read_until_u16(0x0A0D, 1)];
};

struct Bone {
    char ElementName[4];
    char IndexNumber[read_until_u8(0x7B, 1)];
    padding[1];
    char BoneName[read_until_u16(0x0A0D, 1)-2];
    padding[2];
    padding[read_spaces(1)-1];
    Vec3 Position;
    padding[read_spaces(1)-1];
    Vec4 Rotation;
    padding[read_until_u16(0x0A0D, 2)];
};

struct Morph {
    char ElementName[5];
    char IndexNumber[read_until_u8(0x7B, 1)];
    padding[1];
    char BoneName[read_until_u16(0x0A0D, 1)-2];
    padding[2];
    padding[read_spaces(1)-1];
    char Weight[read_until_u8(0x3B, 1)];
    padding[read_until_u16(0x0A0D, 2)+2];
};

struct Element {
    if ($[$] == 0x42) {
        Bone Bone;
    } else {
        Morph Morph; // MikuMikuMoving
    }
};

struct VPD {
    char Magic[23]; // Vocaloid Pose Data file
    padding[read_until_u16(0x0A0D, 2)];
    char ModelName[read_until_u8(0x3B, 1)];
    padding[read_until_u16(0x0A0D, 1)];
    char BonesNumber[read_until_u8(0x3B, 1)];
    padding[read_until_u16(0x0A0D, 2)];
    Element Elements[while($ != sizeof($) && $ + 0x2C < sizeof($))];
};


// This is a text file written in Shift-JIS encoding
VPD VPD @ 0x00;