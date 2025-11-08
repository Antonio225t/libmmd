#pragma author Antonio225
#pragma description VMD Vocaloid Motion Data (.vmd)

#include <std/io.pat>
#include <std/string.pat>




fn IsVersionNew() {
    std::string::NullString ActualMagic @ 0x00;
    
    if (ActualMagic == "Vocaloid Motion Data 0002") {
        return true;
    }
    return false;
};


// Keyframe base

struct Keyframe {
    u8 BoneName_SJIS[15];
    u32 Frame;
};

struct Position {
    float Position_X;
    float Position_Y;
    float Position_Z;
};

struct InterpolationSection {
    s8 InterStart_X;
    s8 InterEnd_X;
    
    s8 InterStart_Y;
    s8 InterEnd_Y;
};


// Bones


struct Rotation {
    float Rotation_X;
    float Rotation_Y; // Math.sin
    float Rotation_Z;
    float Rotation_W;
};

// This is the most confusing part... Took a while to fill everything.
// If you put something in the Unknowns it'll just be replaced with 00
// when saving.
struct InterpolationCurve {
    s8 InterCurve_X_Start_X;
    s8 InterCurve_Y_Start_X_Clone1;
    s8 Unk3; // Seems unused
    s8 Unk4; // Seems unused
    s8 InterCurve_X_Start_Y;
    s8 InterCurve_Y_Start_Y_Clone1;
    s8 InterCurve_Z_Start_Y_Clone1;
    s8 InterCurve_Rotation_Start_X_Clone1;
    s8 InterCurve_X_End_X;
    s8 InterCurve_Y_End_X_Clone1;
    s8 InterCurve_Z_End_X_Clone1;
    s8 InterCurve_Rotation_End_X_Clone1;
    s8 InterCurve_X_End_Y;
    s8 InterCurve_Y_End_Y_Clone1;
    s8 InterCurve_Z_End_Y_Clone1;
    s8 InterCurve_Rotation_End_Y_Clone1;
    s8 InterCurve_Y_Start_X;
    s8 InterCurve_Z_Start_X_Clone1;
    s8 InterCurve_Rotation_Start_Y_Clone1;
    s8 InterCurve_X_Start_Y_Clone1;
    s8 InterCurve_Y_Start_Y;
    s8 InterCurve_Z_Start_Y_Clone2;
    s8 InterCurve_Rotation_Start_X_Clone2;
    s8 InterCurve_X_End_X_Clone1;
    s8 InterCurve_Y_End_X;
    s8 InterCurve_Z_End_X_Clone2;
    s8 InterCurve_Rotation_End_X_Clone2;
    s8 InterCurve_X_End_Y_Clone1;
    s8 InterCurve_Y_End_Y;
    s8 InterCurve_Z_End_Y_Clone2;
    s8 InterCurve_Rotation_End_Y_Clone2;
    s8 Unk31; // Seems unused
    s8 InterCurve_Z_Start_X;
    s8 InterCurve_Rotation_Start_Y_Clone2;
    s8 InterCurve_X_Start_Y_Clone2;
    s8 InterCurve_Y_Start_Y_Clone2;
    s8 InterCurve_Z_Start_Y;
    s8 InterCurve_Rotation_Start_X_Clone3;
    s8 InterCurve_X_End_X_Clone2;
    s8 InterCurve_Y_End_X_Clone2;
    s8 InterCurve_Z_End_X;
    s8 InterCurve_Rotation_End_X_Clone3;
    s8 InterCurve_X_End_Y_Clone2;
    s8 InterCurve_Y_End_Y_Clone2;
    s8 InterCurve_Z_End_Y;
    s8 InterCurve_Rotation_End_Y_Clone3;
    s8 Unk46; // Seems unused
    s8 Unk47; // Seems unused
    s8 InterCurve_Rotation_Start_Y;
    s8 InterCurve_X_Start_Y_Clone3;
    s8 InterCurve_Y_Start_Y_Clone3;
    s8 InterCurve_Z_Start_Y_Clone3;
    s8 InterCurve_Rotation_Start_X;
    s8 InterCurve_X_End_X_Clone3;
    s8 InterCurve_Y_End_X_Clone3;
    s8 InterCurve_Z_End_X_Clone3;
    s8 InterCurve_Rotation_End_X;
    s8 InterCurve_X_End_Y_Clone3;
    s8 InterCurve_Y_End_Y_Clone3;
    s8 InterCurve_Z_End_Y_Clone3;
    s8 InterCurve_Rotation_End_Y;
    s8 Unk61; // Seems unused
    s8 Unk62; // Seems unused
    s8 Unk63; // Seems unused
};

struct BoneKeyframe : Keyframe {
    Position Translation;
    Rotation Rotation;
    InterpolationCurve InterpolationCurve;
};



// Morph

struct MorphKeyframe {
    u8 MorphName_SJIS[15];
    u32 Frame;
    float Weight;
};



// Camera

// These are radiants, here's how you convert them:
//
// degtorad = Math.PI / 180
// radtodeg = 180 / Math.PI
// rad = the float value in this Rotation struct
//
// Val to rotation float: Math.sin(33.2 * degtorad)
// Rotation float to val: Math.asin(rad) * radtodeg
struct CameraRotation {
    float Rotation_X; // Normal but negative is inversed
    float Rotation_Y; // Math.asin
    float Rotation_Z; // Normal
};

struct CameraCurve {
    InterpolationSection InterSection_X;
    InterpolationSection InterSection_Y;
    InterpolationSection InterSection_Z;
    
    InterpolationSection InterSection_Rotation;
    InterpolationSection InterSection_Distance;
    InterpolationSection InterSection_ViewAngle; // FOV
};

struct CameraKeyframe {
    u32 Frame;
    float Distance; // Distance is seen in negative here but on MMD is positive.
    Position Position;
    CameraRotation Rotation;
    CameraCurve Curve;
    u32 ViewAngle; // FOV
    bool DisabledPrespective;
};




// Light

// Colors are float * 256
struct Color {
    float Color_R;
    float Color_G;
    float Color_B;
};

struct LightKeyframe {
    u32 Frame;
    Color Color;
    Position Direction;
};




// Shadow

enum ShadowMode : u8 {
    OFF   = 0x00,
    MODE1 = 0x01,
    MODE2 = 0x02
};


struct ShadowKeyframe {
    u32 Frame;
    ShadowMode Mode;
    float ShadowRange; // 0.1 = 0, 0.0001 = 9999
};




// Disp/IK


struct IKBone {
    u8 BoneName[20];
    bool Active;
};

struct DispIKKeyframe {
    u32 Frame;
    bool Disp;
    
    u32 IKBonesCount;
    IKBone IKBonesList[IKBonesCount];
};



struct VMD {
    char Magic[30];
    u8 ModelName_SJIS[IsVersionNew() ? 20 : 10];
    
    // Bones
    u32 BoneKeyframeCount;
    BoneKeyframe BoneList[BoneKeyframeCount];
    
    // Morphs
    u32 MorphKeyframeCount;
    MorphKeyframe MorphList[MorphKeyframeCount];
    
    
    
    // Cameras
    u32 CameraKeyframeCount;
    CameraKeyframe CameraList[CameraKeyframeCount];
    
    // Lights
    u32 LightKeyframeCount;
    LightKeyframe LightList[LightKeyframeCount];
    
    
    // Shadows
    u32 ShadowKeyframeCount;
    ShadowKeyframe ShadowList[ShadowKeyframeCount];
    
    // Disp/IK
    u32 DispIKKeyframeCount;
    DispIKKeyframe DispIKList[DispIKKeyframeCount];
};


VMD VMD @ 0x00;