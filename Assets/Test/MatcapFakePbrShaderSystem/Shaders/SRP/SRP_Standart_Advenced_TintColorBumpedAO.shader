
Shader "3dArthings/SRP/Standart/Advanced/TintColorBumpedAO"
{
	Properties
	{
		_MainColor("MainColor", Color) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "white" {}
		_AOMap("AOMap", 2D) = "white" {}
		_AOIntensity("AOIntensity", Float) = 0
		_Brightness("Brightness", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _AOMap;
		uniform float4 _AOMap_ST;
		uniform float4 _MainColor;
		uniform float _AOIntensity;
		uniform float _Brightness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float4 tex2DNode51 = tex2D( _NormalMap, uv_NormalMap );
			float4 NormalTexture56 = tex2DNode51;
			o.Normal = NormalTexture56.rgb;
			float2 uv_AOMap = i.uv_texcoord * _AOMap_ST.xy + _AOMap_ST.zw;
			float4 blendOpSrc52 = tex2D( _AOMap, uv_AOMap );
			float4 blendOpDest52 = _MainColor;
			float4 lerpBlendMode52 = lerp(blendOpDest52,( blendOpSrc52 * blendOpDest52 ),_AOIntensity);
			float4 temp_output_52_0 = ( saturate( lerpBlendMode52 ));
			o.Albedo = temp_output_52_0.rgb;
			float4 color58 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float4 lerpResult57 = lerp( color58 , temp_output_52_0 , _Brightness);
			o.Emission = lerpResult57.rgb;
			float temp_output_61_0 = 0.0;
			o.Metallic = temp_output_61_0;
			o.Smoothness = temp_output_61_0;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
