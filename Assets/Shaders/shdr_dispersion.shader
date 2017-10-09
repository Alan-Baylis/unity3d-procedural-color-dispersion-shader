Shader "av/unlit/unlit_ar_stream_dispersed"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D tex_cam_stream;
			sampler2D tex_noise;
			float4 _MainTex_ST;
			int is_init;

			float4 advect(sampler2D _tex, float2 _uv, float2 _dir, float _texel){
				//https://www.shadertoy.com/view/MsyXRW
				const float _G0 = .25;
				const float _G1 = .125;
				const float _G2 = .0625;
				const float ADVECT_DIST = 2.;

				float2 uv = _uv - _dir * ADVECT_DIST * _texel;

				float2 n  = float2( 0., 1.);
				float2 ne = float2( 1., 1.);
				float2 e  = float2( 1., 0.);
				float2 se = float2( 1.,-1.);
				float2 s  = float2( 0.,-1.);
				float2 sw = float2(-1.,-1.);
				float2 w  = float2(-1., 0.);
				float2 nw = float2(-1., 1.);

				float4 c =    tex2D(_tex, frac(uv));
				float4 c_n =  tex2D(_tex, frac(uv+_texel*n));
				float4 c_e =  tex2D(_tex, frac(uv+_texel*e));
				float4 c_s =  tex2D(_tex, frac(uv+_texel*s));
				float4 c_w =  tex2D(_tex, frac(uv+_texel*w));
				float4 c_nw = tex2D(_tex, frac(uv+_texel*nw));
				float4 c_sw = tex2D(_tex, frac(uv+_texel*sw));
				float4 c_ne = tex2D(_tex, frac(uv+_texel*ne));
				float4 c_se = tex2D(_tex, frac(uv+_texel*se));

				return _G0*c+_G1*(c_n+c_e+c_w+c_s)+_G2*(c_nw+c_sw+c_ne+c_se);
			}
			
			float4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv;
				float texel = 1./1024.;
				float2 advt_dir = tex2D(tex_noise, frac(uv - _Time * .1)).rg * 290.0f;

				float3 cam = advect(tex_cam_stream, uv, advt_dir, texel).rgb;
				float3 noise = advect(tex_noise, uv, advt_dir, texel).grb;

				float3 c = normalize(cam + noise);

				if(is_init == 0) 
					c = cam;

				c = clamp(c, float3(0, 0, 0), float3(1.0f, 1.0f, 1.0f));
				c = pow(c, 10.);

				return float4(c.rbg,1);
			}
			ENDCG
		}
	}
}
