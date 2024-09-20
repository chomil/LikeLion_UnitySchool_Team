Shader "WaterBuiltIn"
{
    Properties
    {
        _WaterTexture("WaterTexture", 2D) = "black" {}
        _Water_Texture_Opacity("Water Texture Opacity", Range(0, 1)) = 1
        _Water_Texture_Movement("Water Texture Movement", Vector) = (0, 0, 0, 0)
        _Surface_Color("Surface Color", Color) = (0, 0, 0, 0)
        _Deep_Color("Deep Color", Color) = (0, 0, 0, 0)
        [Normal][NoScaleOffset]_Normal_Map("Normal Map", 2D) = "bump" {}
        _WaveSize("WaveSize", Range(0, 5)) = 0.3
        _WaveSpeed("WaveSpeed", Vector) = (0, 0, 0, 0)
        _WaveSize2("WaveSize2", Range(0, 5)) = 0.15
        _WaveSpeed2("WaveSpeed2", Vector) = (0, 0, 0, 0)
        _Mettalic("Mettalic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Normal_Strength("Normal Strength", Range(0, 1)) = 0.3
        _Depth_Strength("Depth Strength", Range(0.01, 1)) = 0.15
        [ToggleUI]_Caustics_Enabled("Caustics Enabled", Float) = 1
        [NoScaleOffset]_Caustics_Map("Caustics Map", 2D) = "white" {}
        _Caustics_Scale("Caustics Scale", Range(0.05, 1)) = 0.05
        _Distortion_Scale("Distortion Scale", Range(1, 1000)) = 500
        _Distortion_Speed("Distortion Speed", Range(0.0001, 0.01)) = 0.0001
        [ToggleUI]_Refraction_Enabled("Refraction Enabled", Float) = 0
        _Refraction_Strength("Refraction Strength", Range(0.01, 1)) = 0.147
        [ToggleUI]_Foam_Enabled("Foam Enabled", Float) = 1
        _Foam_Size("Foam Size", Range(0, 10)) = 0
        _Foam_Speed("Foam Speed", Range(0.01, 10)) = 0.01
        _Foam_Noise_Scale("Foam Noise Scale", Range(0.1, 1000)) = 200
        _Foam_Noise_Amplitude("Foam Noise Amplitude", Range(0.01, 1)) = 0.2
        _Caustics_Opacity("Caustics Opacity", Range(0, 1)) = 1
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
    SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType"="Transparent"
            "BuiltInMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="BuiltInLitSubTarget"
        }
        Pass
        {
            Name "BuiltIn Forward"
            Tags
            {
                "LightMode" = "ForwardBase"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV : INTERP0;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP1;
            #endif
             float4 tangentWS : INTERP2;
             float4 texCoord0 : INTERP3;
             float4 fogFactorAndVertexLight : INTERP4;
             float4 shadowCoord : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
             float3 viewDirectionWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.shadowCoord.xyzw = input.shadowCoord;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            output.viewDirectionWS.xyz = input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.shadowCoord = input.shadowCoord.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            output.viewDirectionWS = input.viewDirectionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Surface_Color;
        float4 _Deep_Color;
        float4 _Normal_Map_TexelSize;
        float _WaveSize;
        float2 _WaveSpeed;
        float _WaveSize2;
        float2 _WaveSpeed2;
        float _Mettalic;
        float _Smoothness;
        float _Normal_Strength;
        float _Depth_Strength;
        float4 _Caustics_Map_TexelSize;
        float _Caustics_Scale;
        float _Distortion_Scale;
        float _Distortion_Speed;
        float _Refraction_Strength;
        float _Refraction_Enabled;
        float _Foam_Speed;
        float _Foam_Noise_Scale;
        float _Foam_Noise_Amplitude;
        float _Foam_Size;
        float _Foam_Enabled;
        float _Caustics_Enabled;
        float4 _WaterTexture_TexelSize;
        float4 _WaterTexture_ST;
        float2 _Water_Texture_Movement;
        float _Water_Texture_Opacity;
        float _Caustics_Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        float _Depth_power;
        TEXTURE2D(_Caustics_Map);
        SAMPLER(sampler_Caustics_Map);
        TEXTURE2D(_WaterTexture);
        SAMPLER(sampler_WaterTexture);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(abs(A), B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        struct Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float
        {
        float3 AbsoluteWorldSpacePosition;
        float3 TimeParameters;
        };
        
        void SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(float _WaveSize, UnityTexture2D _Normal, float2 _WaveSpeed, float _WaveSize2, float2 _WaveSpeed2, float _Normal_Stranght, Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0 = _Normal;
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_A_4 = 0;
        float2 _Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0 = float2(_Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1, _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3);
        float _Property_4a9326d48476475eabddc6d02a6b6f06_Out_0 = _WaveSize;
        float2 _Property_79f9d365373e442f94e67237d36fa439_Out_0 = _WaveSpeed;
        float2 _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2;
        Unity_Multiply_float2_float2(_Property_79f9d365373e442f94e67237d36fa439_Out_0, (IN.TimeParameters.x.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2);
        float2 _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_4a9326d48476475eabddc6d02a6b6f06_Out_0.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2, _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3);
        float4 _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.tex, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.samplerstate, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.GetTransformedUV(_TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3));
        _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0);
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_R_4 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.r;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_G_5 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.g;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_B_6 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.b;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_A_7 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.a;
        UnityTexture2D _Property_3602dc36773841649ece93e40cb97791_Out_0 = _Normal;
        float _Property_b4289ec1b7944303907293e29374dd74_Out_0 = _WaveSize2;
        float2 _Property_4a9df16b1002432a9dbde8ec0432401f_Out_0 = _WaveSpeed2;
        float2 _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2;
        Unity_Multiply_float2_float2(_Property_4a9df16b1002432a9dbde8ec0432401f_Out_0, (IN.TimeParameters.x.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2);
        float2 _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_b4289ec1b7944303907293e29374dd74_Out_0.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2, _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3);
        float4 _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3602dc36773841649ece93e40cb97791_Out_0.tex, _Property_3602dc36773841649ece93e40cb97791_Out_0.samplerstate, _Property_3602dc36773841649ece93e40cb97791_Out_0.GetTransformedUV(_TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3));
        _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0);
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_R_4 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.r;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_G_5 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.g;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_B_6 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.b;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_A_7 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.a;
        float3 _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2;
        Unity_NormalBlend_float((_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.xyz), (_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.xyz), _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2);
        float _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0 = _Normal_Stranght;
        float _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2;
        Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2);
        float2 _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0 = float2(float(0), _ProjectionParams.z);
        float _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3;
        Unity_Remap_float(_Distance_e9573e7724034e4a8c25515bfdb49340_Out_2, _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0, float2 (1, 0), _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3);
        float _Power_f267dd9724c74f58953f24eee4860ba9_Out_2;
        Unity_Power_float(_Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3, float(500), _Power_f267dd9724c74f58953f24eee4860ba9_Out_2);
        float _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3;
        Unity_Lerp_float(float(0), _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0, _Power_f267dd9724c74f58953f24eee4860ba9_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3);
        float3 _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        Unity_NormalStrength_float(_NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3, _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2);
        OutVector3_1 = _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float
        {
        float4 ScreenPosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float _DepthScale, float _Depth_Streght, float _Depth_power, float3 _Normal, float _RefractionEnabled, float _Foam_Scale, float _Foam_Speed, float _Foam_Noise_Scale, float _Foam_Noise_Amplitude, float _Foam_Falloff, Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float IN, out float OutVector1_1, out float Depth_2, out float SecondFadeDepth_3, out float FoamDepth_4)
        {
        float _Property_318cdc9ecaed4eadaf06301c7076532f_Out_0 = _RefractionEnabled;
        float4 _ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float3 _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0 = _Normal;
        float3 _Add_356e75099f72430888ad16810e5d286d_Out_2;
        Unity_Add_float3((_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2);
        float3 _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3;
        Unity_Branch_float3(_Property_318cdc9ecaed4eadaf06301c7076532f_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2, (_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3);
        float _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1;
        Unity_SceneDepth_Eye_float((float4(_Branch_9e2e59e02af84dabb4377a7f18245711_Out_3, 1.0)), _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1);
        float4 _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0 = IN.ScreenPosition;
        float _Split_16d3558d6d92445a880cb5f6676de872_R_1 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[0];
        float _Split_16d3558d6d92445a880cb5f6676de872_G_2 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[1];
        float _Split_16d3558d6d92445a880cb5f6676de872_B_3 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[2];
        float _Split_16d3558d6d92445a880cb5f6676de872_A_4 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[3];
        float _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0 = _DepthScale;
        float _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2;
        Unity_Add_float(_Split_16d3558d6d92445a880cb5f6676de872_A_4, _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2);
        float _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        Unity_Subtract_float(_SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2);
        float _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2;
        Unity_Comparison_Less_float(_Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, float(0.1), _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2);
        float _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1);
        float4 _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0 = IN.ScreenPosition;
        float _Split_7d45e7abeb8e4d2a97574e613125e070_R_1 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[0];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_G_2 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[1];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_B_3 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[2];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_A_4 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[3];
        float _Property_0909716a724643ba9aa2fef403343a7d_Out_0 = _DepthScale;
        float _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2;
        Unity_Add_float(_Split_7d45e7abeb8e4d2a97574e613125e070_A_4, _Property_0909716a724643ba9aa2fef403343a7d_Out_0, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2);
        float _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2;
        Unity_Subtract_float(_SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2);
        float _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3;
        Unity_Branch_float(_Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3);
        float _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0 = _Depth_Streght;
        float _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2;
        Unity_Multiply_float_float(_Branch_ddac7cdb85fe4825bda3abac374df776_Out_3, _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0, _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2);
        float _Saturate_5cc2a092cece487983e25916a82532c4_Out_1;
        Unity_Saturate_float(_Multiply_c5e61fe354954492921110c4bf3178fd_Out_2, _Saturate_5cc2a092cece487983e25916a82532c4_Out_1);
        float _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1;
        Unity_OneMinus_float(_Saturate_5cc2a092cece487983e25916a82532c4_Out_1, _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1);
        float _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0 = _Depth_power;
        float _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2;
        Unity_Power_float(_OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1, _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0, _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2);
        float _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Unity_OneMinus_float(_Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2, _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1);
        float4 _ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1;
        Unity_SceneDepth_Eye_float(_ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0, _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1);
        float4 _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0 = IN.ScreenPosition;
        float _Split_ba379f9dd00c47e89bdaff09775abecb_R_1 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[0];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_G_2 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[1];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_B_3 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[2];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_A_4 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[3];
        float _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0 = _DepthScale;
        float _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2;
        Unity_Add_float(_Split_ba379f9dd00c47e89bdaff09775abecb_A_4, _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2);
        float _Subtract_9cdc83575a4441888b548be03402455c_Out_2;
        Unity_Subtract_float(_SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2, _Subtract_9cdc83575a4441888b548be03402455c_Out_2);
        float _Multiply_adb140a84534463c8282fcc1cf533119_Out_2;
        Unity_Multiply_float_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, 5, _Multiply_adb140a84534463c8282fcc1cf533119_Out_2);
        float _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1;
        Unity_Saturate_float(_Multiply_adb140a84534463c8282fcc1cf533119_Out_2, _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1);
        float _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1;
        Unity_OneMinus_float(_Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1, _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1);
        float _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        Unity_OneMinus_float(_OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1, _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1);
        float _Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0 = _Foam_Falloff;
        float _Negate_c1176c2567c04045a1e28135f9db2058_Out_1;
        Unity_Negate_float(_Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1);
        float _Add_df082a7d0dc44ed7947582af57d7db85_Out_2;
        Unity_Add_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1, _Add_df082a7d0dc44ed7947582af57d7db85_Out_2);
        float _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0 = _Foam_Scale;
        float _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2;
        Unity_Multiply_float_float(_Add_df082a7d0dc44ed7947582af57d7db85_Out_2, _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0, _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2);
        float _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1;
        Unity_Saturate_float(_Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2, _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1);
        float _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1;
        Unity_OneMinus_float(_Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1, _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1);
        float _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1;
        Unity_OneMinus_float(_OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1, _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1);
        float _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0 = _Foam_Speed;
        float _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0, _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2);
        float2 _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_635a6efa292d46ee852700ca8924fd35_Out_2.xx), _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3);
        float _Property_43d4265c5429441fb1d91ad7136782ad_Out_0 = _Foam_Noise_Scale;
        float _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3, _Property_43d4265c5429441fb1d91ad7136782ad_Out_0, _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2);
        float _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0 = _Foam_Noise_Amplitude;
        float _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2;
        Unity_Multiply_float_float(_SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2, _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0, _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2);
        float _Absolute_20c059810dc244fb9613bea848e93047_Out_1;
        Unity_Absolute_float(_Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2, _Absolute_20c059810dc244fb9613bea848e93047_Out_1);
        float _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2;
        Unity_Add_float(_OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1, _Absolute_20c059810dc244fb9613bea848e93047_Out_1, _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2);
        float _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        Unity_Saturate_float(_Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2, _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1);
        OutVector1_1 = _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Depth_2 = _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        SecondFadeDepth_3 = _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        FoamDepth_4 = _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float
        {
        float3 AbsoluteWorldSpacePosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(UnityTexture2D _Caustics, float _Distortion_Scale, float _Distortion_Speed, float _Caustics_Scale, float _Caustics_Opacity, Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float IN, out float4 OutVector4_1)
        {
        float _Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0 = _Caustics_Opacity;
        UnityTexture2D _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0 = _Caustics;
        float _Split_1012f2365d224feb8935e9feaa351beb_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_1012f2365d224feb8935e9feaa351beb_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_1012f2365d224feb8935e9feaa351beb_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_1012f2365d224feb8935e9feaa351beb_A_4 = 0;
        float2 _Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0 = float2(_Split_1012f2365d224feb8935e9feaa351beb_R_1, _Split_1012f2365d224feb8935e9feaa351beb_B_3);
        float _Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0 = _Caustics_Scale;
        float2 _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3;
        Unity_TilingAndOffset_float(_Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0, (_Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0.xx), float2 (0, 0), _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3);
        float _Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0 = _Distortion_Speed;
        float _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2;
        Unity_Multiply_float_float(_Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0, IN.TimeParameters.x, _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2);
        float _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1;
        Unity_Negate_float(_Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2, _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1);
        float2 _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Negate_6e0c023331f9435fa320590f00ac95d8_Out_1.xx), _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3);
        float _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0 = _Distortion_Scale;
        float _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3, _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0, _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2);
        float _Property_2cdef5d6547f40bf927ab89938223638_Out_0 = _Distortion_Speed;
        float _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2;
        Unity_Multiply_float_float(_Property_2cdef5d6547f40bf927ab89938223638_Out_0, IN.TimeParameters.x, _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2);
        float2 _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2.xx), _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3);
        float _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0 = _Distortion_Scale;
        float _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3, _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2);
        float _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3;
        Unity_Lerp_float(_SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2, float(0.5), _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3);
        float2 _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3;
        Unity_Lerp_float2(_TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3, (_Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3.xx), float2(0.4, 0.4), _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3);
        float4 _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.tex, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.samplerstate, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.GetTransformedUV(_Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3));
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_R_4 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.r;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_G_5 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.g;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_B_6 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.b;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_A_7 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.a;
        float4 _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        Unity_Multiply_float4_float4((_Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0.xxxx), _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0, _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2);
        OutVector4_1 = _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_942d5332a122417fa73853897fe60c48_Out_0 = _Foam_Enabled;
            float _Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0 = _Water_Texture_Opacity;
            UnityTexture2D _Property_c1940be719424daf973545cb452ff735_Out_0 = UnityBuildTexture2DStruct(_WaterTexture);
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_A_4 = 0;
            float2 _Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0 = float2(_Split_5a66b3eabf4247eab1df93cde1d431cc_R_1, _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3);
            float2 _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0 = _Water_Texture_Movement;
            float2 _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0, _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2);
            float2 _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3;
            Unity_TilingAndOffset_float(_Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0, float2 (1, 1), _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2, _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3);
            float4 _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c1940be719424daf973545cb452ff735_Out_0.tex, _Property_c1940be719424daf973545cb452ff735_Out_0.samplerstate, _Property_c1940be719424daf973545cb452ff735_Out_0.GetTransformedUV(_TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3));
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_R_4 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.r;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_G_5 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.g;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_B_6 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.b;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_A_7 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.a;
            float4 _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2;
            Unity_Multiply_float4_float4((_Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0.xxxx), _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0, _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2);
            float4 _Property_45db940379974187aa06193e4e91bf30_Out_0 = _Surface_Color;
            float4 _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0 = _Deep_Color;
            float _Property_f2bba435f69245e29ba364aa15a6246d_Out_0 = _Depth_Strength;
            float _Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0 = _WaveSize;
            UnityTexture2D _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0 = _WaveSpeed;
            float _Property_acee9dd3062c4febbba1a7f48505a892_Out_0 = _WaveSize2;
            float2 _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0 = _WaveSpeed2;
            float _Property_c934b87e11884ee8a832f236aeb6496d_Out_0 = _Normal_Strength;
            Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.TimeParameters = IN.TimeParameters;
            float3 _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(_Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0, _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0, _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0, _Property_acee9dd3062c4febbba1a7f48505a892_Out_0, _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0, _Property_c934b87e11884ee8a832f236aeb6496d_Out_0, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1);
            float _Property_334955ba786b43dc8b8b69068b22e167_Out_0 = _Refraction_Strength;
            float3 _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_334955ba786b43dc8b8b69068b22e167_Out_0.xxx), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2);
            float _Property_004ca3e6203d4184986681a4527c2e63_Out_0 = _Refraction_Enabled;
            float _Property_347e4eac494e4fe6892b846c0efc2313_Out_0 = _Foam_Speed;
            float _Property_dcb74838243b4512aa30f059bfa6798b_Out_0 = _Foam_Noise_Scale;
            float _Property_760c8cbb4aba427f8e610388fe099157_Out_0 = _Foam_Noise_Amplitude;
            float _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0 = _Foam_Size;
            Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float _DepthFade_d12ba53613cd41a2b21fcc4c74833226;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.ScreenPosition = IN.ScreenPosition;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.uv0 = IN.uv0;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.TimeParameters = IN.TimeParameters;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4;
            SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float(0), _Property_f2bba435f69245e29ba364aa15a6246d_Out_0, float(4), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2, _Property_004ca3e6203d4184986681a4527c2e63_Out_0, float(1), _Property_347e4eac494e4fe6892b846c0efc2313_Out_0, _Property_dcb74838243b4512aa30f059bfa6798b_Out_0, _Property_760c8cbb4aba427f8e610388fe099157_Out_0, _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4);
            float4 _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3;
            Unity_Lerp_float4(_Property_45db940379974187aa06193e4e91bf30_Out_0, _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxxx), _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3);
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_R_1 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[0];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[1];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[2];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_A_4 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[3];
            float4 _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4;
            float3 _Combine_ab70c0224251450087a230fa70578bfc_RGB_5;
            float2 _Combine_ab70c0224251450087a230fa70578bfc_RG_6;
            Unity_Combine_float(_Split_8f2f6fc780ca46de94197d1c84619bbb_R_1, _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2, _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3, float(1), _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4, _Combine_ab70c0224251450087a230fa70578bfc_RGB_5, _Combine_ab70c0224251450087a230fa70578bfc_RG_6);
            float3 _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2;
            Unity_Multiply_float3_float3(_Combine_ab70c0224251450087a230fa70578bfc_RGB_5, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxx), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2);
            float3 _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2;
            Unity_Add_float3((_Multiply_3f652e13e5644ef886115b5ec446c687_Out_2.xyz), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2, _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2);
            float3 _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1;
            Unity_Saturate_float3(_Add_ce3801671af64319ba3c39f07b4aedc0_Out_2, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1);
            float3 _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3;
            Unity_Lerp_float3(float3(1, 1, 1), _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4.xxx), _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3);
            float3 _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            Unity_Branch_float3(_Property_942d5332a122417fa73853897fe60c48_Out_0, _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3);
            float _Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0 = _Refraction_Enabled;
            float _Property_c61b272614064d2aaede0be5f876e26a_Out_0 = _Caustics_Enabled;
            float _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1);
            UnityTexture2D _Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0 = UnityBuildTexture2DStructNoScale(_Caustics_Map);
            float _Property_9940386e5105455bbb90176624ec703a_Out_0 = _Distortion_Scale;
            float _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0 = _Distortion_Speed;
            float _Property_1ad804a523494f74b670a22d24e647f8_Out_0 = _Caustics_Scale;
            float _Property_52e2043fade14631a18eeba2d115e057_Out_0 = _Caustics_Opacity;
            Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.uv0 = IN.uv0;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.TimeParameters = IN.TimeParameters;
            float4 _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1;
            SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(_Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0, _Property_9940386e5105455bbb90176624ec703a_Out_0, _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0, _Property_1ad804a523494f74b670a22d24e647f8_Out_0, _Property_52e2043fade14631a18eeba2d115e057_Out_0, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1);
            float4 _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2;
            Unity_Multiply_float4_float4((_OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1.xxxx), _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2);
            float4 _Branch_5becbaeb67464d16b337faa05512237c_Out_3;
            Unity_Branch_float4(_Property_c61b272614064d2aaede0be5f876e26a_Out_0, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2, float4(0, 0, 0, 0), _Branch_5becbaeb67464d16b337faa05512237c_Out_3);
            float4 _ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float _Comparison_8584fdc993bb469a96b47883ba133849_Out_2;
            Unity_Comparison_Less_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, float(0.1), _Comparison_8584fdc993bb469a96b47883ba133849_Out_2);
            float _Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0 = _Refraction_Strength;
            float3 _Multiply_754a12216e3d4884931fab93196a2613_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0.xxx), _Multiply_754a12216e3d4884931fab93196a2613_Out_2);
            float3 _Branch_16061ba1344840bb878837f12dff6a9f_Out_3;
            Unity_Branch_float3(_Comparison_8584fdc993bb469a96b47883ba133849_Out_2, float3(0, 0, 0), _Multiply_754a12216e3d4884931fab93196a2613_Out_2, _Branch_16061ba1344840bb878837f12dff6a9f_Out_3);
            float3 _Add_973d613c80b144f59a3d1fcb338bd611_Out_2;
            Unity_Add_float3((_ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0.xyz), _Branch_16061ba1344840bb878837f12dff6a9f_Out_3, _Add_973d613c80b144f59a3d1fcb338bd611_Out_2);
            float3 _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1;
            Unity_SceneColor_float((float4(_Add_973d613c80b144f59a3d1fcb338bd611_Out_2, 1.0)), _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1);
            float _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1);
            float3 _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2;
            Unity_Multiply_float3_float3(_SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1, (_OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1.xxx), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2);
            float3 _Add_0031381e720c46b6b4f601af8a9c6349_Out_2;
            Unity_Add_float3((_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2);
            float3 _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            Unity_Branch_float3(_Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2, (_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3);
            float _Property_5a8513df1d1248098e683c2b4b5ada98_Out_0 = _Mettalic;
            float _Property_8f9fa5bf99ce4ae8ada90e3808da920c_Out_0 = _Smoothness;
            float _Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0 = _Refraction_Enabled;
            float _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            Unity_Branch_float(_Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _Branch_79a776ac296e4440965d835189b687ba_Out_3);
            surface.BaseColor = _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            surface.NormalTS = _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            surface.Emission = _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            surface.Metallic = _Property_5a8513df1d1248098e683c2b4b5ada98_Out_0;
            surface.Smoothness = _Property_8f9fa5bf99ce4ae8ada90e3808da920c_Out_0;
            surface.Occlusion = float(1);
            surface.Alpha = _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
        
        // Render State
        Blend SrcAlpha One
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdadd_fullshadows
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD_ADD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV : INTERP0;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP1;
            #endif
             float4 tangentWS : INTERP2;
             float4 texCoord0 : INTERP3;
             float4 fogFactorAndVertexLight : INTERP4;
             float4 shadowCoord : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
             float3 viewDirectionWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.shadowCoord.xyzw = input.shadowCoord;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            output.viewDirectionWS.xyz = input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.shadowCoord = input.shadowCoord.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            output.viewDirectionWS = input.viewDirectionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Surface_Color;
        float4 _Deep_Color;
        float4 _Normal_Map_TexelSize;
        float _WaveSize;
        float2 _WaveSpeed;
        float _WaveSize2;
        float2 _WaveSpeed2;
        float _Mettalic;
        float _Smoothness;
        float _Normal_Strength;
        float _Depth_Strength;
        float4 _Caustics_Map_TexelSize;
        float _Caustics_Scale;
        float _Distortion_Scale;
        float _Distortion_Speed;
        float _Refraction_Strength;
        float _Refraction_Enabled;
        float _Foam_Speed;
        float _Foam_Noise_Scale;
        float _Foam_Noise_Amplitude;
        float _Foam_Size;
        float _Foam_Enabled;
        float _Caustics_Enabled;
        float4 _WaterTexture_TexelSize;
        float4 _WaterTexture_ST;
        float2 _Water_Texture_Movement;
        float _Water_Texture_Opacity;
        float _Caustics_Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        float _Depth_power;
        TEXTURE2D(_Caustics_Map);
        SAMPLER(sampler_Caustics_Map);
        TEXTURE2D(_WaterTexture);
        SAMPLER(sampler_WaterTexture);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(abs(A), B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        struct Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float
        {
        float3 AbsoluteWorldSpacePosition;
        float3 TimeParameters;
        };
        
        void SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(float _WaveSize, UnityTexture2D _Normal, float2 _WaveSpeed, float _WaveSize2, float2 _WaveSpeed2, float _Normal_Stranght, Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0 = _Normal;
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_A_4 = 0;
        float2 _Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0 = float2(_Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1, _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3);
        float _Property_4a9326d48476475eabddc6d02a6b6f06_Out_0 = _WaveSize;
        float2 _Property_79f9d365373e442f94e67237d36fa439_Out_0 = _WaveSpeed;
        float2 _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2;
        Unity_Multiply_float2_float2(_Property_79f9d365373e442f94e67237d36fa439_Out_0, (IN.TimeParameters.x.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2);
        float2 _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_4a9326d48476475eabddc6d02a6b6f06_Out_0.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2, _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3);
        float4 _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.tex, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.samplerstate, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.GetTransformedUV(_TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3));
        _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0);
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_R_4 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.r;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_G_5 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.g;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_B_6 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.b;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_A_7 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.a;
        UnityTexture2D _Property_3602dc36773841649ece93e40cb97791_Out_0 = _Normal;
        float _Property_b4289ec1b7944303907293e29374dd74_Out_0 = _WaveSize2;
        float2 _Property_4a9df16b1002432a9dbde8ec0432401f_Out_0 = _WaveSpeed2;
        float2 _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2;
        Unity_Multiply_float2_float2(_Property_4a9df16b1002432a9dbde8ec0432401f_Out_0, (IN.TimeParameters.x.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2);
        float2 _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_b4289ec1b7944303907293e29374dd74_Out_0.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2, _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3);
        float4 _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3602dc36773841649ece93e40cb97791_Out_0.tex, _Property_3602dc36773841649ece93e40cb97791_Out_0.samplerstate, _Property_3602dc36773841649ece93e40cb97791_Out_0.GetTransformedUV(_TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3));
        _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0);
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_R_4 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.r;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_G_5 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.g;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_B_6 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.b;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_A_7 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.a;
        float3 _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2;
        Unity_NormalBlend_float((_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.xyz), (_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.xyz), _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2);
        float _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0 = _Normal_Stranght;
        float _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2;
        Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2);
        float2 _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0 = float2(float(0), _ProjectionParams.z);
        float _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3;
        Unity_Remap_float(_Distance_e9573e7724034e4a8c25515bfdb49340_Out_2, _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0, float2 (1, 0), _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3);
        float _Power_f267dd9724c74f58953f24eee4860ba9_Out_2;
        Unity_Power_float(_Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3, float(500), _Power_f267dd9724c74f58953f24eee4860ba9_Out_2);
        float _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3;
        Unity_Lerp_float(float(0), _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0, _Power_f267dd9724c74f58953f24eee4860ba9_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3);
        float3 _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        Unity_NormalStrength_float(_NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3, _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2);
        OutVector3_1 = _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float
        {
        float4 ScreenPosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float _DepthScale, float _Depth_Streght, float _Depth_power, float3 _Normal, float _RefractionEnabled, float _Foam_Scale, float _Foam_Speed, float _Foam_Noise_Scale, float _Foam_Noise_Amplitude, float _Foam_Falloff, Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float IN, out float OutVector1_1, out float Depth_2, out float SecondFadeDepth_3, out float FoamDepth_4)
        {
        float _Property_318cdc9ecaed4eadaf06301c7076532f_Out_0 = _RefractionEnabled;
        float4 _ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float3 _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0 = _Normal;
        float3 _Add_356e75099f72430888ad16810e5d286d_Out_2;
        Unity_Add_float3((_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2);
        float3 _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3;
        Unity_Branch_float3(_Property_318cdc9ecaed4eadaf06301c7076532f_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2, (_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3);
        float _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1;
        Unity_SceneDepth_Eye_float((float4(_Branch_9e2e59e02af84dabb4377a7f18245711_Out_3, 1.0)), _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1);
        float4 _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0 = IN.ScreenPosition;
        float _Split_16d3558d6d92445a880cb5f6676de872_R_1 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[0];
        float _Split_16d3558d6d92445a880cb5f6676de872_G_2 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[1];
        float _Split_16d3558d6d92445a880cb5f6676de872_B_3 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[2];
        float _Split_16d3558d6d92445a880cb5f6676de872_A_4 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[3];
        float _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0 = _DepthScale;
        float _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2;
        Unity_Add_float(_Split_16d3558d6d92445a880cb5f6676de872_A_4, _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2);
        float _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        Unity_Subtract_float(_SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2);
        float _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2;
        Unity_Comparison_Less_float(_Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, float(0.1), _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2);
        float _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1);
        float4 _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0 = IN.ScreenPosition;
        float _Split_7d45e7abeb8e4d2a97574e613125e070_R_1 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[0];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_G_2 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[1];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_B_3 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[2];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_A_4 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[3];
        float _Property_0909716a724643ba9aa2fef403343a7d_Out_0 = _DepthScale;
        float _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2;
        Unity_Add_float(_Split_7d45e7abeb8e4d2a97574e613125e070_A_4, _Property_0909716a724643ba9aa2fef403343a7d_Out_0, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2);
        float _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2;
        Unity_Subtract_float(_SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2);
        float _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3;
        Unity_Branch_float(_Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3);
        float _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0 = _Depth_Streght;
        float _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2;
        Unity_Multiply_float_float(_Branch_ddac7cdb85fe4825bda3abac374df776_Out_3, _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0, _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2);
        float _Saturate_5cc2a092cece487983e25916a82532c4_Out_1;
        Unity_Saturate_float(_Multiply_c5e61fe354954492921110c4bf3178fd_Out_2, _Saturate_5cc2a092cece487983e25916a82532c4_Out_1);
        float _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1;
        Unity_OneMinus_float(_Saturate_5cc2a092cece487983e25916a82532c4_Out_1, _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1);
        float _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0 = _Depth_power;
        float _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2;
        Unity_Power_float(_OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1, _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0, _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2);
        float _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Unity_OneMinus_float(_Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2, _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1);
        float4 _ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1;
        Unity_SceneDepth_Eye_float(_ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0, _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1);
        float4 _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0 = IN.ScreenPosition;
        float _Split_ba379f9dd00c47e89bdaff09775abecb_R_1 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[0];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_G_2 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[1];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_B_3 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[2];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_A_4 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[3];
        float _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0 = _DepthScale;
        float _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2;
        Unity_Add_float(_Split_ba379f9dd00c47e89bdaff09775abecb_A_4, _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2);
        float _Subtract_9cdc83575a4441888b548be03402455c_Out_2;
        Unity_Subtract_float(_SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2, _Subtract_9cdc83575a4441888b548be03402455c_Out_2);
        float _Multiply_adb140a84534463c8282fcc1cf533119_Out_2;
        Unity_Multiply_float_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, 5, _Multiply_adb140a84534463c8282fcc1cf533119_Out_2);
        float _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1;
        Unity_Saturate_float(_Multiply_adb140a84534463c8282fcc1cf533119_Out_2, _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1);
        float _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1;
        Unity_OneMinus_float(_Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1, _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1);
        float _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        Unity_OneMinus_float(_OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1, _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1);
        float _Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0 = _Foam_Falloff;
        float _Negate_c1176c2567c04045a1e28135f9db2058_Out_1;
        Unity_Negate_float(_Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1);
        float _Add_df082a7d0dc44ed7947582af57d7db85_Out_2;
        Unity_Add_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1, _Add_df082a7d0dc44ed7947582af57d7db85_Out_2);
        float _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0 = _Foam_Scale;
        float _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2;
        Unity_Multiply_float_float(_Add_df082a7d0dc44ed7947582af57d7db85_Out_2, _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0, _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2);
        float _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1;
        Unity_Saturate_float(_Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2, _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1);
        float _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1;
        Unity_OneMinus_float(_Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1, _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1);
        float _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1;
        Unity_OneMinus_float(_OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1, _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1);
        float _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0 = _Foam_Speed;
        float _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0, _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2);
        float2 _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_635a6efa292d46ee852700ca8924fd35_Out_2.xx), _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3);
        float _Property_43d4265c5429441fb1d91ad7136782ad_Out_0 = _Foam_Noise_Scale;
        float _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3, _Property_43d4265c5429441fb1d91ad7136782ad_Out_0, _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2);
        float _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0 = _Foam_Noise_Amplitude;
        float _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2;
        Unity_Multiply_float_float(_SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2, _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0, _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2);
        float _Absolute_20c059810dc244fb9613bea848e93047_Out_1;
        Unity_Absolute_float(_Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2, _Absolute_20c059810dc244fb9613bea848e93047_Out_1);
        float _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2;
        Unity_Add_float(_OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1, _Absolute_20c059810dc244fb9613bea848e93047_Out_1, _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2);
        float _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        Unity_Saturate_float(_Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2, _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1);
        OutVector1_1 = _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Depth_2 = _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        SecondFadeDepth_3 = _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        FoamDepth_4 = _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float
        {
        float3 AbsoluteWorldSpacePosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(UnityTexture2D _Caustics, float _Distortion_Scale, float _Distortion_Speed, float _Caustics_Scale, float _Caustics_Opacity, Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float IN, out float4 OutVector4_1)
        {
        float _Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0 = _Caustics_Opacity;
        UnityTexture2D _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0 = _Caustics;
        float _Split_1012f2365d224feb8935e9feaa351beb_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_1012f2365d224feb8935e9feaa351beb_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_1012f2365d224feb8935e9feaa351beb_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_1012f2365d224feb8935e9feaa351beb_A_4 = 0;
        float2 _Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0 = float2(_Split_1012f2365d224feb8935e9feaa351beb_R_1, _Split_1012f2365d224feb8935e9feaa351beb_B_3);
        float _Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0 = _Caustics_Scale;
        float2 _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3;
        Unity_TilingAndOffset_float(_Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0, (_Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0.xx), float2 (0, 0), _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3);
        float _Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0 = _Distortion_Speed;
        float _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2;
        Unity_Multiply_float_float(_Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0, IN.TimeParameters.x, _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2);
        float _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1;
        Unity_Negate_float(_Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2, _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1);
        float2 _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Negate_6e0c023331f9435fa320590f00ac95d8_Out_1.xx), _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3);
        float _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0 = _Distortion_Scale;
        float _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3, _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0, _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2);
        float _Property_2cdef5d6547f40bf927ab89938223638_Out_0 = _Distortion_Speed;
        float _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2;
        Unity_Multiply_float_float(_Property_2cdef5d6547f40bf927ab89938223638_Out_0, IN.TimeParameters.x, _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2);
        float2 _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2.xx), _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3);
        float _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0 = _Distortion_Scale;
        float _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3, _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2);
        float _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3;
        Unity_Lerp_float(_SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2, float(0.5), _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3);
        float2 _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3;
        Unity_Lerp_float2(_TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3, (_Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3.xx), float2(0.4, 0.4), _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3);
        float4 _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.tex, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.samplerstate, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.GetTransformedUV(_Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3));
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_R_4 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.r;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_G_5 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.g;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_B_6 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.b;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_A_7 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.a;
        float4 _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        Unity_Multiply_float4_float4((_Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0.xxxx), _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0, _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2);
        OutVector4_1 = _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_942d5332a122417fa73853897fe60c48_Out_0 = _Foam_Enabled;
            float _Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0 = _Water_Texture_Opacity;
            UnityTexture2D _Property_c1940be719424daf973545cb452ff735_Out_0 = UnityBuildTexture2DStruct(_WaterTexture);
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_A_4 = 0;
            float2 _Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0 = float2(_Split_5a66b3eabf4247eab1df93cde1d431cc_R_1, _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3);
            float2 _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0 = _Water_Texture_Movement;
            float2 _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0, _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2);
            float2 _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3;
            Unity_TilingAndOffset_float(_Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0, float2 (1, 1), _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2, _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3);
            float4 _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c1940be719424daf973545cb452ff735_Out_0.tex, _Property_c1940be719424daf973545cb452ff735_Out_0.samplerstate, _Property_c1940be719424daf973545cb452ff735_Out_0.GetTransformedUV(_TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3));
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_R_4 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.r;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_G_5 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.g;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_B_6 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.b;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_A_7 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.a;
            float4 _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2;
            Unity_Multiply_float4_float4((_Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0.xxxx), _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0, _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2);
            float4 _Property_45db940379974187aa06193e4e91bf30_Out_0 = _Surface_Color;
            float4 _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0 = _Deep_Color;
            float _Property_f2bba435f69245e29ba364aa15a6246d_Out_0 = _Depth_Strength;
            float _Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0 = _WaveSize;
            UnityTexture2D _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0 = _WaveSpeed;
            float _Property_acee9dd3062c4febbba1a7f48505a892_Out_0 = _WaveSize2;
            float2 _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0 = _WaveSpeed2;
            float _Property_c934b87e11884ee8a832f236aeb6496d_Out_0 = _Normal_Strength;
            Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.TimeParameters = IN.TimeParameters;
            float3 _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(_Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0, _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0, _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0, _Property_acee9dd3062c4febbba1a7f48505a892_Out_0, _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0, _Property_c934b87e11884ee8a832f236aeb6496d_Out_0, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1);
            float _Property_334955ba786b43dc8b8b69068b22e167_Out_0 = _Refraction_Strength;
            float3 _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_334955ba786b43dc8b8b69068b22e167_Out_0.xxx), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2);
            float _Property_004ca3e6203d4184986681a4527c2e63_Out_0 = _Refraction_Enabled;
            float _Property_347e4eac494e4fe6892b846c0efc2313_Out_0 = _Foam_Speed;
            float _Property_dcb74838243b4512aa30f059bfa6798b_Out_0 = _Foam_Noise_Scale;
            float _Property_760c8cbb4aba427f8e610388fe099157_Out_0 = _Foam_Noise_Amplitude;
            float _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0 = _Foam_Size;
            Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float _DepthFade_d12ba53613cd41a2b21fcc4c74833226;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.ScreenPosition = IN.ScreenPosition;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.uv0 = IN.uv0;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.TimeParameters = IN.TimeParameters;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4;
            SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float(0), _Property_f2bba435f69245e29ba364aa15a6246d_Out_0, float(4), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2, _Property_004ca3e6203d4184986681a4527c2e63_Out_0, float(1), _Property_347e4eac494e4fe6892b846c0efc2313_Out_0, _Property_dcb74838243b4512aa30f059bfa6798b_Out_0, _Property_760c8cbb4aba427f8e610388fe099157_Out_0, _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4);
            float4 _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3;
            Unity_Lerp_float4(_Property_45db940379974187aa06193e4e91bf30_Out_0, _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxxx), _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3);
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_R_1 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[0];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[1];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[2];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_A_4 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[3];
            float4 _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4;
            float3 _Combine_ab70c0224251450087a230fa70578bfc_RGB_5;
            float2 _Combine_ab70c0224251450087a230fa70578bfc_RG_6;
            Unity_Combine_float(_Split_8f2f6fc780ca46de94197d1c84619bbb_R_1, _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2, _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3, float(1), _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4, _Combine_ab70c0224251450087a230fa70578bfc_RGB_5, _Combine_ab70c0224251450087a230fa70578bfc_RG_6);
            float3 _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2;
            Unity_Multiply_float3_float3(_Combine_ab70c0224251450087a230fa70578bfc_RGB_5, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxx), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2);
            float3 _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2;
            Unity_Add_float3((_Multiply_3f652e13e5644ef886115b5ec446c687_Out_2.xyz), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2, _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2);
            float3 _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1;
            Unity_Saturate_float3(_Add_ce3801671af64319ba3c39f07b4aedc0_Out_2, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1);
            float3 _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3;
            Unity_Lerp_float3(float3(1, 1, 1), _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4.xxx), _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3);
            float3 _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            Unity_Branch_float3(_Property_942d5332a122417fa73853897fe60c48_Out_0, _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3);
            float _Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0 = _Refraction_Enabled;
            float _Property_c61b272614064d2aaede0be5f876e26a_Out_0 = _Caustics_Enabled;
            float _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1);
            UnityTexture2D _Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0 = UnityBuildTexture2DStructNoScale(_Caustics_Map);
            float _Property_9940386e5105455bbb90176624ec703a_Out_0 = _Distortion_Scale;
            float _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0 = _Distortion_Speed;
            float _Property_1ad804a523494f74b670a22d24e647f8_Out_0 = _Caustics_Scale;
            float _Property_52e2043fade14631a18eeba2d115e057_Out_0 = _Caustics_Opacity;
            Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.uv0 = IN.uv0;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.TimeParameters = IN.TimeParameters;
            float4 _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1;
            SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(_Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0, _Property_9940386e5105455bbb90176624ec703a_Out_0, _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0, _Property_1ad804a523494f74b670a22d24e647f8_Out_0, _Property_52e2043fade14631a18eeba2d115e057_Out_0, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1);
            float4 _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2;
            Unity_Multiply_float4_float4((_OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1.xxxx), _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2);
            float4 _Branch_5becbaeb67464d16b337faa05512237c_Out_3;
            Unity_Branch_float4(_Property_c61b272614064d2aaede0be5f876e26a_Out_0, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2, float4(0, 0, 0, 0), _Branch_5becbaeb67464d16b337faa05512237c_Out_3);
            float4 _ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float _Comparison_8584fdc993bb469a96b47883ba133849_Out_2;
            Unity_Comparison_Less_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, float(0.1), _Comparison_8584fdc993bb469a96b47883ba133849_Out_2);
            float _Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0 = _Refraction_Strength;
            float3 _Multiply_754a12216e3d4884931fab93196a2613_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0.xxx), _Multiply_754a12216e3d4884931fab93196a2613_Out_2);
            float3 _Branch_16061ba1344840bb878837f12dff6a9f_Out_3;
            Unity_Branch_float3(_Comparison_8584fdc993bb469a96b47883ba133849_Out_2, float3(0, 0, 0), _Multiply_754a12216e3d4884931fab93196a2613_Out_2, _Branch_16061ba1344840bb878837f12dff6a9f_Out_3);
            float3 _Add_973d613c80b144f59a3d1fcb338bd611_Out_2;
            Unity_Add_float3((_ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0.xyz), _Branch_16061ba1344840bb878837f12dff6a9f_Out_3, _Add_973d613c80b144f59a3d1fcb338bd611_Out_2);
            float3 _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1;
            Unity_SceneColor_float((float4(_Add_973d613c80b144f59a3d1fcb338bd611_Out_2, 1.0)), _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1);
            float _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1);
            float3 _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2;
            Unity_Multiply_float3_float3(_SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1, (_OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1.xxx), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2);
            float3 _Add_0031381e720c46b6b4f601af8a9c6349_Out_2;
            Unity_Add_float3((_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2);
            float3 _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            Unity_Branch_float3(_Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2, (_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3);
            float _Property_5a8513df1d1248098e683c2b4b5ada98_Out_0 = _Mettalic;
            float _Property_8f9fa5bf99ce4ae8ada90e3808da920c_Out_0 = _Smoothness;
            float _Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0 = _Refraction_Enabled;
            float _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            Unity_Branch_float(_Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _Branch_79a776ac296e4440965d835189b687ba_Out_3);
            surface.BaseColor = _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            surface.NormalTS = _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            surface.Emission = _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            surface.Metallic = _Property_5a8513df1d1248098e683c2b4b5ada98_Out_0;
            surface.Smoothness = _Property_8f9fa5bf99ce4ae8ada90e3808da920c_Out_0;
            surface.Occlusion = float(1);
            surface.Alpha = _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn Deferred"
            Tags
            {
                "LightMode" = "Deferred"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma multi_compile_instancing
        #pragma exclude_renderers nomrt
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEFERRED
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV : INTERP0;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP1;
            #endif
             float4 tangentWS : INTERP2;
             float4 texCoord0 : INTERP3;
             float4 fogFactorAndVertexLight : INTERP4;
             float4 shadowCoord : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
             float3 viewDirectionWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.shadowCoord.xyzw = input.shadowCoord;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            output.viewDirectionWS.xyz = input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.shadowCoord = input.shadowCoord.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            output.viewDirectionWS = input.viewDirectionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Surface_Color;
        float4 _Deep_Color;
        float4 _Normal_Map_TexelSize;
        float _WaveSize;
        float2 _WaveSpeed;
        float _WaveSize2;
        float2 _WaveSpeed2;
        float _Mettalic;
        float _Smoothness;
        float _Normal_Strength;
        float _Depth_Strength;
        float4 _Caustics_Map_TexelSize;
        float _Caustics_Scale;
        float _Distortion_Scale;
        float _Distortion_Speed;
        float _Refraction_Strength;
        float _Refraction_Enabled;
        float _Foam_Speed;
        float _Foam_Noise_Scale;
        float _Foam_Noise_Amplitude;
        float _Foam_Size;
        float _Foam_Enabled;
        float _Caustics_Enabled;
        float4 _WaterTexture_TexelSize;
        float4 _WaterTexture_ST;
        float2 _Water_Texture_Movement;
        float _Water_Texture_Opacity;
        float _Caustics_Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        float _Depth_power;
        TEXTURE2D(_Caustics_Map);
        SAMPLER(sampler_Caustics_Map);
        TEXTURE2D(_WaterTexture);
        SAMPLER(sampler_WaterTexture);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(abs(A), B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        struct Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float
        {
        float3 AbsoluteWorldSpacePosition;
        float3 TimeParameters;
        };
        
        void SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(float _WaveSize, UnityTexture2D _Normal, float2 _WaveSpeed, float _WaveSize2, float2 _WaveSpeed2, float _Normal_Stranght, Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0 = _Normal;
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_A_4 = 0;
        float2 _Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0 = float2(_Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1, _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3);
        float _Property_4a9326d48476475eabddc6d02a6b6f06_Out_0 = _WaveSize;
        float2 _Property_79f9d365373e442f94e67237d36fa439_Out_0 = _WaveSpeed;
        float2 _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2;
        Unity_Multiply_float2_float2(_Property_79f9d365373e442f94e67237d36fa439_Out_0, (IN.TimeParameters.x.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2);
        float2 _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_4a9326d48476475eabddc6d02a6b6f06_Out_0.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2, _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3);
        float4 _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.tex, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.samplerstate, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.GetTransformedUV(_TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3));
        _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0);
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_R_4 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.r;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_G_5 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.g;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_B_6 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.b;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_A_7 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.a;
        UnityTexture2D _Property_3602dc36773841649ece93e40cb97791_Out_0 = _Normal;
        float _Property_b4289ec1b7944303907293e29374dd74_Out_0 = _WaveSize2;
        float2 _Property_4a9df16b1002432a9dbde8ec0432401f_Out_0 = _WaveSpeed2;
        float2 _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2;
        Unity_Multiply_float2_float2(_Property_4a9df16b1002432a9dbde8ec0432401f_Out_0, (IN.TimeParameters.x.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2);
        float2 _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_b4289ec1b7944303907293e29374dd74_Out_0.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2, _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3);
        float4 _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3602dc36773841649ece93e40cb97791_Out_0.tex, _Property_3602dc36773841649ece93e40cb97791_Out_0.samplerstate, _Property_3602dc36773841649ece93e40cb97791_Out_0.GetTransformedUV(_TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3));
        _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0);
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_R_4 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.r;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_G_5 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.g;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_B_6 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.b;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_A_7 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.a;
        float3 _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2;
        Unity_NormalBlend_float((_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.xyz), (_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.xyz), _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2);
        float _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0 = _Normal_Stranght;
        float _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2;
        Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2);
        float2 _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0 = float2(float(0), _ProjectionParams.z);
        float _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3;
        Unity_Remap_float(_Distance_e9573e7724034e4a8c25515bfdb49340_Out_2, _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0, float2 (1, 0), _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3);
        float _Power_f267dd9724c74f58953f24eee4860ba9_Out_2;
        Unity_Power_float(_Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3, float(500), _Power_f267dd9724c74f58953f24eee4860ba9_Out_2);
        float _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3;
        Unity_Lerp_float(float(0), _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0, _Power_f267dd9724c74f58953f24eee4860ba9_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3);
        float3 _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        Unity_NormalStrength_float(_NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3, _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2);
        OutVector3_1 = _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float
        {
        float4 ScreenPosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float _DepthScale, float _Depth_Streght, float _Depth_power, float3 _Normal, float _RefractionEnabled, float _Foam_Scale, float _Foam_Speed, float _Foam_Noise_Scale, float _Foam_Noise_Amplitude, float _Foam_Falloff, Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float IN, out float OutVector1_1, out float Depth_2, out float SecondFadeDepth_3, out float FoamDepth_4)
        {
        float _Property_318cdc9ecaed4eadaf06301c7076532f_Out_0 = _RefractionEnabled;
        float4 _ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float3 _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0 = _Normal;
        float3 _Add_356e75099f72430888ad16810e5d286d_Out_2;
        Unity_Add_float3((_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2);
        float3 _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3;
        Unity_Branch_float3(_Property_318cdc9ecaed4eadaf06301c7076532f_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2, (_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3);
        float _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1;
        Unity_SceneDepth_Eye_float((float4(_Branch_9e2e59e02af84dabb4377a7f18245711_Out_3, 1.0)), _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1);
        float4 _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0 = IN.ScreenPosition;
        float _Split_16d3558d6d92445a880cb5f6676de872_R_1 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[0];
        float _Split_16d3558d6d92445a880cb5f6676de872_G_2 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[1];
        float _Split_16d3558d6d92445a880cb5f6676de872_B_3 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[2];
        float _Split_16d3558d6d92445a880cb5f6676de872_A_4 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[3];
        float _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0 = _DepthScale;
        float _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2;
        Unity_Add_float(_Split_16d3558d6d92445a880cb5f6676de872_A_4, _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2);
        float _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        Unity_Subtract_float(_SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2);
        float _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2;
        Unity_Comparison_Less_float(_Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, float(0.1), _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2);
        float _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1);
        float4 _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0 = IN.ScreenPosition;
        float _Split_7d45e7abeb8e4d2a97574e613125e070_R_1 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[0];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_G_2 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[1];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_B_3 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[2];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_A_4 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[3];
        float _Property_0909716a724643ba9aa2fef403343a7d_Out_0 = _DepthScale;
        float _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2;
        Unity_Add_float(_Split_7d45e7abeb8e4d2a97574e613125e070_A_4, _Property_0909716a724643ba9aa2fef403343a7d_Out_0, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2);
        float _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2;
        Unity_Subtract_float(_SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2);
        float _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3;
        Unity_Branch_float(_Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3);
        float _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0 = _Depth_Streght;
        float _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2;
        Unity_Multiply_float_float(_Branch_ddac7cdb85fe4825bda3abac374df776_Out_3, _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0, _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2);
        float _Saturate_5cc2a092cece487983e25916a82532c4_Out_1;
        Unity_Saturate_float(_Multiply_c5e61fe354954492921110c4bf3178fd_Out_2, _Saturate_5cc2a092cece487983e25916a82532c4_Out_1);
        float _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1;
        Unity_OneMinus_float(_Saturate_5cc2a092cece487983e25916a82532c4_Out_1, _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1);
        float _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0 = _Depth_power;
        float _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2;
        Unity_Power_float(_OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1, _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0, _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2);
        float _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Unity_OneMinus_float(_Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2, _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1);
        float4 _ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1;
        Unity_SceneDepth_Eye_float(_ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0, _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1);
        float4 _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0 = IN.ScreenPosition;
        float _Split_ba379f9dd00c47e89bdaff09775abecb_R_1 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[0];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_G_2 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[1];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_B_3 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[2];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_A_4 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[3];
        float _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0 = _DepthScale;
        float _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2;
        Unity_Add_float(_Split_ba379f9dd00c47e89bdaff09775abecb_A_4, _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2);
        float _Subtract_9cdc83575a4441888b548be03402455c_Out_2;
        Unity_Subtract_float(_SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2, _Subtract_9cdc83575a4441888b548be03402455c_Out_2);
        float _Multiply_adb140a84534463c8282fcc1cf533119_Out_2;
        Unity_Multiply_float_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, 5, _Multiply_adb140a84534463c8282fcc1cf533119_Out_2);
        float _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1;
        Unity_Saturate_float(_Multiply_adb140a84534463c8282fcc1cf533119_Out_2, _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1);
        float _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1;
        Unity_OneMinus_float(_Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1, _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1);
        float _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        Unity_OneMinus_float(_OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1, _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1);
        float _Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0 = _Foam_Falloff;
        float _Negate_c1176c2567c04045a1e28135f9db2058_Out_1;
        Unity_Negate_float(_Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1);
        float _Add_df082a7d0dc44ed7947582af57d7db85_Out_2;
        Unity_Add_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1, _Add_df082a7d0dc44ed7947582af57d7db85_Out_2);
        float _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0 = _Foam_Scale;
        float _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2;
        Unity_Multiply_float_float(_Add_df082a7d0dc44ed7947582af57d7db85_Out_2, _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0, _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2);
        float _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1;
        Unity_Saturate_float(_Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2, _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1);
        float _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1;
        Unity_OneMinus_float(_Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1, _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1);
        float _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1;
        Unity_OneMinus_float(_OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1, _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1);
        float _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0 = _Foam_Speed;
        float _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0, _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2);
        float2 _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_635a6efa292d46ee852700ca8924fd35_Out_2.xx), _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3);
        float _Property_43d4265c5429441fb1d91ad7136782ad_Out_0 = _Foam_Noise_Scale;
        float _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3, _Property_43d4265c5429441fb1d91ad7136782ad_Out_0, _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2);
        float _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0 = _Foam_Noise_Amplitude;
        float _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2;
        Unity_Multiply_float_float(_SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2, _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0, _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2);
        float _Absolute_20c059810dc244fb9613bea848e93047_Out_1;
        Unity_Absolute_float(_Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2, _Absolute_20c059810dc244fb9613bea848e93047_Out_1);
        float _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2;
        Unity_Add_float(_OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1, _Absolute_20c059810dc244fb9613bea848e93047_Out_1, _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2);
        float _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        Unity_Saturate_float(_Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2, _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1);
        OutVector1_1 = _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Depth_2 = _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        SecondFadeDepth_3 = _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        FoamDepth_4 = _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float
        {
        float3 AbsoluteWorldSpacePosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(UnityTexture2D _Caustics, float _Distortion_Scale, float _Distortion_Speed, float _Caustics_Scale, float _Caustics_Opacity, Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float IN, out float4 OutVector4_1)
        {
        float _Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0 = _Caustics_Opacity;
        UnityTexture2D _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0 = _Caustics;
        float _Split_1012f2365d224feb8935e9feaa351beb_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_1012f2365d224feb8935e9feaa351beb_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_1012f2365d224feb8935e9feaa351beb_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_1012f2365d224feb8935e9feaa351beb_A_4 = 0;
        float2 _Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0 = float2(_Split_1012f2365d224feb8935e9feaa351beb_R_1, _Split_1012f2365d224feb8935e9feaa351beb_B_3);
        float _Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0 = _Caustics_Scale;
        float2 _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3;
        Unity_TilingAndOffset_float(_Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0, (_Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0.xx), float2 (0, 0), _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3);
        float _Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0 = _Distortion_Speed;
        float _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2;
        Unity_Multiply_float_float(_Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0, IN.TimeParameters.x, _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2);
        float _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1;
        Unity_Negate_float(_Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2, _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1);
        float2 _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Negate_6e0c023331f9435fa320590f00ac95d8_Out_1.xx), _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3);
        float _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0 = _Distortion_Scale;
        float _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3, _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0, _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2);
        float _Property_2cdef5d6547f40bf927ab89938223638_Out_0 = _Distortion_Speed;
        float _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2;
        Unity_Multiply_float_float(_Property_2cdef5d6547f40bf927ab89938223638_Out_0, IN.TimeParameters.x, _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2);
        float2 _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2.xx), _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3);
        float _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0 = _Distortion_Scale;
        float _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3, _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2);
        float _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3;
        Unity_Lerp_float(_SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2, float(0.5), _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3);
        float2 _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3;
        Unity_Lerp_float2(_TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3, (_Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3.xx), float2(0.4, 0.4), _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3);
        float4 _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.tex, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.samplerstate, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.GetTransformedUV(_Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3));
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_R_4 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.r;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_G_5 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.g;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_B_6 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.b;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_A_7 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.a;
        float4 _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        Unity_Multiply_float4_float4((_Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0.xxxx), _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0, _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2);
        OutVector4_1 = _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_942d5332a122417fa73853897fe60c48_Out_0 = _Foam_Enabled;
            float _Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0 = _Water_Texture_Opacity;
            UnityTexture2D _Property_c1940be719424daf973545cb452ff735_Out_0 = UnityBuildTexture2DStruct(_WaterTexture);
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_A_4 = 0;
            float2 _Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0 = float2(_Split_5a66b3eabf4247eab1df93cde1d431cc_R_1, _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3);
            float2 _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0 = _Water_Texture_Movement;
            float2 _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0, _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2);
            float2 _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3;
            Unity_TilingAndOffset_float(_Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0, float2 (1, 1), _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2, _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3);
            float4 _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c1940be719424daf973545cb452ff735_Out_0.tex, _Property_c1940be719424daf973545cb452ff735_Out_0.samplerstate, _Property_c1940be719424daf973545cb452ff735_Out_0.GetTransformedUV(_TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3));
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_R_4 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.r;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_G_5 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.g;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_B_6 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.b;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_A_7 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.a;
            float4 _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2;
            Unity_Multiply_float4_float4((_Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0.xxxx), _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0, _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2);
            float4 _Property_45db940379974187aa06193e4e91bf30_Out_0 = _Surface_Color;
            float4 _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0 = _Deep_Color;
            float _Property_f2bba435f69245e29ba364aa15a6246d_Out_0 = _Depth_Strength;
            float _Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0 = _WaveSize;
            UnityTexture2D _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0 = _WaveSpeed;
            float _Property_acee9dd3062c4febbba1a7f48505a892_Out_0 = _WaveSize2;
            float2 _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0 = _WaveSpeed2;
            float _Property_c934b87e11884ee8a832f236aeb6496d_Out_0 = _Normal_Strength;
            Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.TimeParameters = IN.TimeParameters;
            float3 _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(_Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0, _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0, _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0, _Property_acee9dd3062c4febbba1a7f48505a892_Out_0, _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0, _Property_c934b87e11884ee8a832f236aeb6496d_Out_0, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1);
            float _Property_334955ba786b43dc8b8b69068b22e167_Out_0 = _Refraction_Strength;
            float3 _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_334955ba786b43dc8b8b69068b22e167_Out_0.xxx), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2);
            float _Property_004ca3e6203d4184986681a4527c2e63_Out_0 = _Refraction_Enabled;
            float _Property_347e4eac494e4fe6892b846c0efc2313_Out_0 = _Foam_Speed;
            float _Property_dcb74838243b4512aa30f059bfa6798b_Out_0 = _Foam_Noise_Scale;
            float _Property_760c8cbb4aba427f8e610388fe099157_Out_0 = _Foam_Noise_Amplitude;
            float _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0 = _Foam_Size;
            Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float _DepthFade_d12ba53613cd41a2b21fcc4c74833226;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.ScreenPosition = IN.ScreenPosition;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.uv0 = IN.uv0;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.TimeParameters = IN.TimeParameters;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4;
            SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float(0), _Property_f2bba435f69245e29ba364aa15a6246d_Out_0, float(4), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2, _Property_004ca3e6203d4184986681a4527c2e63_Out_0, float(1), _Property_347e4eac494e4fe6892b846c0efc2313_Out_0, _Property_dcb74838243b4512aa30f059bfa6798b_Out_0, _Property_760c8cbb4aba427f8e610388fe099157_Out_0, _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4);
            float4 _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3;
            Unity_Lerp_float4(_Property_45db940379974187aa06193e4e91bf30_Out_0, _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxxx), _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3);
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_R_1 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[0];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[1];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[2];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_A_4 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[3];
            float4 _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4;
            float3 _Combine_ab70c0224251450087a230fa70578bfc_RGB_5;
            float2 _Combine_ab70c0224251450087a230fa70578bfc_RG_6;
            Unity_Combine_float(_Split_8f2f6fc780ca46de94197d1c84619bbb_R_1, _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2, _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3, float(1), _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4, _Combine_ab70c0224251450087a230fa70578bfc_RGB_5, _Combine_ab70c0224251450087a230fa70578bfc_RG_6);
            float3 _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2;
            Unity_Multiply_float3_float3(_Combine_ab70c0224251450087a230fa70578bfc_RGB_5, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxx), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2);
            float3 _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2;
            Unity_Add_float3((_Multiply_3f652e13e5644ef886115b5ec446c687_Out_2.xyz), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2, _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2);
            float3 _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1;
            Unity_Saturate_float3(_Add_ce3801671af64319ba3c39f07b4aedc0_Out_2, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1);
            float3 _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3;
            Unity_Lerp_float3(float3(1, 1, 1), _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4.xxx), _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3);
            float3 _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            Unity_Branch_float3(_Property_942d5332a122417fa73853897fe60c48_Out_0, _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3);
            float _Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0 = _Refraction_Enabled;
            float _Property_c61b272614064d2aaede0be5f876e26a_Out_0 = _Caustics_Enabled;
            float _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1);
            UnityTexture2D _Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0 = UnityBuildTexture2DStructNoScale(_Caustics_Map);
            float _Property_9940386e5105455bbb90176624ec703a_Out_0 = _Distortion_Scale;
            float _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0 = _Distortion_Speed;
            float _Property_1ad804a523494f74b670a22d24e647f8_Out_0 = _Caustics_Scale;
            float _Property_52e2043fade14631a18eeba2d115e057_Out_0 = _Caustics_Opacity;
            Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.uv0 = IN.uv0;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.TimeParameters = IN.TimeParameters;
            float4 _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1;
            SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(_Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0, _Property_9940386e5105455bbb90176624ec703a_Out_0, _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0, _Property_1ad804a523494f74b670a22d24e647f8_Out_0, _Property_52e2043fade14631a18eeba2d115e057_Out_0, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1);
            float4 _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2;
            Unity_Multiply_float4_float4((_OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1.xxxx), _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2);
            float4 _Branch_5becbaeb67464d16b337faa05512237c_Out_3;
            Unity_Branch_float4(_Property_c61b272614064d2aaede0be5f876e26a_Out_0, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2, float4(0, 0, 0, 0), _Branch_5becbaeb67464d16b337faa05512237c_Out_3);
            float4 _ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float _Comparison_8584fdc993bb469a96b47883ba133849_Out_2;
            Unity_Comparison_Less_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, float(0.1), _Comparison_8584fdc993bb469a96b47883ba133849_Out_2);
            float _Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0 = _Refraction_Strength;
            float3 _Multiply_754a12216e3d4884931fab93196a2613_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0.xxx), _Multiply_754a12216e3d4884931fab93196a2613_Out_2);
            float3 _Branch_16061ba1344840bb878837f12dff6a9f_Out_3;
            Unity_Branch_float3(_Comparison_8584fdc993bb469a96b47883ba133849_Out_2, float3(0, 0, 0), _Multiply_754a12216e3d4884931fab93196a2613_Out_2, _Branch_16061ba1344840bb878837f12dff6a9f_Out_3);
            float3 _Add_973d613c80b144f59a3d1fcb338bd611_Out_2;
            Unity_Add_float3((_ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0.xyz), _Branch_16061ba1344840bb878837f12dff6a9f_Out_3, _Add_973d613c80b144f59a3d1fcb338bd611_Out_2);
            float3 _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1;
            Unity_SceneColor_float((float4(_Add_973d613c80b144f59a3d1fcb338bd611_Out_2, 1.0)), _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1);
            float _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1);
            float3 _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2;
            Unity_Multiply_float3_float3(_SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1, (_OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1.xxx), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2);
            float3 _Add_0031381e720c46b6b4f601af8a9c6349_Out_2;
            Unity_Add_float3((_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2);
            float3 _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            Unity_Branch_float3(_Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2, (_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3);
            float _Property_5a8513df1d1248098e683c2b4b5ada98_Out_0 = _Mettalic;
            float _Property_8f9fa5bf99ce4ae8ada90e3808da920c_Out_0 = _Smoothness;
            float _Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0 = _Refraction_Enabled;
            float _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            Unity_Branch_float(_Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _Branch_79a776ac296e4440965d835189b687ba_Out_3);
            surface.BaseColor = _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            surface.NormalTS = _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            surface.Emission = _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            surface.Metallic = _Property_5a8513df1d1248098e683c2b4b5ada98_Out_0;
            surface.Smoothness = _Property_8f9fa5bf99ce4ae8ada90e3808da920c_Out_0;
            surface.Occlusion = float(1);
            surface.Alpha = _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_shadowcaster
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Surface_Color;
        float4 _Deep_Color;
        float4 _Normal_Map_TexelSize;
        float _WaveSize;
        float2 _WaveSpeed;
        float _WaveSize2;
        float2 _WaveSpeed2;
        float _Mettalic;
        float _Smoothness;
        float _Normal_Strength;
        float _Depth_Strength;
        float4 _Caustics_Map_TexelSize;
        float _Caustics_Scale;
        float _Distortion_Scale;
        float _Distortion_Speed;
        float _Refraction_Strength;
        float _Refraction_Enabled;
        float _Foam_Speed;
        float _Foam_Noise_Scale;
        float _Foam_Noise_Amplitude;
        float _Foam_Size;
        float _Foam_Enabled;
        float _Caustics_Enabled;
        float4 _WaterTexture_TexelSize;
        float4 _WaterTexture_ST;
        float2 _Water_Texture_Movement;
        float _Water_Texture_Opacity;
        float _Caustics_Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        float _Depth_power;
        TEXTURE2D(_Caustics_Map);
        SAMPLER(sampler_Caustics_Map);
        TEXTURE2D(_WaterTexture);
        SAMPLER(sampler_WaterTexture);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(abs(A), B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        struct Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float
        {
        float3 AbsoluteWorldSpacePosition;
        float3 TimeParameters;
        };
        
        void SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(float _WaveSize, UnityTexture2D _Normal, float2 _WaveSpeed, float _WaveSize2, float2 _WaveSpeed2, float _Normal_Stranght, Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0 = _Normal;
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_A_4 = 0;
        float2 _Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0 = float2(_Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1, _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3);
        float _Property_4a9326d48476475eabddc6d02a6b6f06_Out_0 = _WaveSize;
        float2 _Property_79f9d365373e442f94e67237d36fa439_Out_0 = _WaveSpeed;
        float2 _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2;
        Unity_Multiply_float2_float2(_Property_79f9d365373e442f94e67237d36fa439_Out_0, (IN.TimeParameters.x.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2);
        float2 _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_4a9326d48476475eabddc6d02a6b6f06_Out_0.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2, _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3);
        float4 _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.tex, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.samplerstate, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.GetTransformedUV(_TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3));
        _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0);
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_R_4 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.r;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_G_5 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.g;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_B_6 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.b;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_A_7 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.a;
        UnityTexture2D _Property_3602dc36773841649ece93e40cb97791_Out_0 = _Normal;
        float _Property_b4289ec1b7944303907293e29374dd74_Out_0 = _WaveSize2;
        float2 _Property_4a9df16b1002432a9dbde8ec0432401f_Out_0 = _WaveSpeed2;
        float2 _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2;
        Unity_Multiply_float2_float2(_Property_4a9df16b1002432a9dbde8ec0432401f_Out_0, (IN.TimeParameters.x.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2);
        float2 _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_b4289ec1b7944303907293e29374dd74_Out_0.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2, _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3);
        float4 _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3602dc36773841649ece93e40cb97791_Out_0.tex, _Property_3602dc36773841649ece93e40cb97791_Out_0.samplerstate, _Property_3602dc36773841649ece93e40cb97791_Out_0.GetTransformedUV(_TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3));
        _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0);
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_R_4 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.r;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_G_5 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.g;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_B_6 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.b;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_A_7 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.a;
        float3 _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2;
        Unity_NormalBlend_float((_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.xyz), (_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.xyz), _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2);
        float _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0 = _Normal_Stranght;
        float _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2;
        Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2);
        float2 _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0 = float2(float(0), _ProjectionParams.z);
        float _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3;
        Unity_Remap_float(_Distance_e9573e7724034e4a8c25515bfdb49340_Out_2, _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0, float2 (1, 0), _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3);
        float _Power_f267dd9724c74f58953f24eee4860ba9_Out_2;
        Unity_Power_float(_Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3, float(500), _Power_f267dd9724c74f58953f24eee4860ba9_Out_2);
        float _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3;
        Unity_Lerp_float(float(0), _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0, _Power_f267dd9724c74f58953f24eee4860ba9_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3);
        float3 _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        Unity_NormalStrength_float(_NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3, _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2);
        OutVector3_1 = _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float
        {
        float4 ScreenPosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float _DepthScale, float _Depth_Streght, float _Depth_power, float3 _Normal, float _RefractionEnabled, float _Foam_Scale, float _Foam_Speed, float _Foam_Noise_Scale, float _Foam_Noise_Amplitude, float _Foam_Falloff, Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float IN, out float OutVector1_1, out float Depth_2, out float SecondFadeDepth_3, out float FoamDepth_4)
        {
        float _Property_318cdc9ecaed4eadaf06301c7076532f_Out_0 = _RefractionEnabled;
        float4 _ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float3 _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0 = _Normal;
        float3 _Add_356e75099f72430888ad16810e5d286d_Out_2;
        Unity_Add_float3((_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2);
        float3 _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3;
        Unity_Branch_float3(_Property_318cdc9ecaed4eadaf06301c7076532f_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2, (_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3);
        float _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1;
        Unity_SceneDepth_Eye_float((float4(_Branch_9e2e59e02af84dabb4377a7f18245711_Out_3, 1.0)), _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1);
        float4 _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0 = IN.ScreenPosition;
        float _Split_16d3558d6d92445a880cb5f6676de872_R_1 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[0];
        float _Split_16d3558d6d92445a880cb5f6676de872_G_2 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[1];
        float _Split_16d3558d6d92445a880cb5f6676de872_B_3 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[2];
        float _Split_16d3558d6d92445a880cb5f6676de872_A_4 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[3];
        float _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0 = _DepthScale;
        float _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2;
        Unity_Add_float(_Split_16d3558d6d92445a880cb5f6676de872_A_4, _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2);
        float _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        Unity_Subtract_float(_SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2);
        float _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2;
        Unity_Comparison_Less_float(_Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, float(0.1), _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2);
        float _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1);
        float4 _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0 = IN.ScreenPosition;
        float _Split_7d45e7abeb8e4d2a97574e613125e070_R_1 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[0];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_G_2 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[1];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_B_3 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[2];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_A_4 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[3];
        float _Property_0909716a724643ba9aa2fef403343a7d_Out_0 = _DepthScale;
        float _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2;
        Unity_Add_float(_Split_7d45e7abeb8e4d2a97574e613125e070_A_4, _Property_0909716a724643ba9aa2fef403343a7d_Out_0, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2);
        float _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2;
        Unity_Subtract_float(_SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2);
        float _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3;
        Unity_Branch_float(_Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3);
        float _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0 = _Depth_Streght;
        float _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2;
        Unity_Multiply_float_float(_Branch_ddac7cdb85fe4825bda3abac374df776_Out_3, _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0, _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2);
        float _Saturate_5cc2a092cece487983e25916a82532c4_Out_1;
        Unity_Saturate_float(_Multiply_c5e61fe354954492921110c4bf3178fd_Out_2, _Saturate_5cc2a092cece487983e25916a82532c4_Out_1);
        float _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1;
        Unity_OneMinus_float(_Saturate_5cc2a092cece487983e25916a82532c4_Out_1, _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1);
        float _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0 = _Depth_power;
        float _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2;
        Unity_Power_float(_OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1, _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0, _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2);
        float _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Unity_OneMinus_float(_Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2, _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1);
        float4 _ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1;
        Unity_SceneDepth_Eye_float(_ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0, _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1);
        float4 _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0 = IN.ScreenPosition;
        float _Split_ba379f9dd00c47e89bdaff09775abecb_R_1 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[0];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_G_2 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[1];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_B_3 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[2];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_A_4 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[3];
        float _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0 = _DepthScale;
        float _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2;
        Unity_Add_float(_Split_ba379f9dd00c47e89bdaff09775abecb_A_4, _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2);
        float _Subtract_9cdc83575a4441888b548be03402455c_Out_2;
        Unity_Subtract_float(_SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2, _Subtract_9cdc83575a4441888b548be03402455c_Out_2);
        float _Multiply_adb140a84534463c8282fcc1cf533119_Out_2;
        Unity_Multiply_float_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, 5, _Multiply_adb140a84534463c8282fcc1cf533119_Out_2);
        float _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1;
        Unity_Saturate_float(_Multiply_adb140a84534463c8282fcc1cf533119_Out_2, _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1);
        float _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1;
        Unity_OneMinus_float(_Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1, _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1);
        float _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        Unity_OneMinus_float(_OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1, _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1);
        float _Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0 = _Foam_Falloff;
        float _Negate_c1176c2567c04045a1e28135f9db2058_Out_1;
        Unity_Negate_float(_Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1);
        float _Add_df082a7d0dc44ed7947582af57d7db85_Out_2;
        Unity_Add_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1, _Add_df082a7d0dc44ed7947582af57d7db85_Out_2);
        float _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0 = _Foam_Scale;
        float _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2;
        Unity_Multiply_float_float(_Add_df082a7d0dc44ed7947582af57d7db85_Out_2, _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0, _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2);
        float _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1;
        Unity_Saturate_float(_Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2, _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1);
        float _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1;
        Unity_OneMinus_float(_Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1, _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1);
        float _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1;
        Unity_OneMinus_float(_OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1, _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1);
        float _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0 = _Foam_Speed;
        float _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0, _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2);
        float2 _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_635a6efa292d46ee852700ca8924fd35_Out_2.xx), _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3);
        float _Property_43d4265c5429441fb1d91ad7136782ad_Out_0 = _Foam_Noise_Scale;
        float _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3, _Property_43d4265c5429441fb1d91ad7136782ad_Out_0, _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2);
        float _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0 = _Foam_Noise_Amplitude;
        float _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2;
        Unity_Multiply_float_float(_SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2, _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0, _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2);
        float _Absolute_20c059810dc244fb9613bea848e93047_Out_1;
        Unity_Absolute_float(_Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2, _Absolute_20c059810dc244fb9613bea848e93047_Out_1);
        float _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2;
        Unity_Add_float(_OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1, _Absolute_20c059810dc244fb9613bea848e93047_Out_1, _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2);
        float _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        Unity_Saturate_float(_Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2, _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1);
        OutVector1_1 = _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Depth_2 = _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        SecondFadeDepth_3 = _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        FoamDepth_4 = _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0 = _Refraction_Enabled;
            float _Property_f2bba435f69245e29ba364aa15a6246d_Out_0 = _Depth_Strength;
            float _Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0 = _WaveSize;
            UnityTexture2D _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0 = _WaveSpeed;
            float _Property_acee9dd3062c4febbba1a7f48505a892_Out_0 = _WaveSize2;
            float2 _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0 = _WaveSpeed2;
            float _Property_c934b87e11884ee8a832f236aeb6496d_Out_0 = _Normal_Strength;
            Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.TimeParameters = IN.TimeParameters;
            float3 _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(_Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0, _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0, _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0, _Property_acee9dd3062c4febbba1a7f48505a892_Out_0, _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0, _Property_c934b87e11884ee8a832f236aeb6496d_Out_0, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1);
            float _Property_334955ba786b43dc8b8b69068b22e167_Out_0 = _Refraction_Strength;
            float3 _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_334955ba786b43dc8b8b69068b22e167_Out_0.xxx), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2);
            float _Property_004ca3e6203d4184986681a4527c2e63_Out_0 = _Refraction_Enabled;
            float _Property_347e4eac494e4fe6892b846c0efc2313_Out_0 = _Foam_Speed;
            float _Property_dcb74838243b4512aa30f059bfa6798b_Out_0 = _Foam_Noise_Scale;
            float _Property_760c8cbb4aba427f8e610388fe099157_Out_0 = _Foam_Noise_Amplitude;
            float _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0 = _Foam_Size;
            Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float _DepthFade_d12ba53613cd41a2b21fcc4c74833226;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.ScreenPosition = IN.ScreenPosition;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.uv0 = IN.uv0;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.TimeParameters = IN.TimeParameters;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4;
            SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float(0), _Property_f2bba435f69245e29ba364aa15a6246d_Out_0, float(4), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2, _Property_004ca3e6203d4184986681a4527c2e63_Out_0, float(1), _Property_347e4eac494e4fe6892b846c0efc2313_Out_0, _Property_dcb74838243b4512aa30f059bfa6798b_Out_0, _Property_760c8cbb4aba427f8e610388fe099157_Out_0, _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4);
            float _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            Unity_Branch_float(_Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _Branch_79a776ac296e4440965d835189b687ba_Out_3);
            surface.Alpha = _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Surface_Color;
        float4 _Deep_Color;
        float4 _Normal_Map_TexelSize;
        float _WaveSize;
        float2 _WaveSpeed;
        float _WaveSize2;
        float2 _WaveSpeed2;
        float _Mettalic;
        float _Smoothness;
        float _Normal_Strength;
        float _Depth_Strength;
        float4 _Caustics_Map_TexelSize;
        float _Caustics_Scale;
        float _Distortion_Scale;
        float _Distortion_Speed;
        float _Refraction_Strength;
        float _Refraction_Enabled;
        float _Foam_Speed;
        float _Foam_Noise_Scale;
        float _Foam_Noise_Amplitude;
        float _Foam_Size;
        float _Foam_Enabled;
        float _Caustics_Enabled;
        float4 _WaterTexture_TexelSize;
        float4 _WaterTexture_ST;
        float2 _Water_Texture_Movement;
        float _Water_Texture_Opacity;
        float _Caustics_Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        float _Depth_power;
        TEXTURE2D(_Caustics_Map);
        SAMPLER(sampler_Caustics_Map);
        TEXTURE2D(_WaterTexture);
        SAMPLER(sampler_WaterTexture);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(abs(A), B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        struct Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float
        {
        float3 AbsoluteWorldSpacePosition;
        float3 TimeParameters;
        };
        
        void SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(float _WaveSize, UnityTexture2D _Normal, float2 _WaveSpeed, float _WaveSize2, float2 _WaveSpeed2, float _Normal_Stranght, Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0 = _Normal;
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_A_4 = 0;
        float2 _Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0 = float2(_Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1, _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3);
        float _Property_4a9326d48476475eabddc6d02a6b6f06_Out_0 = _WaveSize;
        float2 _Property_79f9d365373e442f94e67237d36fa439_Out_0 = _WaveSpeed;
        float2 _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2;
        Unity_Multiply_float2_float2(_Property_79f9d365373e442f94e67237d36fa439_Out_0, (IN.TimeParameters.x.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2);
        float2 _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_4a9326d48476475eabddc6d02a6b6f06_Out_0.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2, _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3);
        float4 _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.tex, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.samplerstate, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.GetTransformedUV(_TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3));
        _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0);
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_R_4 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.r;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_G_5 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.g;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_B_6 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.b;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_A_7 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.a;
        UnityTexture2D _Property_3602dc36773841649ece93e40cb97791_Out_0 = _Normal;
        float _Property_b4289ec1b7944303907293e29374dd74_Out_0 = _WaveSize2;
        float2 _Property_4a9df16b1002432a9dbde8ec0432401f_Out_0 = _WaveSpeed2;
        float2 _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2;
        Unity_Multiply_float2_float2(_Property_4a9df16b1002432a9dbde8ec0432401f_Out_0, (IN.TimeParameters.x.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2);
        float2 _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_b4289ec1b7944303907293e29374dd74_Out_0.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2, _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3);
        float4 _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3602dc36773841649ece93e40cb97791_Out_0.tex, _Property_3602dc36773841649ece93e40cb97791_Out_0.samplerstate, _Property_3602dc36773841649ece93e40cb97791_Out_0.GetTransformedUV(_TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3));
        _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0);
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_R_4 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.r;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_G_5 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.g;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_B_6 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.b;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_A_7 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.a;
        float3 _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2;
        Unity_NormalBlend_float((_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.xyz), (_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.xyz), _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2);
        float _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0 = _Normal_Stranght;
        float _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2;
        Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2);
        float2 _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0 = float2(float(0), _ProjectionParams.z);
        float _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3;
        Unity_Remap_float(_Distance_e9573e7724034e4a8c25515bfdb49340_Out_2, _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0, float2 (1, 0), _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3);
        float _Power_f267dd9724c74f58953f24eee4860ba9_Out_2;
        Unity_Power_float(_Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3, float(500), _Power_f267dd9724c74f58953f24eee4860ba9_Out_2);
        float _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3;
        Unity_Lerp_float(float(0), _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0, _Power_f267dd9724c74f58953f24eee4860ba9_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3);
        float3 _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        Unity_NormalStrength_float(_NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3, _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2);
        OutVector3_1 = _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float
        {
        float4 ScreenPosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float _DepthScale, float _Depth_Streght, float _Depth_power, float3 _Normal, float _RefractionEnabled, float _Foam_Scale, float _Foam_Speed, float _Foam_Noise_Scale, float _Foam_Noise_Amplitude, float _Foam_Falloff, Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float IN, out float OutVector1_1, out float Depth_2, out float SecondFadeDepth_3, out float FoamDepth_4)
        {
        float _Property_318cdc9ecaed4eadaf06301c7076532f_Out_0 = _RefractionEnabled;
        float4 _ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float3 _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0 = _Normal;
        float3 _Add_356e75099f72430888ad16810e5d286d_Out_2;
        Unity_Add_float3((_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2);
        float3 _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3;
        Unity_Branch_float3(_Property_318cdc9ecaed4eadaf06301c7076532f_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2, (_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3);
        float _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1;
        Unity_SceneDepth_Eye_float((float4(_Branch_9e2e59e02af84dabb4377a7f18245711_Out_3, 1.0)), _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1);
        float4 _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0 = IN.ScreenPosition;
        float _Split_16d3558d6d92445a880cb5f6676de872_R_1 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[0];
        float _Split_16d3558d6d92445a880cb5f6676de872_G_2 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[1];
        float _Split_16d3558d6d92445a880cb5f6676de872_B_3 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[2];
        float _Split_16d3558d6d92445a880cb5f6676de872_A_4 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[3];
        float _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0 = _DepthScale;
        float _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2;
        Unity_Add_float(_Split_16d3558d6d92445a880cb5f6676de872_A_4, _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2);
        float _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        Unity_Subtract_float(_SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2);
        float _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2;
        Unity_Comparison_Less_float(_Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, float(0.1), _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2);
        float _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1);
        float4 _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0 = IN.ScreenPosition;
        float _Split_7d45e7abeb8e4d2a97574e613125e070_R_1 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[0];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_G_2 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[1];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_B_3 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[2];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_A_4 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[3];
        float _Property_0909716a724643ba9aa2fef403343a7d_Out_0 = _DepthScale;
        float _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2;
        Unity_Add_float(_Split_7d45e7abeb8e4d2a97574e613125e070_A_4, _Property_0909716a724643ba9aa2fef403343a7d_Out_0, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2);
        float _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2;
        Unity_Subtract_float(_SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2);
        float _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3;
        Unity_Branch_float(_Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3);
        float _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0 = _Depth_Streght;
        float _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2;
        Unity_Multiply_float_float(_Branch_ddac7cdb85fe4825bda3abac374df776_Out_3, _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0, _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2);
        float _Saturate_5cc2a092cece487983e25916a82532c4_Out_1;
        Unity_Saturate_float(_Multiply_c5e61fe354954492921110c4bf3178fd_Out_2, _Saturate_5cc2a092cece487983e25916a82532c4_Out_1);
        float _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1;
        Unity_OneMinus_float(_Saturate_5cc2a092cece487983e25916a82532c4_Out_1, _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1);
        float _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0 = _Depth_power;
        float _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2;
        Unity_Power_float(_OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1, _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0, _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2);
        float _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Unity_OneMinus_float(_Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2, _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1);
        float4 _ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1;
        Unity_SceneDepth_Eye_float(_ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0, _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1);
        float4 _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0 = IN.ScreenPosition;
        float _Split_ba379f9dd00c47e89bdaff09775abecb_R_1 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[0];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_G_2 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[1];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_B_3 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[2];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_A_4 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[3];
        float _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0 = _DepthScale;
        float _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2;
        Unity_Add_float(_Split_ba379f9dd00c47e89bdaff09775abecb_A_4, _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2);
        float _Subtract_9cdc83575a4441888b548be03402455c_Out_2;
        Unity_Subtract_float(_SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2, _Subtract_9cdc83575a4441888b548be03402455c_Out_2);
        float _Multiply_adb140a84534463c8282fcc1cf533119_Out_2;
        Unity_Multiply_float_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, 5, _Multiply_adb140a84534463c8282fcc1cf533119_Out_2);
        float _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1;
        Unity_Saturate_float(_Multiply_adb140a84534463c8282fcc1cf533119_Out_2, _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1);
        float _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1;
        Unity_OneMinus_float(_Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1, _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1);
        float _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        Unity_OneMinus_float(_OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1, _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1);
        float _Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0 = _Foam_Falloff;
        float _Negate_c1176c2567c04045a1e28135f9db2058_Out_1;
        Unity_Negate_float(_Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1);
        float _Add_df082a7d0dc44ed7947582af57d7db85_Out_2;
        Unity_Add_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1, _Add_df082a7d0dc44ed7947582af57d7db85_Out_2);
        float _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0 = _Foam_Scale;
        float _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2;
        Unity_Multiply_float_float(_Add_df082a7d0dc44ed7947582af57d7db85_Out_2, _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0, _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2);
        float _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1;
        Unity_Saturate_float(_Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2, _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1);
        float _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1;
        Unity_OneMinus_float(_Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1, _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1);
        float _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1;
        Unity_OneMinus_float(_OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1, _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1);
        float _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0 = _Foam_Speed;
        float _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0, _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2);
        float2 _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_635a6efa292d46ee852700ca8924fd35_Out_2.xx), _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3);
        float _Property_43d4265c5429441fb1d91ad7136782ad_Out_0 = _Foam_Noise_Scale;
        float _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3, _Property_43d4265c5429441fb1d91ad7136782ad_Out_0, _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2);
        float _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0 = _Foam_Noise_Amplitude;
        float _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2;
        Unity_Multiply_float_float(_SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2, _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0, _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2);
        float _Absolute_20c059810dc244fb9613bea848e93047_Out_1;
        Unity_Absolute_float(_Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2, _Absolute_20c059810dc244fb9613bea848e93047_Out_1);
        float _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2;
        Unity_Add_float(_OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1, _Absolute_20c059810dc244fb9613bea848e93047_Out_1, _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2);
        float _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        Unity_Saturate_float(_Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2, _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1);
        OutVector1_1 = _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Depth_2 = _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        SecondFadeDepth_3 = _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        FoamDepth_4 = _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float
        {
        float3 AbsoluteWorldSpacePosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(UnityTexture2D _Caustics, float _Distortion_Scale, float _Distortion_Speed, float _Caustics_Scale, float _Caustics_Opacity, Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float IN, out float4 OutVector4_1)
        {
        float _Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0 = _Caustics_Opacity;
        UnityTexture2D _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0 = _Caustics;
        float _Split_1012f2365d224feb8935e9feaa351beb_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_1012f2365d224feb8935e9feaa351beb_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_1012f2365d224feb8935e9feaa351beb_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_1012f2365d224feb8935e9feaa351beb_A_4 = 0;
        float2 _Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0 = float2(_Split_1012f2365d224feb8935e9feaa351beb_R_1, _Split_1012f2365d224feb8935e9feaa351beb_B_3);
        float _Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0 = _Caustics_Scale;
        float2 _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3;
        Unity_TilingAndOffset_float(_Vector2_3f7e44e17286401cb092a6f14f7e9767_Out_0, (_Property_1a92e7e5282b45f6a6e1ce7d29ee5147_Out_0.xx), float2 (0, 0), _TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3);
        float _Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0 = _Distortion_Speed;
        float _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2;
        Unity_Multiply_float_float(_Property_2dbfda4458db4c7aa454bd8c5342be87_Out_0, IN.TimeParameters.x, _Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2);
        float _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1;
        Unity_Negate_float(_Multiply_89a2a7ef4b0f4ee8bb7e24271132fdfb_Out_2, _Negate_6e0c023331f9435fa320590f00ac95d8_Out_1);
        float2 _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Negate_6e0c023331f9435fa320590f00ac95d8_Out_1.xx), _TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3);
        float _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0 = _Distortion_Scale;
        float _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_72c8643292214bd58e3ddc8c68b1a5c9_Out_3, _Property_1c580c5e9a314fcab49816aabd0bf2b3_Out_0, _SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2);
        float _Property_2cdef5d6547f40bf927ab89938223638_Out_0 = _Distortion_Speed;
        float _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2;
        Unity_Multiply_float_float(_Property_2cdef5d6547f40bf927ab89938223638_Out_0, IN.TimeParameters.x, _Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2);
        float2 _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_ce83cf5b120d4cd9bbceaea9aede8b05_Out_2.xx), _TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3);
        float _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0 = _Distortion_Scale;
        float _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_ef9f328d81494053a8a8183612bd8d39_Out_3, _Property_4b07d4d411694cf39fd34bcc3edbab3c_Out_0, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2);
        float _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3;
        Unity_Lerp_float(_SimpleNoise_873cc579ff43445c90a5d9fba8d8efa7_Out_2, _SimpleNoise_0babf590f21a46b2bad9885638dac3da_Out_2, float(0.5), _Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3);
        float2 _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3;
        Unity_Lerp_float2(_TilingAndOffset_d337f2acb99944a9a9e58c4a86074f2e_Out_3, (_Lerp_0b3707c7a91f4fbe896ae20014b75987_Out_3.xx), float2(0.4, 0.4), _Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3);
        float4 _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.tex, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.samplerstate, _Property_1533c1b5806a416bad32d5d9d63fc996_Out_0.GetTransformedUV(_Lerp_84dcd826a97f434395bb1d24744e7d69_Out_3));
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_R_4 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.r;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_G_5 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.g;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_B_6 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.b;
        float _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_A_7 = _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0.a;
        float4 _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        Unity_Multiply_float4_float4((_Property_686fe894d7ba4a14b88fe6c268242cdf_Out_0.xxxx), _SampleTexture2D_eba263be9d0542858a4ada55050aaca9_RGBA_0, _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2);
        OutVector4_1 = _Multiply_d12a036f0072450eb9184a779c5afe37_Out_2;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_942d5332a122417fa73853897fe60c48_Out_0 = _Foam_Enabled;
            float _Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0 = _Water_Texture_Opacity;
            UnityTexture2D _Property_c1940be719424daf973545cb452ff735_Out_0 = UnityBuildTexture2DStruct(_WaterTexture);
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_R_1 = IN.AbsoluteWorldSpacePosition[0];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_G_2 = IN.AbsoluteWorldSpacePosition[1];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3 = IN.AbsoluteWorldSpacePosition[2];
            float _Split_5a66b3eabf4247eab1df93cde1d431cc_A_4 = 0;
            float2 _Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0 = float2(_Split_5a66b3eabf4247eab1df93cde1d431cc_R_1, _Split_5a66b3eabf4247eab1df93cde1d431cc_B_3);
            float2 _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0 = _Water_Texture_Movement;
            float2 _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_0d93faaf58ac4796b11f00b6c900ac7f_Out_0, _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2);
            float2 _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3;
            Unity_TilingAndOffset_float(_Vector2_5e536aa9866d4604b8b6bed445e3f2df_Out_0, float2 (1, 1), _Multiply_2ce320dcab2c44b38fdefc53a090f9c1_Out_2, _TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3);
            float4 _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c1940be719424daf973545cb452ff735_Out_0.tex, _Property_c1940be719424daf973545cb452ff735_Out_0.samplerstate, _Property_c1940be719424daf973545cb452ff735_Out_0.GetTransformedUV(_TilingAndOffset_b3efb503d4f942d5aba17f8bf6947a15_Out_3));
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_R_4 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.r;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_G_5 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.g;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_B_6 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.b;
            float _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_A_7 = _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0.a;
            float4 _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2;
            Unity_Multiply_float4_float4((_Property_05f3ff12ec874e2ab39bad0c274a3cfe_Out_0.xxxx), _SampleTexture2D_cd12cc44f608409bb6da927940c453a8_RGBA_0, _Multiply_3f652e13e5644ef886115b5ec446c687_Out_2);
            float4 _Property_45db940379974187aa06193e4e91bf30_Out_0 = _Surface_Color;
            float4 _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0 = _Deep_Color;
            float _Property_f2bba435f69245e29ba364aa15a6246d_Out_0 = _Depth_Strength;
            float _Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0 = _WaveSize;
            UnityTexture2D _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0 = _WaveSpeed;
            float _Property_acee9dd3062c4febbba1a7f48505a892_Out_0 = _WaveSize2;
            float2 _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0 = _WaveSpeed2;
            float _Property_c934b87e11884ee8a832f236aeb6496d_Out_0 = _Normal_Strength;
            Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.TimeParameters = IN.TimeParameters;
            float3 _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(_Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0, _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0, _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0, _Property_acee9dd3062c4febbba1a7f48505a892_Out_0, _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0, _Property_c934b87e11884ee8a832f236aeb6496d_Out_0, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1);
            float _Property_334955ba786b43dc8b8b69068b22e167_Out_0 = _Refraction_Strength;
            float3 _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_334955ba786b43dc8b8b69068b22e167_Out_0.xxx), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2);
            float _Property_004ca3e6203d4184986681a4527c2e63_Out_0 = _Refraction_Enabled;
            float _Property_347e4eac494e4fe6892b846c0efc2313_Out_0 = _Foam_Speed;
            float _Property_dcb74838243b4512aa30f059bfa6798b_Out_0 = _Foam_Noise_Scale;
            float _Property_760c8cbb4aba427f8e610388fe099157_Out_0 = _Foam_Noise_Amplitude;
            float _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0 = _Foam_Size;
            Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float _DepthFade_d12ba53613cd41a2b21fcc4c74833226;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.ScreenPosition = IN.ScreenPosition;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.uv0 = IN.uv0;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.TimeParameters = IN.TimeParameters;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4;
            SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float(0), _Property_f2bba435f69245e29ba364aa15a6246d_Out_0, float(4), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2, _Property_004ca3e6203d4184986681a4527c2e63_Out_0, float(1), _Property_347e4eac494e4fe6892b846c0efc2313_Out_0, _Property_dcb74838243b4512aa30f059bfa6798b_Out_0, _Property_760c8cbb4aba427f8e610388fe099157_Out_0, _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4);
            float4 _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3;
            Unity_Lerp_float4(_Property_45db940379974187aa06193e4e91bf30_Out_0, _Property_7994bbf5ea1f4920a28f77081eb38e16_Out_0, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxxx), _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3);
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_R_1 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[0];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[1];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[2];
            float _Split_8f2f6fc780ca46de94197d1c84619bbb_A_4 = _Lerp_ee02c97cbb634fdea6e731a03f40c7a0_Out_3[3];
            float4 _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4;
            float3 _Combine_ab70c0224251450087a230fa70578bfc_RGB_5;
            float2 _Combine_ab70c0224251450087a230fa70578bfc_RG_6;
            Unity_Combine_float(_Split_8f2f6fc780ca46de94197d1c84619bbb_R_1, _Split_8f2f6fc780ca46de94197d1c84619bbb_G_2, _Split_8f2f6fc780ca46de94197d1c84619bbb_B_3, float(1), _Combine_ab70c0224251450087a230fa70578bfc_RGBA_4, _Combine_ab70c0224251450087a230fa70578bfc_RGB_5, _Combine_ab70c0224251450087a230fa70578bfc_RG_6);
            float3 _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2;
            Unity_Multiply_float3_float3(_Combine_ab70c0224251450087a230fa70578bfc_RGB_5, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1.xxx), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2);
            float3 _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2;
            Unity_Add_float3((_Multiply_3f652e13e5644ef886115b5ec446c687_Out_2.xyz), _Multiply_fa0f27bad87045a89083546a5aaa6d06_Out_2, _Add_ce3801671af64319ba3c39f07b4aedc0_Out_2);
            float3 _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1;
            Unity_Saturate_float3(_Add_ce3801671af64319ba3c39f07b4aedc0_Out_2, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1);
            float3 _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3;
            Unity_Lerp_float3(float3(1, 1, 1), _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, (_DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4.xxx), _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3);
            float3 _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            Unity_Branch_float3(_Property_942d5332a122417fa73853897fe60c48_Out_0, _Lerp_91c059eb6776488b838f5d35b18489fc_Out_3, _Saturate_764f6d74862a4fa2bad2d48575a2b885_Out_1, _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3);
            float _Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0 = _Refraction_Enabled;
            float _Property_c61b272614064d2aaede0be5f876e26a_Out_0 = _Caustics_Enabled;
            float _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1);
            UnityTexture2D _Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0 = UnityBuildTexture2DStructNoScale(_Caustics_Map);
            float _Property_9940386e5105455bbb90176624ec703a_Out_0 = _Distortion_Scale;
            float _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0 = _Distortion_Speed;
            float _Property_1ad804a523494f74b670a22d24e647f8_Out_0 = _Caustics_Scale;
            float _Property_52e2043fade14631a18eeba2d115e057_Out_0 = _Caustics_Opacity;
            Bindings_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.uv0 = IN.uv0;
            _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b.TimeParameters = IN.TimeParameters;
            float4 _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1;
            SG_Caustics_e7cef77f3748f044b98a2fafee0e0d4e_float(_Property_c18a3ccf672f4acf8adf679bd2c6b5f8_Out_0, _Property_9940386e5105455bbb90176624ec703a_Out_0, _Property_5a48b4c2046847b9813d950dfa82b1f0_Out_0, _Property_1ad804a523494f74b670a22d24e647f8_Out_0, _Property_52e2043fade14631a18eeba2d115e057_Out_0, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b, _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1);
            float4 _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2;
            Unity_Multiply_float4_float4((_OneMinus_e6e98854a68f41398a011f2b7da1bee3_Out_1.xxxx), _Caustics_4b4e81f3ee4a4984a1958b2b9c18d08b_OutVector4_1, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2);
            float4 _Branch_5becbaeb67464d16b337faa05512237c_Out_3;
            Unity_Branch_float4(_Property_c61b272614064d2aaede0be5f876e26a_Out_0, _Multiply_e69bdfad7a3549c3b9564cff4eb3e6b2_Out_2, float4(0, 0, 0, 0), _Branch_5becbaeb67464d16b337faa05512237c_Out_3);
            float4 _ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float _Comparison_8584fdc993bb469a96b47883ba133849_Out_2;
            Unity_Comparison_Less_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, float(0.1), _Comparison_8584fdc993bb469a96b47883ba133849_Out_2);
            float _Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0 = _Refraction_Strength;
            float3 _Multiply_754a12216e3d4884931fab93196a2613_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_34d2a4c4f05a44b7a4e00f6d5c30af18_Out_0.xxx), _Multiply_754a12216e3d4884931fab93196a2613_Out_2);
            float3 _Branch_16061ba1344840bb878837f12dff6a9f_Out_3;
            Unity_Branch_float3(_Comparison_8584fdc993bb469a96b47883ba133849_Out_2, float3(0, 0, 0), _Multiply_754a12216e3d4884931fab93196a2613_Out_2, _Branch_16061ba1344840bb878837f12dff6a9f_Out_3);
            float3 _Add_973d613c80b144f59a3d1fcb338bd611_Out_2;
            Unity_Add_float3((_ScreenPosition_7b63114d09fd4fe896b95ce925ddafe7_Out_0.xyz), _Branch_16061ba1344840bb878837f12dff6a9f_Out_3, _Add_973d613c80b144f59a3d1fcb338bd611_Out_2);
            float3 _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1;
            Unity_SceneColor_float((float4(_Add_973d613c80b144f59a3d1fcb338bd611_Out_2, 1.0)), _SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1);
            float _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1;
            Unity_OneMinus_float(_DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1);
            float3 _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2;
            Unity_Multiply_float3_float3(_SceneColor_fc086b7e086a4375b10adb6f73115bcd_Out_1, (_OneMinus_cda4b87e8a3e4101bed99c039f98f58d_Out_1.xxx), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2);
            float3 _Add_0031381e720c46b6b4f601af8a9c6349_Out_2;
            Unity_Add_float3((_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Multiply_b4a7009946ca4f989c22cf95f4ad2d88_Out_2, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2);
            float3 _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            Unity_Branch_float3(_Property_46e58d9eb5ee4c50b269d5d6cc7c95dd_Out_0, _Add_0031381e720c46b6b4f601af8a9c6349_Out_2, (_Branch_5becbaeb67464d16b337faa05512237c_Out_3.xyz), _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3);
            float _Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0 = _Refraction_Enabled;
            float _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            Unity_Branch_float(_Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _Branch_79a776ac296e4440965d835189b687ba_Out_3);
            surface.BaseColor = _Branch_8e77b80f4def4160abc5bbbbbaf8df72_Out_3;
            surface.Emission = _Branch_f35f6d0eb8d04071add3f672117a15cb_Out_3;
            surface.Alpha = _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.texcoord1  = attributes.uv1;
            result.texcoord2  = attributes.uv2;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SceneSelectionPass
        #define BUILTIN_TARGET_API 1
        #define SCENESELECTIONPASS 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Surface_Color;
        float4 _Deep_Color;
        float4 _Normal_Map_TexelSize;
        float _WaveSize;
        float2 _WaveSpeed;
        float _WaveSize2;
        float2 _WaveSpeed2;
        float _Mettalic;
        float _Smoothness;
        float _Normal_Strength;
        float _Depth_Strength;
        float4 _Caustics_Map_TexelSize;
        float _Caustics_Scale;
        float _Distortion_Scale;
        float _Distortion_Speed;
        float _Refraction_Strength;
        float _Refraction_Enabled;
        float _Foam_Speed;
        float _Foam_Noise_Scale;
        float _Foam_Noise_Amplitude;
        float _Foam_Size;
        float _Foam_Enabled;
        float _Caustics_Enabled;
        float4 _WaterTexture_TexelSize;
        float4 _WaterTexture_ST;
        float2 _Water_Texture_Movement;
        float _Water_Texture_Opacity;
        float _Caustics_Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        float _Depth_power;
        TEXTURE2D(_Caustics_Map);
        SAMPLER(sampler_Caustics_Map);
        TEXTURE2D(_WaterTexture);
        SAMPLER(sampler_WaterTexture);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(abs(A), B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        struct Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float
        {
        float3 AbsoluteWorldSpacePosition;
        float3 TimeParameters;
        };
        
        void SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(float _WaveSize, UnityTexture2D _Normal, float2 _WaveSpeed, float _WaveSize2, float2 _WaveSpeed2, float _Normal_Stranght, Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0 = _Normal;
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_A_4 = 0;
        float2 _Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0 = float2(_Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1, _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3);
        float _Property_4a9326d48476475eabddc6d02a6b6f06_Out_0 = _WaveSize;
        float2 _Property_79f9d365373e442f94e67237d36fa439_Out_0 = _WaveSpeed;
        float2 _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2;
        Unity_Multiply_float2_float2(_Property_79f9d365373e442f94e67237d36fa439_Out_0, (IN.TimeParameters.x.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2);
        float2 _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_4a9326d48476475eabddc6d02a6b6f06_Out_0.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2, _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3);
        float4 _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.tex, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.samplerstate, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.GetTransformedUV(_TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3));
        _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0);
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_R_4 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.r;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_G_5 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.g;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_B_6 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.b;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_A_7 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.a;
        UnityTexture2D _Property_3602dc36773841649ece93e40cb97791_Out_0 = _Normal;
        float _Property_b4289ec1b7944303907293e29374dd74_Out_0 = _WaveSize2;
        float2 _Property_4a9df16b1002432a9dbde8ec0432401f_Out_0 = _WaveSpeed2;
        float2 _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2;
        Unity_Multiply_float2_float2(_Property_4a9df16b1002432a9dbde8ec0432401f_Out_0, (IN.TimeParameters.x.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2);
        float2 _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_b4289ec1b7944303907293e29374dd74_Out_0.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2, _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3);
        float4 _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3602dc36773841649ece93e40cb97791_Out_0.tex, _Property_3602dc36773841649ece93e40cb97791_Out_0.samplerstate, _Property_3602dc36773841649ece93e40cb97791_Out_0.GetTransformedUV(_TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3));
        _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0);
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_R_4 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.r;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_G_5 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.g;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_B_6 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.b;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_A_7 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.a;
        float3 _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2;
        Unity_NormalBlend_float((_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.xyz), (_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.xyz), _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2);
        float _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0 = _Normal_Stranght;
        float _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2;
        Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2);
        float2 _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0 = float2(float(0), _ProjectionParams.z);
        float _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3;
        Unity_Remap_float(_Distance_e9573e7724034e4a8c25515bfdb49340_Out_2, _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0, float2 (1, 0), _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3);
        float _Power_f267dd9724c74f58953f24eee4860ba9_Out_2;
        Unity_Power_float(_Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3, float(500), _Power_f267dd9724c74f58953f24eee4860ba9_Out_2);
        float _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3;
        Unity_Lerp_float(float(0), _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0, _Power_f267dd9724c74f58953f24eee4860ba9_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3);
        float3 _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        Unity_NormalStrength_float(_NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3, _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2);
        OutVector3_1 = _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float
        {
        float4 ScreenPosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float _DepthScale, float _Depth_Streght, float _Depth_power, float3 _Normal, float _RefractionEnabled, float _Foam_Scale, float _Foam_Speed, float _Foam_Noise_Scale, float _Foam_Noise_Amplitude, float _Foam_Falloff, Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float IN, out float OutVector1_1, out float Depth_2, out float SecondFadeDepth_3, out float FoamDepth_4)
        {
        float _Property_318cdc9ecaed4eadaf06301c7076532f_Out_0 = _RefractionEnabled;
        float4 _ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float3 _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0 = _Normal;
        float3 _Add_356e75099f72430888ad16810e5d286d_Out_2;
        Unity_Add_float3((_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2);
        float3 _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3;
        Unity_Branch_float3(_Property_318cdc9ecaed4eadaf06301c7076532f_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2, (_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3);
        float _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1;
        Unity_SceneDepth_Eye_float((float4(_Branch_9e2e59e02af84dabb4377a7f18245711_Out_3, 1.0)), _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1);
        float4 _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0 = IN.ScreenPosition;
        float _Split_16d3558d6d92445a880cb5f6676de872_R_1 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[0];
        float _Split_16d3558d6d92445a880cb5f6676de872_G_2 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[1];
        float _Split_16d3558d6d92445a880cb5f6676de872_B_3 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[2];
        float _Split_16d3558d6d92445a880cb5f6676de872_A_4 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[3];
        float _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0 = _DepthScale;
        float _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2;
        Unity_Add_float(_Split_16d3558d6d92445a880cb5f6676de872_A_4, _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2);
        float _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        Unity_Subtract_float(_SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2);
        float _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2;
        Unity_Comparison_Less_float(_Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, float(0.1), _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2);
        float _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1);
        float4 _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0 = IN.ScreenPosition;
        float _Split_7d45e7abeb8e4d2a97574e613125e070_R_1 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[0];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_G_2 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[1];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_B_3 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[2];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_A_4 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[3];
        float _Property_0909716a724643ba9aa2fef403343a7d_Out_0 = _DepthScale;
        float _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2;
        Unity_Add_float(_Split_7d45e7abeb8e4d2a97574e613125e070_A_4, _Property_0909716a724643ba9aa2fef403343a7d_Out_0, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2);
        float _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2;
        Unity_Subtract_float(_SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2);
        float _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3;
        Unity_Branch_float(_Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3);
        float _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0 = _Depth_Streght;
        float _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2;
        Unity_Multiply_float_float(_Branch_ddac7cdb85fe4825bda3abac374df776_Out_3, _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0, _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2);
        float _Saturate_5cc2a092cece487983e25916a82532c4_Out_1;
        Unity_Saturate_float(_Multiply_c5e61fe354954492921110c4bf3178fd_Out_2, _Saturate_5cc2a092cece487983e25916a82532c4_Out_1);
        float _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1;
        Unity_OneMinus_float(_Saturate_5cc2a092cece487983e25916a82532c4_Out_1, _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1);
        float _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0 = _Depth_power;
        float _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2;
        Unity_Power_float(_OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1, _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0, _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2);
        float _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Unity_OneMinus_float(_Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2, _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1);
        float4 _ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1;
        Unity_SceneDepth_Eye_float(_ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0, _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1);
        float4 _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0 = IN.ScreenPosition;
        float _Split_ba379f9dd00c47e89bdaff09775abecb_R_1 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[0];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_G_2 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[1];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_B_3 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[2];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_A_4 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[3];
        float _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0 = _DepthScale;
        float _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2;
        Unity_Add_float(_Split_ba379f9dd00c47e89bdaff09775abecb_A_4, _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2);
        float _Subtract_9cdc83575a4441888b548be03402455c_Out_2;
        Unity_Subtract_float(_SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2, _Subtract_9cdc83575a4441888b548be03402455c_Out_2);
        float _Multiply_adb140a84534463c8282fcc1cf533119_Out_2;
        Unity_Multiply_float_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, 5, _Multiply_adb140a84534463c8282fcc1cf533119_Out_2);
        float _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1;
        Unity_Saturate_float(_Multiply_adb140a84534463c8282fcc1cf533119_Out_2, _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1);
        float _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1;
        Unity_OneMinus_float(_Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1, _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1);
        float _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        Unity_OneMinus_float(_OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1, _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1);
        float _Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0 = _Foam_Falloff;
        float _Negate_c1176c2567c04045a1e28135f9db2058_Out_1;
        Unity_Negate_float(_Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1);
        float _Add_df082a7d0dc44ed7947582af57d7db85_Out_2;
        Unity_Add_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1, _Add_df082a7d0dc44ed7947582af57d7db85_Out_2);
        float _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0 = _Foam_Scale;
        float _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2;
        Unity_Multiply_float_float(_Add_df082a7d0dc44ed7947582af57d7db85_Out_2, _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0, _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2);
        float _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1;
        Unity_Saturate_float(_Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2, _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1);
        float _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1;
        Unity_OneMinus_float(_Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1, _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1);
        float _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1;
        Unity_OneMinus_float(_OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1, _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1);
        float _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0 = _Foam_Speed;
        float _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0, _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2);
        float2 _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_635a6efa292d46ee852700ca8924fd35_Out_2.xx), _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3);
        float _Property_43d4265c5429441fb1d91ad7136782ad_Out_0 = _Foam_Noise_Scale;
        float _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3, _Property_43d4265c5429441fb1d91ad7136782ad_Out_0, _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2);
        float _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0 = _Foam_Noise_Amplitude;
        float _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2;
        Unity_Multiply_float_float(_SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2, _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0, _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2);
        float _Absolute_20c059810dc244fb9613bea848e93047_Out_1;
        Unity_Absolute_float(_Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2, _Absolute_20c059810dc244fb9613bea848e93047_Out_1);
        float _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2;
        Unity_Add_float(_OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1, _Absolute_20c059810dc244fb9613bea848e93047_Out_1, _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2);
        float _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        Unity_Saturate_float(_Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2, _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1);
        OutVector1_1 = _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Depth_2 = _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        SecondFadeDepth_3 = _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        FoamDepth_4 = _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0 = _Refraction_Enabled;
            float _Property_f2bba435f69245e29ba364aa15a6246d_Out_0 = _Depth_Strength;
            float _Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0 = _WaveSize;
            UnityTexture2D _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0 = _WaveSpeed;
            float _Property_acee9dd3062c4febbba1a7f48505a892_Out_0 = _WaveSize2;
            float2 _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0 = _WaveSpeed2;
            float _Property_c934b87e11884ee8a832f236aeb6496d_Out_0 = _Normal_Strength;
            Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.TimeParameters = IN.TimeParameters;
            float3 _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(_Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0, _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0, _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0, _Property_acee9dd3062c4febbba1a7f48505a892_Out_0, _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0, _Property_c934b87e11884ee8a832f236aeb6496d_Out_0, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1);
            float _Property_334955ba786b43dc8b8b69068b22e167_Out_0 = _Refraction_Strength;
            float3 _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_334955ba786b43dc8b8b69068b22e167_Out_0.xxx), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2);
            float _Property_004ca3e6203d4184986681a4527c2e63_Out_0 = _Refraction_Enabled;
            float _Property_347e4eac494e4fe6892b846c0efc2313_Out_0 = _Foam_Speed;
            float _Property_dcb74838243b4512aa30f059bfa6798b_Out_0 = _Foam_Noise_Scale;
            float _Property_760c8cbb4aba427f8e610388fe099157_Out_0 = _Foam_Noise_Amplitude;
            float _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0 = _Foam_Size;
            Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float _DepthFade_d12ba53613cd41a2b21fcc4c74833226;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.ScreenPosition = IN.ScreenPosition;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.uv0 = IN.uv0;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.TimeParameters = IN.TimeParameters;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4;
            SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float(0), _Property_f2bba435f69245e29ba364aa15a6246d_Out_0, float(4), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2, _Property_004ca3e6203d4184986681a4527c2e63_Out_0, float(1), _Property_347e4eac494e4fe6892b846c0efc2313_Out_0, _Property_dcb74838243b4512aa30f059bfa6798b_Out_0, _Property_760c8cbb4aba427f8e610388fe099157_Out_0, _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4);
            float _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            Unity_Branch_float(_Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _Branch_79a776ac296e4440965d835189b687ba_Out_3);
            surface.Alpha = _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS ScenePickingPass
        #define BUILTIN_TARGET_API 1
        #define SCENEPICKINGPASS 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Surface_Color;
        float4 _Deep_Color;
        float4 _Normal_Map_TexelSize;
        float _WaveSize;
        float2 _WaveSpeed;
        float _WaveSize2;
        float2 _WaveSpeed2;
        float _Mettalic;
        float _Smoothness;
        float _Normal_Strength;
        float _Depth_Strength;
        float4 _Caustics_Map_TexelSize;
        float _Caustics_Scale;
        float _Distortion_Scale;
        float _Distortion_Speed;
        float _Refraction_Strength;
        float _Refraction_Enabled;
        float _Foam_Speed;
        float _Foam_Noise_Scale;
        float _Foam_Noise_Amplitude;
        float _Foam_Size;
        float _Foam_Enabled;
        float _Caustics_Enabled;
        float4 _WaterTexture_TexelSize;
        float4 _WaterTexture_ST;
        float2 _Water_Texture_Movement;
        float _Water_Texture_Opacity;
        float _Caustics_Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        float _Depth_power;
        TEXTURE2D(_Caustics_Map);
        SAMPLER(sampler_Caustics_Map);
        TEXTURE2D(_WaterTexture);
        SAMPLER(sampler_WaterTexture);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(abs(A), B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        struct Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float
        {
        float3 AbsoluteWorldSpacePosition;
        float3 TimeParameters;
        };
        
        void SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(float _WaveSize, UnityTexture2D _Normal, float2 _WaveSpeed, float _WaveSize2, float2 _WaveSpeed2, float _Normal_Stranght, Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float IN, out float3 OutVector3_1)
        {
        UnityTexture2D _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0 = _Normal;
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1 = IN.AbsoluteWorldSpacePosition[0];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_G_2 = IN.AbsoluteWorldSpacePosition[1];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3 = IN.AbsoluteWorldSpacePosition[2];
        float _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_A_4 = 0;
        float2 _Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0 = float2(_Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_R_1, _Split_bdab328a8e0641a1ae2cbc2b2c78dfe7_B_3);
        float _Property_4a9326d48476475eabddc6d02a6b6f06_Out_0 = _WaveSize;
        float2 _Property_79f9d365373e442f94e67237d36fa439_Out_0 = _WaveSpeed;
        float2 _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2;
        Unity_Multiply_float2_float2(_Property_79f9d365373e442f94e67237d36fa439_Out_0, (IN.TimeParameters.x.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2);
        float2 _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_4a9326d48476475eabddc6d02a6b6f06_Out_0.xx), _Multiply_35ffd1c6319f4a39806a8ac9c0f3b08a_Out_2, _TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3);
        float4 _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.tex, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.samplerstate, _Property_fe329a614ae14864afcb42f9b9c8b11f_Out_0.GetTransformedUV(_TilingAndOffset_20a81e26768a469ca4d190471b503d2d_Out_3));
        _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0);
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_R_4 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.r;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_G_5 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.g;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_B_6 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.b;
        float _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_A_7 = _SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.a;
        UnityTexture2D _Property_3602dc36773841649ece93e40cb97791_Out_0 = _Normal;
        float _Property_b4289ec1b7944303907293e29374dd74_Out_0 = _WaveSize2;
        float2 _Property_4a9df16b1002432a9dbde8ec0432401f_Out_0 = _WaveSpeed2;
        float2 _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2;
        Unity_Multiply_float2_float2(_Property_4a9df16b1002432a9dbde8ec0432401f_Out_0, (IN.TimeParameters.x.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2);
        float2 _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3;
        Unity_TilingAndOffset_float(_Vector2_1742332ccf684b05ba72fd01ae516ac9_Out_0, (_Property_b4289ec1b7944303907293e29374dd74_Out_0.xx), _Multiply_e9d362860ae845d6960dba795a7bfbba_Out_2, _TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3);
        float4 _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3602dc36773841649ece93e40cb97791_Out_0.tex, _Property_3602dc36773841649ece93e40cb97791_Out_0.samplerstate, _Property_3602dc36773841649ece93e40cb97791_Out_0.GetTransformedUV(_TilingAndOffset_ec0b72c6dc7b46abb3dd52264a02036b_Out_3));
        _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0);
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_R_4 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.r;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_G_5 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.g;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_B_6 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.b;
        float _SampleTexture2D_49efec6c30df4e278717cf659af3e805_A_7 = _SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.a;
        float3 _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2;
        Unity_NormalBlend_float((_SampleTexture2D_93f13a49f037470989f426e5ad04d67c_RGBA_0.xyz), (_SampleTexture2D_49efec6c30df4e278717cf659af3e805_RGBA_0.xyz), _NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2);
        float _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0 = _Normal_Stranght;
        float _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2;
        Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_e9573e7724034e4a8c25515bfdb49340_Out_2);
        float2 _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0 = float2(float(0), _ProjectionParams.z);
        float _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3;
        Unity_Remap_float(_Distance_e9573e7724034e4a8c25515bfdb49340_Out_2, _Vector2_e10b20c59ce046dfafd221725b3d0201_Out_0, float2 (1, 0), _Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3);
        float _Power_f267dd9724c74f58953f24eee4860ba9_Out_2;
        Unity_Power_float(_Remap_df36678ebcf74fb5b6a3b2538074fd72_Out_3, float(500), _Power_f267dd9724c74f58953f24eee4860ba9_Out_2);
        float _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3;
        Unity_Lerp_float(float(0), _Property_f474e769f3644eef87425c7c5f9e4ce6_Out_0, _Power_f267dd9724c74f58953f24eee4860ba9_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3);
        float3 _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        Unity_NormalStrength_float(_NormalBlend_008ad006298547c197d5b30d13ec36f1_Out_2, _Lerp_21e18d3aacfa4b21a92e1b5d549fb02e_Out_3, _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2);
        OutVector3_1 = _NormalStrength_7e91d6e98ef74802b98c55be2b3a8fd9_Out_2;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Less_float(float A, float B, out float Out)
        {
            Out = A < B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        struct Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float
        {
        float4 ScreenPosition;
        half4 uv0;
        float3 TimeParameters;
        };
        
        void SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float _DepthScale, float _Depth_Streght, float _Depth_power, float3 _Normal, float _RefractionEnabled, float _Foam_Scale, float _Foam_Speed, float _Foam_Noise_Scale, float _Foam_Noise_Amplitude, float _Foam_Falloff, Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float IN, out float OutVector1_1, out float Depth_2, out float SecondFadeDepth_3, out float FoamDepth_4)
        {
        float _Property_318cdc9ecaed4eadaf06301c7076532f_Out_0 = _RefractionEnabled;
        float4 _ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float3 _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0 = _Normal;
        float3 _Add_356e75099f72430888ad16810e5d286d_Out_2;
        Unity_Add_float3((_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Property_91b13c1e565e4ef08638c23d0fcd9af6_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2);
        float3 _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3;
        Unity_Branch_float3(_Property_318cdc9ecaed4eadaf06301c7076532f_Out_0, _Add_356e75099f72430888ad16810e5d286d_Out_2, (_ScreenPosition_f790d9bafa634f2d8d4ffde1b901b0c0_Out_0.xyz), _Branch_9e2e59e02af84dabb4377a7f18245711_Out_3);
        float _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1;
        Unity_SceneDepth_Eye_float((float4(_Branch_9e2e59e02af84dabb4377a7f18245711_Out_3, 1.0)), _SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1);
        float4 _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0 = IN.ScreenPosition;
        float _Split_16d3558d6d92445a880cb5f6676de872_R_1 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[0];
        float _Split_16d3558d6d92445a880cb5f6676de872_G_2 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[1];
        float _Split_16d3558d6d92445a880cb5f6676de872_B_3 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[2];
        float _Split_16d3558d6d92445a880cb5f6676de872_A_4 = _ScreenPosition_a135bd00653447fbb34e7eec119bd731_Out_0[3];
        float _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0 = _DepthScale;
        float _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2;
        Unity_Add_float(_Split_16d3558d6d92445a880cb5f6676de872_A_4, _Property_5d0fbb1f2bf04a329114eb4fe3103b11_Out_0, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2);
        float _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        Unity_Subtract_float(_SceneDepth_7e7a8203d7624181bc7a32b821fe8866_Out_1, _Add_241efc01de4a4ab38b1cd82db4d80201_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2);
        float _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2;
        Unity_Comparison_Less_float(_Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, float(0.1), _Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2);
        float _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1);
        float4 _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0 = IN.ScreenPosition;
        float _Split_7d45e7abeb8e4d2a97574e613125e070_R_1 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[0];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_G_2 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[1];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_B_3 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[2];
        float _Split_7d45e7abeb8e4d2a97574e613125e070_A_4 = _ScreenPosition_302d4ec7747644ecb95c8a215084bad3_Out_0[3];
        float _Property_0909716a724643ba9aa2fef403343a7d_Out_0 = _DepthScale;
        float _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2;
        Unity_Add_float(_Split_7d45e7abeb8e4d2a97574e613125e070_A_4, _Property_0909716a724643ba9aa2fef403343a7d_Out_0, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2);
        float _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2;
        Unity_Subtract_float(_SceneDepth_a87ad10de1884c7c92d918946c50c773_Out_1, _Add_926ace8dcbdf45dcbeac4da3283de6f7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2);
        float _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3;
        Unity_Branch_float(_Comparison_1d822b724a454bd99cac2cef255c20c7_Out_2, _Subtract_e398ed2aedd04e3e979bad246351b68f_Out_2, _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2, _Branch_ddac7cdb85fe4825bda3abac374df776_Out_3);
        float _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0 = _Depth_Streght;
        float _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2;
        Unity_Multiply_float_float(_Branch_ddac7cdb85fe4825bda3abac374df776_Out_3, _Property_9316f1bcf5d74fdcb480c1766132ff7f_Out_0, _Multiply_c5e61fe354954492921110c4bf3178fd_Out_2);
        float _Saturate_5cc2a092cece487983e25916a82532c4_Out_1;
        Unity_Saturate_float(_Multiply_c5e61fe354954492921110c4bf3178fd_Out_2, _Saturate_5cc2a092cece487983e25916a82532c4_Out_1);
        float _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1;
        Unity_OneMinus_float(_Saturate_5cc2a092cece487983e25916a82532c4_Out_1, _OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1);
        float _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0 = _Depth_power;
        float _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2;
        Unity_Power_float(_OneMinus_62bac7f450834c00afa37f30e3c48b99_Out_1, _Property_7012f7ae38c24b33a2bd6f2aba0b83a3_Out_0, _Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2);
        float _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Unity_OneMinus_float(_Power_4846a8bfb58a4e4fbd635c635aa1e3ce_Out_2, _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1);
        float4 _ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
        float _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1;
        Unity_SceneDepth_Eye_float(_ScreenPosition_2c1f22375dbc436abd5aacd3d3182f34_Out_0, _SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1);
        float4 _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0 = IN.ScreenPosition;
        float _Split_ba379f9dd00c47e89bdaff09775abecb_R_1 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[0];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_G_2 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[1];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_B_3 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[2];
        float _Split_ba379f9dd00c47e89bdaff09775abecb_A_4 = _ScreenPosition_49e76852325647c496c01d6627c68603_Out_0[3];
        float _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0 = _DepthScale;
        float _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2;
        Unity_Add_float(_Split_ba379f9dd00c47e89bdaff09775abecb_A_4, _Property_4d1a91eb2fae4654bec1204bee1bbc73_Out_0, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2);
        float _Subtract_9cdc83575a4441888b548be03402455c_Out_2;
        Unity_Subtract_float(_SceneDepth_392738ecf11e4193971bc1fbce3ad37e_Out_1, _Add_7e0e5eceeab5451abd77c4a1cb2aa4aa_Out_2, _Subtract_9cdc83575a4441888b548be03402455c_Out_2);
        float _Multiply_adb140a84534463c8282fcc1cf533119_Out_2;
        Unity_Multiply_float_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, 5, _Multiply_adb140a84534463c8282fcc1cf533119_Out_2);
        float _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1;
        Unity_Saturate_float(_Multiply_adb140a84534463c8282fcc1cf533119_Out_2, _Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1);
        float _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1;
        Unity_OneMinus_float(_Saturate_41ac47d9a3294bfeb43f00b239c4062f_Out_1, _OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1);
        float _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        Unity_OneMinus_float(_OneMinus_0eed5c943dd648acaf5c0a9c34e3ed27_Out_1, _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1);
        float _Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0 = _Foam_Falloff;
        float _Negate_c1176c2567c04045a1e28135f9db2058_Out_1;
        Unity_Negate_float(_Property_ea7207f3cddd4aeab4b21c3497461b81_Out_0, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1);
        float _Add_df082a7d0dc44ed7947582af57d7db85_Out_2;
        Unity_Add_float(_Subtract_9cdc83575a4441888b548be03402455c_Out_2, _Negate_c1176c2567c04045a1e28135f9db2058_Out_1, _Add_df082a7d0dc44ed7947582af57d7db85_Out_2);
        float _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0 = _Foam_Scale;
        float _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2;
        Unity_Multiply_float_float(_Add_df082a7d0dc44ed7947582af57d7db85_Out_2, _Property_b13a9d01b1234e2e8da971354bdc8d02_Out_0, _Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2);
        float _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1;
        Unity_Saturate_float(_Multiply_86daf70a5b2a4aa0851517c7ef470ea4_Out_2, _Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1);
        float _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1;
        Unity_OneMinus_float(_Saturate_1c88c7e244fc482fbb07cbf460d40163_Out_1, _OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1);
        float _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1;
        Unity_OneMinus_float(_OneMinus_57c63a241bf34527b64492cf7dd71e63_Out_1, _OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1);
        float _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0 = _Foam_Speed;
        float _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2;
        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_03b5d79b6693415ead3a0afd5097bd3d_Out_0, _Multiply_635a6efa292d46ee852700ca8924fd35_Out_2);
        float2 _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3;
        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_635a6efa292d46ee852700ca8924fd35_Out_2.xx), _TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3);
        float _Property_43d4265c5429441fb1d91ad7136782ad_Out_0 = _Foam_Noise_Scale;
        float _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2;
        Unity_SimpleNoise_float(_TilingAndOffset_a5c1d69cef3641b1bee8522806576241_Out_3, _Property_43d4265c5429441fb1d91ad7136782ad_Out_0, _SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2);
        float _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0 = _Foam_Noise_Amplitude;
        float _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2;
        Unity_Multiply_float_float(_SimpleNoise_9b19e4d2c551456d9ce45f173644aba8_Out_2, _Property_c60040290a9f42a3a76e7d8cab20d50c_Out_0, _Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2);
        float _Absolute_20c059810dc244fb9613bea848e93047_Out_1;
        Unity_Absolute_float(_Multiply_cfff3a5af8c142b5972b9bb4a4b91047_Out_2, _Absolute_20c059810dc244fb9613bea848e93047_Out_1);
        float _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2;
        Unity_Add_float(_OneMinus_c58cfe7b63044cc59d8654edc8db4bdd_Out_1, _Absolute_20c059810dc244fb9613bea848e93047_Out_1, _Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2);
        float _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        Unity_Saturate_float(_Add_91bdb4e26ce04907be7fedc94aff5ee1_Out_2, _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1);
        OutVector1_1 = _OneMinus_2bd5ccdcad984ca18ee2539329ed6bbc_Out_1;
        Depth_2 = _Subtract_f671a9a29b1b423ab527ad32cfc84cd8_Out_2;
        SecondFadeDepth_3 = _OneMinus_7ec7f4721f784de495c09f588cee9e49_Out_1;
        FoamDepth_4 = _Saturate_a880a63c40e14e299cd7cc6e63a77fff_Out_1;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0 = _Refraction_Enabled;
            float _Property_f2bba435f69245e29ba364aa15a6246d_Out_0 = _Depth_Strength;
            float _Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0 = _WaveSize;
            UnityTexture2D _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0 = _WaveSpeed;
            float _Property_acee9dd3062c4febbba1a7f48505a892_Out_0 = _WaveSize2;
            float2 _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0 = _WaveSpeed2;
            float _Property_c934b87e11884ee8a832f236aeb6496d_Out_0 = _Normal_Strength;
            Bindings_WaterNormals_6c828002cb0bdf043a8738a67927f033_float _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8.TimeParameters = IN.TimeParameters;
            float3 _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1;
            SG_WaterNormals_6c828002cb0bdf043a8738a67927f033_float(_Property_3a34fc40c2a24602bb9e21a0f0dd0bba_Out_0, _Property_ccea1f2eb02b4896b830f4ed8b941783_Out_0, _Property_4172861e3099428fa6b2b0f4df5850fa_Out_0, _Property_acee9dd3062c4febbba1a7f48505a892_Out_0, _Property_c1dd7ded769b466886c7ee7cbf18aa0d_Out_0, _Property_c934b87e11884ee8a832f236aeb6496d_Out_0, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8, _WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1);
            float _Property_334955ba786b43dc8b8b69068b22e167_Out_0 = _Refraction_Strength;
            float3 _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2;
            Unity_Multiply_float3_float3(_WaterNormals_f9727b1d6ed5433daf47e009c718f6e8_OutVector3_1, (_Property_334955ba786b43dc8b8b69068b22e167_Out_0.xxx), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2);
            float _Property_004ca3e6203d4184986681a4527c2e63_Out_0 = _Refraction_Enabled;
            float _Property_347e4eac494e4fe6892b846c0efc2313_Out_0 = _Foam_Speed;
            float _Property_dcb74838243b4512aa30f059bfa6798b_Out_0 = _Foam_Noise_Scale;
            float _Property_760c8cbb4aba427f8e610388fe099157_Out_0 = _Foam_Noise_Amplitude;
            float _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0 = _Foam_Size;
            Bindings_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float _DepthFade_d12ba53613cd41a2b21fcc4c74833226;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.ScreenPosition = IN.ScreenPosition;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.uv0 = IN.uv0;
            _DepthFade_d12ba53613cd41a2b21fcc4c74833226.TimeParameters = IN.TimeParameters;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3;
            float _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4;
            SG_DepthFade_c3ff2f1ba9a8d8e4d98d2d51336a6722_float(float(0), _Property_f2bba435f69245e29ba364aa15a6246d_Out_0, float(4), _Multiply_a174a8e6b3e7424b9d1a8c682933bb3f_Out_2, _Property_004ca3e6203d4184986681a4527c2e63_Out_0, float(1), _Property_347e4eac494e4fe6892b846c0efc2313_Out_0, _Property_dcb74838243b4512aa30f059bfa6798b_Out_0, _Property_760c8cbb4aba427f8e610388fe099157_Out_0, _Property_ace801e6f0d8466b9b45d86703f34f72_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_Depth_2, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_FoamDepth_4);
            float _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            Unity_Branch_float(_Property_5cbf207b295e4b22b1a7aaff65f838a5_Out_0, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_SecondFadeDepth_3, _DepthFade_d12ba53613cd41a2b21fcc4c74833226_OutVector1_1, _Branch_79a776ac296e4440965d835189b687ba_Out_3);
            surface.Alpha = _Branch_79a776ac296e4440965d835189b687ba_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}