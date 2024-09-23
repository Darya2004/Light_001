
Shader "3dArthings/SRP/MatcapFakePBR/Simple/TintColor"
{
	Properties
	{
		_MainTexture("MainTexture", 2D) = "white" {}
		[Toggle]_DesaturateIt("Desaturate It!", Float) = 0
		[Toggle]_ActivateTINT("Activate TINT", Float) = 0
		_TintColor("TintColor", Color) = (0,0,0,0)
		_TintIntensity("TintIntensity", Range( 0 , 1)) = 0
		_Brightness("Brightness", Range( 0 , 1)) = 0.5
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
		struct Input
		{
			float3 worldNormal;
		};

		uniform float _ActivateTINT;
		uniform float _DesaturateIt;
		uniform sampler2D _MainTexture;
		uniform float4 _TintColor;
		uniform float _TintIntensity;
		uniform float _Brightness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float4 tex2DNode1 = tex2D( _MainTexture, ( ( mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz * 0.5 ) + 0.5 ).xy );
			float3 desaturateInitialColor57 = tex2DNode1.rgb;
			float desaturateDot57 = dot( desaturateInitialColor57, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar57 = lerp( desaturateInitialColor57, desaturateDot57.xxx, 1.0 );
			float4 blendOpSrc60 = (( _DesaturateIt )?( float4( desaturateVar57 , 0.0 ) ):( tex2DNode1 ));
			float4 blendOpDest60 = _TintColor;
			float4 lerpResult62 = lerp( (( _DesaturateIt )?( float4( desaturateVar57 , 0.0 ) ):( tex2DNode1 )) , ( saturate( (( blendOpDest60 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest60 ) * ( 1.0 - blendOpSrc60 ) ) : ( 2.0 * blendOpDest60 * blendOpSrc60 ) ) )) , _TintIntensity);
			float4 temp_output_49_0 = (( _ActivateTINT )?( lerpResult62 ):( (( _DesaturateIt )?( float4( desaturateVar57 , 0.0 ) ):( tex2DNode1 )) ));
			o.Albedo = temp_output_49_0.rgb;
			float4 color52 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float lerpResult56 = lerp( 0.0 , 2.0 , _Brightness);
			float4 lerpResult51 = lerp( color52 , (( _ActivateTINT )?( lerpResult62 ):( (( _DesaturateIt )?( float4( desaturateVar57 , 0.0 ) ):( tex2DNode1 )) )) , lerpResult56);
			o.Emission = lerpResult51.rgb;
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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = IN.worldNormal;
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
