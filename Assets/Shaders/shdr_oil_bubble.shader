Shader "av/surface/shdr_oil_bubble" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_FresnelMap ("Fresnel", 2D) = "white" {}
		_FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
		_FresnelPow ("Fresnel Power", Range(0.5, 20.0)) = 15.0
		tex_dispersion("dispersion", 2D) = "black" {}
		tessel_size ("tessel_size", Range(0.0, 100.0)) = 0.0
		disp_height ("disp_height", Range(0.0, 10.0)) = 0.0
	}
	SubShader {
//		Cull Off
//		ZWrite Off
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade vertex:disp tessellate:tessEdge
		#include "Tessellation.cginc"

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		 
		float tessel_size;
		float disp_height;

		sampler2D _MainTex;
		sampler2D _FresnelMap;
		sampler2D tex_dispersion;

		half _Glossiness;
		half _Metallic;
		float _FresnelPow;
		fixed4 _FresnelColor;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
			float3 worldNormal;
		};

		struct appdata {
	        float4 vertex : POSITION;
	        float4 tangent : TANGENT;
	        float3 normal : NORMAL;
	        float2 texcoord : TEXCOORD0;
	        float2 texcoord1 : TEXCOORD1;
		};
		 
		sampler2D _ParallaxMap;

		float4 tessEdge (appdata v0, appdata v1, appdata v2){
            return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, tessel_size);
        }
		 
		void disp (inout appdata v){
		        fixed4 rgb = tex2Dlod(tex_dispersion, float4(v.texcoord.xy,0,0));
		        float d = (-rgb.r*.6 + rgb.b*1.) * disp_height;
//		        v.vertex.xyz += (v.normal) * d;
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float4 cam = tex2D(_FresnelMap, IN.uv_MainTex);
			float4 dispersion = tex2D(tex_dispersion, IN.uv_MainTex);

			// color adjustment
			float4 nd = dispersion;
			nd.r = dispersion.r;
			nd.g = dispersion.g*2. + dispersion.b*3.;
			nd.b = dispersion.g*3. + dispersion.b*5. + dispersion.r*.3;

			o.Albedo = c.rgb + nd.rgb;
			o.Metallic = _Metallic * cam.rgb - nd.rgb;
			o.Smoothness = _Glossiness - nd;

			float alpha = c.a - nd.g * 10.;
			alpha = clamp(alpha, 0.3, 1.0);
			o.Alpha = alpha;

			half fresnel = pow(1.0 - saturate(dot(normalize(IN.viewDir), IN.worldNormal)), _FresnelPow);
			float4 fresnel_c = _FresnelColor * cam * nd;
			o.Emission = fresnel_c * fresnel + float4(nd.r,0,nd.b*.6,0) * 5.;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
