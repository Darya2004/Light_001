
Shader "3dArthings/SRP/MatcapFakePBR/Advanced/BlendTintColor"
{
	Properties
	{
		_MainTexture01("MainTexture01", 2D) = "white" {}
		_MainTexture02("MainTexture02", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "white" {}
		_AOMap("AOMap", 2D) = "white" {}
		_AOIntensity("AOIntensity", Range( 0 , 1)) = 0
		_BlendTextures("Blend Textures", Range( 0 , 1)) = 0
		[Toggle]_DesaturateIT("Desaturate IT", Float) = 0
		[Toggle]_ActivateTINT("Activate TINT", Float) = 0
		_TintColor("TintColor", Color) = (0,0,0,0)
		_TintIntensity1("TintIntensity", Range( 0 , 1)) = 0
		_Brightness("Brightness", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _AOMap;
		uniform float4 _AOMap_ST;
		uniform float _ActivateTINT;
		uniform float _DesaturateIT;
		uniform sampler2D _MainTexture01;
		uniform sampler2D _MainTexture02;
		uniform float _BlendTextures;
		uniform float4 _TintColor;
		uniform float _TintIntensity1;
		uniform float _AOIntensity;
		uniform float _Brightness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float4 tex2DNode69 = tex2D( _NormalMap, uv_NormalMap );
			float4 NormalTexture70 = tex2DNode69;
			o.Normal = NormalTexture70.rgb;
			float2 uv_AOMap = i.uv_texcoord * _AOMap_ST.xy + _AOMap_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 temp_output_68_0 = ( tex2DNode69 + float4( ase_worldNormal , 0.0 ) );
			float4 lerpResult47 = lerp( tex2D( _MainTexture01, ( ( mul( UNITY_MATRIX_V, temp_output_68_0 ) * 0.5 ) + 0.5 ).rg ) , tex2D( _MainTexture02, ( ( mul( UNITY_MATRIX_V, temp_output_68_0 ) * 0.5 ) + 0.5 ).rg ) , _BlendTextures);
			float3 desaturateInitialColor59 = lerpResult47.rgb;
			float desaturateDot59 = dot( desaturateInitialColor59, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar59 = lerp( desaturateInitialColor59, desaturateDot59.xxx, 1.0 );
			float4 blendOpSrc57 = (( _DesaturateIT )?( float4( desaturateVar59 , 0.0 ) ):( lerpResult47 ));
			float4 blendOpDest57 = _TintColor;
			float4 lerpResult75 = lerp( (( _DesaturateIT )?( float4( desaturateVar59 , 0.0 ) ):( lerpResult47 )) , ( saturate( (( blendOpDest57 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest57 ) * ( 1.0 - blendOpSrc57 ) ) : ( 2.0 * blendOpDest57 * blendOpSrc57 ) ) )) , _TintIntensity1);
			float4 blendOpSrc62 = tex2D( _AOMap, uv_AOMap );
			float4 blendOpDest62 = (( _ActivateTINT )?( lerpResult75 ):( (( _DesaturateIT )?( float4( desaturateVar59 , 0.0 ) ):( lerpResult47 )) ));
			float lerpResult63 = lerp( 0.0 , 2.0 , _AOIntensity);
			float4 lerpBlendMode62 = lerp(blendOpDest62,( blendOpSrc62 * blendOpDest62 ),lerpResult63);
			float4 temp_output_62_0 = ( saturate( lerpBlendMode62 ));
			o.Albedo = temp_output_62_0.rgb;
			float4 color51 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float lerpResult52 = lerp( 0.0 , 2.0 , _Brightness);
			float4 lerpResult50 = lerp( color51 , temp_output_62_0 , lerpResult52);
			o.Emission = lerpResult50.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
