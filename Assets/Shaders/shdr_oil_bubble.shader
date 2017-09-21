Shader "av/surface/shdr_oil_bubble" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_FresnelMap ("Fresnel", 2D) = "white" {}
		_FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
		_FresnelPow ("Fresnel Power", Range(0.5, 8.0)) = 3.0
		tex_dispersion("dispersion", 2D) = "black" {}
	}
	SubShader {
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
			float3 worldNormal;
		};

		sampler2D _MainTex;
		sampler2D _FresnelMap;
		sampler2D tex_dispersion;

		half _Glossiness;
		half _Metallic;
		float _FresnelPow;
		fixed4 _FresnelColor;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float4 cam = tex2D(_FresnelMap, IN.uv_MainTex);
			cam = pow(cam, 3.);
			float4 dispersion = tex2D(tex_dispersion, IN.uv_MainTex);
			dispersion = pow(dispersion, 2.) * 15.;

//			float4 cloud = dispersion;
//			cloud.r = cloud.b = cloud.g;

			half fresnel = pow(1.0 - saturate(dot(normalize(IN.viewDir), IN.worldNormal)), _FresnelPow);
			float4 fresnel_c = _FresnelColor * cam * dispersion;

			o.Albedo = c.rgb + dispersion.rgb;// - cloud.rgb;
			o.Metallic = _Metallic * cam.rgb;// - cloud.rgb;
			o.Smoothness = _Glossiness;
			o.Emission = fresnel_c * fresnel;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
