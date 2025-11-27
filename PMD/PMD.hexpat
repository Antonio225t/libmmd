#pragma author Antonio225
#pragma description PMD Polygon Model Data (.pmd)
#pragma pattern_limit 0xFFFFFFFF
#pragma array_limit 0xFFFFFFFF
#pragma endian little

#include <std/io.pat>
#include <std/string.pat>




fn IsVersionNew() {
    std::string::NullString ActualMagic @ 0x00;

    if (ActualMagic == "Pmd") {
        return true;
    }
    return false;
};



// Others

struct Vec2 {
    float X;
    float Y;
};

struct Vec3 {
    float X;
    float Y;
    float Z;
};

struct Vec4 {
    float X;
    float Y;
    float Z;
    float W;
};

struct Text {
    u32 Length;
    char Characters[Length];
};

// Header

struct Header {
    char Magic[3]; // "Pmd"
    float Version; // 1.0
    
    char ModelNameJP[20]; // In Shift-JIS
    char ModelCommentJP[0x100]; // In Shift-JIS
};


Header PMD_Header @ 0x00;


// Vertices

struct Vertex {
    Vec3 Position;
    Vec3 Normal; // ???
    Vec2 UV;
    
    u16 BoneID1;
    u16 BoneID2;
    
    u8 Bone1Weight; // Bone2Weight is 100 - Bone1Weight
    bool HasEdge;
};

struct Vertices {
    u32 VertexCount;
    Vertex VerticesList[VertexCount];
};

Vertices PMD_Vertices @ $;



// Faces

struct Face {
    u16 Face;
};

struct Faces {
    u32 FaceCount;
    Face FacesList[FaceCount];
};

Faces PMD_Faces @ $;



// Materials

// Flags:
// 0 = Is Double Sided (has cull)
// 1 = Draw Drop Shadow
// 2 = Draw Self Shadow Map
// 3 = Draw Self Shadow that got recieved from Self Shadow Map
// 4 = Draw Toon Edge (the "pencil edge")
// 5 = Vertex Color (ONLY 2.1, uses Vec4 1 for the color)
// 6 = Point Drawing (ONLY 2.1, the 3 vertices are points)
// 7 = Line Drawing (ONLY 2.1, the triangle is rendered as a line)


enum SphereBlendMode : s8 {
    DISABLED = 0x00,
    MULTIPLY = 0x01,
    ADDITIVE = 0x02,
    SUBTEX   = 0x03
};

struct Material {
    Vec4 DiffuseColor;
    float Shininess;
    Vec3 SpecularColor;
    Vec3 AmbientColor;
    
    s8 ToonIndex; // 0 - 9, if -1 then there is no toon
    
    s8 EdgeFlag; // Maybe boolean
    u32 VertexCount;
    
    char TexturePath[20]; // In Shift-JIS
};

struct Materials {
    s32 MaterialCount;
    Material MaterialsList[MaterialCount];
};

Materials PMD_Materials @ $;



// Bones

enum BoneType : u8 {
    RO         = 0x00, // Only rotation
    RO_MOV     = 0x01, // Rotation & Position
    IK         = 0x02, // IK
    UNKNOWN    = 0x03, // TODO: Check this type
    IK_INFL_RO = 0x04, // Hip and knee bones
    INF_RO     = 0x05, // Eyes bones
    IK_CON     = 0x06, // ???
    HID        = 0x07, // Hidden bone
    TW         = 0x08, // Twist bone
    REVO       = 0x09  // Co-Rotate bone
};


struct Bone {
    char NameJP[20]; // In Shift-JIS
    
    u16 Parent; // If 0xFFFF then there is no parent
    u16 TailBone; // If 0xFFFF then rhere is no tail bone
    
    BoneType Type;
    
    if (Type == BoneType::REVO) {
        s16 IKBone;
    } else {
        u16 IKBone;
    }
    
    Vec3 Position;
};

struct Bones {
    u16 BoneCount;
    Bone BonesList[BoneCount];
};

Bones PMD_Bones @ $;



// IKs

struct IK {
    u16 Bone;
    u16 TargetBone;
    
    u8 IKLinkCount;
    
    u16 InteractionCount;
    float ControlWeight;
    u16 IKChildrenList[IKLinkCount];
};

struct IKs {
    u16 IKCount;
    IK IKsList[IKCount];
};

IKs PMD_IKs @ $;



// Morphs

enum MorphCategory : u8 {
    OTHER   = 0x00,
    EYEBROW = 0x01,
    EYES    = 0x02,
    MOUTH   = 0x03,
};


struct MorphVertex {
    u32 Index;
    Vec3 Offset;
};

struct Morph {
    char NameJP[20];
    
    u32 AffectedVertices;
    MorphCategory Category;
    
    MorphVertex VertexOffsetsList[AffectedVertices];
};

struct Morphs {
    u16 MorphCount;
    Morph MorphsList[MorphCount];
};

Morphs PMD_Morphs @ $;



// Display Items Morphs

struct DisplayItemMorph {
    u16 MorphIndex;
};

struct DisplayItemMorphs {
    s8 DisplayItemMorphCount;
    DisplayItemMorph DisplayItemMorphsList[DisplayItemMorphCount];
};

DisplayItemMorphs PMD_DisplayItemMorphs @ $;



// Display Items Bones Groups

struct DisplayItemBonesGroup {
    char NameJP[50]; // Shift-JIS
};

struct DisplayItemBonesGroups {
    s8 DisplayItemBonesGroupCount;
    DisplayItemBonesGroup DisplayItemBonesGroupList[DisplayItemBonesGroupCount];
};

DisplayItemBonesGroups PMD_DisplayItemBonesGroups @ $;



// Display Items Bones

struct DisplayItemBone {
    u16 BoneIndex;
    s8 GroupIndex;
};

struct DisplayItemBones {
    s8 DisplayItemBoneCount;
    DisplayItemBone DisplayItemBonesList[DisplayItemBoneCount+1];
};

DisplayItemBones PMD_DisplayItemBones @ $;



// TODO: Make a check if the file continues

// English data

struct EnglishBoneName {
    char BoneNameENG[20]; // In Shift-JIS
};

struct EnglishMorphName {
    char MorphNameENG[20]; // In Shift-JIS
};

struct EnglishBoneGroupName {
    char BoneGroupNameENG[50]; // In Shift-JIS
};

struct EnglishToonPathName {
    char BoneToonPathENG[0x64]; // In Shift-JIS
};


struct EnglishNames {
    bool HasEnglishNames;
    
    if (HasEnglishNames) {
        char ModelNameENG[20]; // In Shift-JIS
        char ModelCommentENG[0x100]; // In Shift-JIS
    
        EnglishBoneName EnglishBoneNamesList[PMD_Bones.BoneCount];
        EnglishMorphName EnglishMorphNamesList[PMD_Morphs.MorphCount-1];
        EnglishBoneGroupName EnglishBoneGroupNamesList[PMD_DisplayItemBonesGroups.DisplayItemBonesGroupCount];
    }
    
};

EnglishNames PMD_EnglishNames @ $;



// TODO: Make a check if the file continues

// Toon Paths

struct ToonPath {
    char ToonPath[0x64];
};

ToonPath PMD_ToonPaths[10] @ $;



// TODO: Make a check if the file continues

// Rigid Bodies

enum RigidBodyType : u8 {
    SPHERE  = 0x00,
    BOX     = 0x01,
    CAPSULE = 0x02
};

enum RigidBodyMode : u8 {
    STATIC       = 0x00,
    DYNAMIC      = 0x01,
    DYNAMIC_BONE = 0x02
};

struct RigidBody {
    char RigidBodyNameJP[20]; // In Shift-JIS
    
    u16 TargetBone; // If 0xFFFF then there is no target bone
    u8 CollisionGroupNumber;
    u16 CollisionGroupMask;
    
    RigidBodyType Type;
    
    Vec3 Size;
    Vec3 Position;
    Vec3 Rotation;
    
    float Mass;
    float VelocityAttenuation;
    float RotationAttenuation;
    float Bounce;
    float Friction;
    
    RigidBodyMode Mode;
};

struct RigidBodies {
    s32 RigidBodyCount;
    RigidBody RigidBodiesList[RigidBodyCount];
};

RigidBodies PMD_RigidBodies @ $;



// Joints

enum JointMode : u8 {
    SPRING_6DOF = 0x00,
    NORMAL_6DOF = 0x01, // Only 2.1
    P2P         = 0x02, // Only 2.1
    CONE_TWIST  = 0x03, // Only 2.1
    SLIDER      = 0x04, // Only 2.1
    HINGE       = 0x05  // Only 2.1
};

struct Joint {
    char JointNameJP[20]; // In Shift-JIS
    
    u32 SrcRigidBody;
    u32 DestRigidBody;
    
    Vec3 Position;
    Vec3 Rotation;
    
    Vec3 MinPosition;
    Vec3 MaxPosition;
    
    Vec3 MinRotation;
    Vec3 MaxRotation;
    
    Vec3 SpringPosition;
    Vec3 SpringRotation;
};

struct Joints {
    s32 JointCount;
    Joint JointsList[JointCount];
};

Joints PMD_Joints @ $;