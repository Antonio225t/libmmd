#pragma author Antonio225
#pragma description PMX Polygon Model Extended (.pmx)
#pragma pattern_limit 0xFFFFFFFF
#pragma array_limit 0xFFFFFFFF
#pragma endian little

#include <std/io.pat>
#include <std/string.pat>




fn IsVersionNew() {
    std::string::NullString ActualMagic @ 0x00;

    if (ActualMagic == "PMX ") {
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

struct Global {
    u8 EncodingType; // 0 = UTF16LE, 1 = UTF8
    Vec4 VertexOffset; // Applied to the vertices of this global
    u8 VertexByteSize;
    u8 TextureByteSize;
    u8 MaterialByteSize;
    u8 BoneByteSize;
    u8 MorphByteSize;
    u8 RigidBodyByteSize;
    
};

enum IndexType : u8 {
    NO_VALUE = 0x0,
    U8       = 0x1,
    U16      = 0x2,
    U32      = 0x4
};

enum EncodingType : u8 {
    UTF_16_LITTLE_ENDIAN = 0,
    UTF_8                = 1
};

struct Header {
    char Magic[4]; // "PMX "
    float Version; // 2 or 2.1
    
    u8 GlobalsCount;
    EncodingType EncodingType;
    u8 AdditionalUVs;
    IndexType VertexByteSize;
    IndexType TextureByteSize;
    IndexType MaterialByteSize;
    IndexType BoneByteSize;
    IndexType MorphByteSize;
    IndexType RigidBodyByteSize;
};



// Info

struct ModelInfo {
    Text ModelNameJP;
    Text ModelNameENG;
    
    Text CommentJP;
    Text CommentENG;
};


Header PMX_Header @ 0x00;
ModelInfo PMX_Info @ $;


// Vertices

enum WeightDeformType : u8 {
    BDEF1 = 0x00,
    BDEF2 = 0x01,
    BDEF4 = 0x02,
    SDEF  = 0x03,
    QDEF  = 0x04 // Only in 2.1
};

struct BDEF1Deform {
    s8 BoneTarget[u8(PMX_Header.BoneByteSize)];
};

struct BDEF2Deform {
    s8 BoneTarget1[u8(PMX_Header.BoneByteSize)];
    s8 BoneTarget2[u8(PMX_Header.BoneByteSize)];
    float Weight;
    // Weight bone 2 is 1.0 - Weight
};

struct BDEF4Deform {
    s8 BoneTarget1[u8(PMX_Header.BoneByteSize)];
    s8 BoneTarget2[u8(PMX_Header.BoneByteSize)];
    s8 BoneTarget3[u8(PMX_Header.BoneByteSize)];
    s8 BoneTarget4[u8(PMX_Header.BoneByteSize)];
    float Weight1;
    float Weight2;
    float Weight3;
    float Weight4;
};

struct SDEFWeight {
    float Weight;
    Vec3 c;
    Vec3 r0;
    Vec3 r1;
};

struct SDEFDeform {
    s8 BoneTarget1[u8(PMX_Header.BoneByteSize)];
    s8 BoneTarget2[u8(PMX_Header.BoneByteSize)];
    SDEFWeight Weight;
};

struct QDEFDeform : BDEF4Deform {};

struct WeightDeform {
    WeightDeformType Type;
    
    if (Type == WeightDeformType::BDEF1) {
        BDEF1Deform Deform;
    } else if (Type == WeightDeformType::BDEF2) {
        BDEF2Deform Deform;
    } else if (Type == WeightDeformType::BDEF4) {
        BDEF4Deform Deform;
    } else if (Type == WeightDeformType::SDEF) {
        SDEFDeform Deform;
    } else if (Type == WeightDeformType::QDEF) {
        QDEFDeform Deform;
    }
};

struct Vertex {
    Vec3 Position;
    Vec3 Normal; // ???
    Vec2 UV;
    
    Vec4 AdditionalUV[PMX_Header.AdditionalUVs];
    WeightDeform WeightDeform;
    float EdgeScale;
};

struct Vertices {
    s32 VertexCount;
    Vertex VerticesList[VertexCount];
};

Vertices PMX_Vertices @ $;



// Faces

struct Face {
    s8 Face[u8(PMX_Header.VertexByteSize)];
};

struct Faces {
    s32 FaceCount;
    Face FacesList[FaceCount];
};

Faces PMX_Faces @ $;



// Textures

struct Texture {
    Text path;
};

struct Textures {
    s32 TextureCount;
    Texture TexturesList[TextureCount];
};

Textures PMX_Textures @ $;



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
    Text NameJP;
    Text NameENG;
    
    Vec4 DiffuseColor;
    Vec3 SpecularColor;
    float Shininess;
    Vec3 AmbientColor;
    
    u8 Flags;
    
    Vec4 EdgeColor;
    float EdgeSize;
    
    s8 Texture[u8(PMX_Header.TextureByteSize)];
    s8 SphereTexture[u8(PMX_Header.TextureByteSize)];
    SphereBlendMode SphereBlendMode;
    
    bool IsSharedToonTexture;
    s8 ToonTexture[IsSharedToonTexture ? 1 : u8(PMX_Header.TextureByteSize)];
    
    Text Comment;
    u32 VertexCount;
    
};

struct Materials {
    s32 MaterialCount;
    Material MaterialsList[MaterialCount];
};

Materials PMX_Materials @ $;



// Bones

// Flags:
// 0  = Is Display an Index
// 1  = Is Rotatable
// 2  = Is Movable
// 3  = Is Visible
// 4  = Is Controllable
// 5  = Is IK
// 6  = ???
// 7  = ???
// 8  = Inherits Rotation from Parent
// 9  = Inherits Position from Parent
// 10 = Fixed Direction
// 11 = Local Coordinate
// 12 = Physics After Deform
// 13 = External Parent Deform


struct TransformBone {
    s8 TargetBone[u8(PMX_Header.BoneByteSize)];
    float Influence;
};

struct BoneLocalCoordinates {
    Vec3 X;
    Vec3 Z;
};

struct IKLink {
    s8 TargetBone[u8(PMX_Header.BoneByteSize)];
    bool HasLimit;
    
    if (HasLimit) {
        Vec3 MinAngle;
        Vec3 MaxAngle;
    }
};

struct IKBone {
    s8 TargetBone[u8(PMX_Header.BoneByteSize)];
    s32 LoopCount;
    float RotationConstraint;
    
    s32 IKLinkCount;
    IKLink IKLinksList[IKLinkCount];
};


struct Bone {
    Text NameJP;
    Text NameENG;
    
    Vec3 Position;
    s8 ParentBone[u8(PMX_Header.BoneByteSize)];
    s32 Layer;
    
    u16 Flags;
    
    if ((Flags & 0x01) != 0) {
        u8 DisplayConnection[u8(PMX_Header.BoneByteSize)];
    } else {
        Vec3 DisplayConnection;
    }
    
    if ((Flags & 0x200) != 0 || (Flags & 0x100) != 0) {
        TransformBone AdditionalTransform;
    }
    
    if ((Flags & 0x400) != 0) {
        Vec3 Axis;
    }
    
    if ((Flags & 0x800) != 0) {
        BoneLocalCoordinates LocalCoordinates;
    }
    
    if ((Flags & 0x2000) != 0) {
        s32 ExternalTransformKey;
    }
    
    if ((Flags & 0x20) != 0) {
        IKBone IKBones;
    }
};

struct Bones {
    s32 BoneCount;
    Bone BonesList[BoneCount];
};

Bones PMX_Bones @ $;



// Morphs

enum MorphDataType : u8 {
    GROUP    = 0x00,
    VERTEX   = 0x01,
    BONE     = 0x02,
    UV       = 0x03,
    UV_EXT1  = 0x04,
    UV_EXT2  = 0x05,
    UV_EXT3  = 0x06,
    UV_EXT4  = 0x07,
    MATERIAL = 0x08,
    FLIP     = 0x09, // Only 2.1
    IMPULSE  = 0x10  // Only 2.1
};

enum MorphCategory : u8 {
    HIDDEN  = 0x00,
    EYEBROW = 0x01,
    EYES    = 0x02,
    MOUTH   = 0x03,
    OTHER   = 0x04
};



struct MorphGroupOffset {
    u8 MorphIndex[u8(PMX_Header.MorphByteSize)];
    float Factor;
};

struct MorphGroup {
    u32 OffsetCount;
    MorphGroupOffset OffsetsList[OffsetCount];
};



struct MorphVertexOffset {
    u8 VertexIndex[u8(PMX_Header.VertexByteSize)];
    Vec3 Offset;
};

struct MorphVertex {
    u32 OffsetCount;
    MorphVertexOffset OffsetsList[OffsetCount];
};



struct MorphBoneOffset {
    u8 BoneIndex[u8(PMX_Header.BoneByteSize)];
    Vec3 PositionOffset;
    Vec4 RotationOffset; // If it's all 0, then it would default to X: 0, Y: 0, Z: 0, W: 1
};

struct MorphBone {
    u32 OffsetCount;
    MorphBoneOffset OffsetsList[OffsetCount];
};



struct MorphUVOffset {
    u8 VertexIndex[u8(PMX_Header.VertexByteSize)];
    Vec4 Offset;
};

struct MorphUV {
    u32 OffsetCount;
    MorphUVOffset OffsetsList[OffsetCount];
};



enum MorphMaterialOffsetType : u8 {
    ADDITION       = 0x00,
    MULTIPLICATION = 0x01
};

struct MorphMaterialOffset {
    u8 MaterialIndex[u8(PMX_Header.MaterialByteSize)];
    MorphMaterialOffsetType OffsetType;
    
    Vec4 DiffuseColorOffset;
    Vec3 SpecularColorOffset;
    float ShininessOffset;
    Vec3 AmbientColorOffset;
    
    Vec4 EdgeColorOffset;
    float EdgeSizeOffset;
    
    Vec4 TextureFactor;
    Vec4 SphereTextureFactor;
    Vec4 ToonTextureFactor;
};

struct MorphMaterial {
    u32 OffsetCount;
    MorphMaterialOffset OffsetsList[OffsetCount];
};



struct MorphFlipOffset {
    u8 MorphIndex[u8(PMX_Header.MorphByteSize)];
    float Influence;
};

struct MorphFlip {
    u32 OffsetCount;
    MorphFlipOffset OffsetsList[OffsetCount];
};



struct MorphImpulseOffset {
    u8 RigidBodyIndex[u8(PMX_Header.RigidBodyByteSize)];
    u8 LocalFlag;
    Vec3 MovementSpeed;
    Vec3 RotationTorque;
};

struct MorphImpulse {
    s32 OffsetCount;
    MorphFlipOffset OffsetsList[OffsetCount];
};



struct Morph {
    Text NameJP;
    Text NameENG;
    
    MorphCategory Category;
    MorphDataType Type;
    
    if (Type == MorphDataType::GROUP) {
        MorphGroup Morph;
    } else if (Type == MorphDataType::VERTEX) {
        MorphVertex Morph;
    } else if (Type == MorphDataType::BONE) {
        MorphBone Morph;
    } else if (Type == MorphDataType::UV || Type == MorphDataType::UV_EXT1 || Type == MorphDataType::UV_EXT2 || Type == MorphDataType::UV_EXT3 || Type == MorphDataType::UV_EXT4) {
        MorphUV Morph;
    } else if (Type == MorphDataType::MATERIAL) {
        MorphMaterial Morph;
    } else if (Type == MorphDataType::FLIP) {
        MorphFlip Morph;
    } else if (Type == MorphDataType::IMPULSE) {
        MorphImpulse Morph;
    }
};

struct Morphs {
    s32 MorphCount;
    Morph MorphsList[MorphCount];
};

Morphs PMX_Morphs @ $;



// Display Items

enum DisplayElementType : u8 {
    BONE  = 0x00,
    MORPH = 0x01
};

struct DisplayElement {
    DisplayElementType Type;
    
    if (Type == DisplayElementType::BONE) {
        u8 BoneIndex[u8(PMX_Header.BoneByteSize)];
    } else if (Type == DisplayElementType::MORPH) {
        u8 MorphIndex[u8(PMX_Header.MorphByteSize)];
    }
};

struct DisplayItem {
    Text NameJP;
    Text NameENG;
    
    bool IsSpecial;
    
    u32 DisplayElementCount;
    DisplayElement DisplayElementsList[DisplayElementCount];
};

struct DisplayItems {
    s32 DisplayItemCount;
    DisplayItem DisplayItemsList[DisplayItemCount];
};

DisplayItems PMX_DisplayItems @ $;



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
    Text NameJP;
    Text NameENG;
    
    u8 RelatedBoneIndex[u8(PMX_Header.BoneByteSize)]; // If this is "-1" then there is no related bone
    s8 CollisionGroupID;
    u16 CollisionGroupMask;
    
    RigidBodyType Type;
    Vec3 Size;
    Vec3 Position;
    Vec4 Rotation; // In mmdtools for blender this is a Vec3 but... This looks like a Vec4
    
    float Mass;
    float VelocityAttenuation;
    float Bounce;
    float Friction;
    
    RigidBodyMode Mode;
};

struct RigidBodies {
    s32 RigidBodyCount;
    RigidBody RigidBodiesList[RigidBodyCount];
};

RigidBodies PMX_RigidBodies @ $;



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
    Text NameJP;
    Text NameENG;
    
    JointMode Mode;
    
    u8 SrcRigidBody[u8(PMX_Header.RigidBodyByteSize)]; // If "-1" then there is no source rigid body
    u8 DestRigidBody[u8(PMX_Header.RigidBodyByteSize)]; // If "-1" then there is no destination rigid body
    
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

Joints PMX_Joints @ $;



// Soft Bodies (2.1 Only)

// Flags:
// 0 = B-Link
// 1 = Cluster Creation
// 2 = Link Crossing

enum SoftBodyShape : u8 {
    TRI_MESH = 0x00,
    ROPE     = 0x01
};

enum AerodynamicsModel : u32 {
    V_POINT    = 0x00,
    V_TWOSIDED = 0x01,
    V_ONESIDED = 0x02,
    F_TWOSIDED = 0x03,
    F_ONESIDED = 0x04
};

struct SoftBodyConfig {
    float Config_VCF;
    float Config_DP;
    float Config_DG;
    float Config_LF;
    float Config_PR;
    float Config_VC;
    float Config_DF;
    float Config_MT;
    float Config_CHR;
    float Config_KHR;
    float Config_SHR;
    float Config_AHR;
};

struct SoftBodyCluster {
    float Cluster_SRHR_CL;
    float Cluster_SKHR_CL;
    float Cluster_SSHR_CL;
    float Cluster_SR_SPLT_CL;
    float Cluster_SK_SPLT_CL;
    float Cluster_SS_SPLT_CL;
};

struct SoftBodyInterpolation {
    s32 Interpolation_V_IT;
    s32 Interpolation_P_IT;
    s32 Interpolation_D_IT;
    s32 Interpolation_C_IT;
};

struct SoftBodyMaterial {
    s32 Material_LST;
    s32 Material_AST;
    s32 Material_VST;
};

struct SoftBodyAnchor {
    u8 RigidBodyIndex[u8(PMX_Header.RigidBodyByteSize)];
    u8 VertexIndex[u8(PMX_Header.VertexByteSize)];
    bool NearMode;
};

struct SoftBodyAnchors {
    s32 AnchorBodyCount;
    SoftBodyAnchor AnchorBodiesList[AnchorBodyCount];
};

struct SoftBodyVertexPin {
    u8 VertexIndex[u8(PMX_Header.VertexByteSize)];
};

struct SoftBodyVertexPins {
    s32 VertexPinCount;
    SoftBodyVertexPin VertexPinsList[VertexPinCount];
};

struct SoftBody {
    Text NameJP;
    Text NameENG;
    
    SoftBodyShape ShapeType;
    u8 MaterialIndex[u8(PMX_Header.RigidBodyByteSize)];
    
    u8 CollisionGroupID; // 1 - 16
    u16 CollisionGroupMask; // Binary numbers 1 - 16
    
    u8 Flags;
    
    s32 BLinkCreateDistance;
    s32 ClusterCount;
    
    float TotalMass;
    float CollisionMargin;
    
    AerodynamicsModel AerodynamicsModel;
    
    SoftBodyConfig Config;
    SoftBodyCluster Cluster;
    SoftBodyInterpolation Interpolation;
    SoftBodyMaterial Material;
    
    SoftBodyAnchors AnchorBodies;
    SoftBodyVertexPins VertexPins;
};

struct SoftBodies {
    s32 SoftBodyCount;
    SoftBody SoftBodiesList[SoftBodyCount];
};

if (PMX_Header.Version == 2) {
    return;
}

SoftBodies PMX_SoftBodies @ $;