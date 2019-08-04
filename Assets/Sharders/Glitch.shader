Shader "Effect/Glitch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags {
			"Queue" = "Transparent"
		}
		LOD 100

		GrabPass
        {
            "_BackgroundTexture"
        }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex  : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 grabPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;

				float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
				float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
				float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
				o.vertex = mul(UNITY_MATRIX_P, viewPos);
				o.vertex.z = 1;
				o.uv = v.uv;
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			sampler2D _BackgroundTexture;
			
			float rand(float2 uv) {
				return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half4 bgcolor = tex2Dproj(_BackgroundTexture, i.grabPos);
				float2 uv = i.uv;
				float4 grabPos = i.grabPos;
				for (int i = 0; i < 5; i++) {
					float phase = floor(_Time.y * (10 + 0.1 * i));
					float seedOffset = i * 1.23456;
					float2 pos = float2(
						rand(float2(phase, 0 + seedOffset)),
						rand(float2(phase, 1 + seedOffset))
					);
					float2 halfSize = float2(
						rand(float2(phase, 2 + seedOffset)) * 0.5,
						rand(float2(phase, 3 + seedOffset)) * 0.05 + 0.05
					);
					bool isGlitch =
						pos.x + halfSize.x > uv.x &&
						pos.x - halfSize.x < uv.x &&
						pos.y + halfSize.y > uv.y &&
						pos.y - halfSize.y < uv.y;
					if (isGlitch) {
						float glitchType = rand(float2(phase, 5 + seedOffset));
						if (glitchType < 0.3) {
							float4 delta = float4(rand(float2(_Time.y, 6 + uv.y + seedOffset)) * 0.1 - 0.05, 0, 0, 0);
							bgcolor = tex2Dproj(_BackgroundTexture, grabPos + delta);
						} else if (glitchType < 0.6) {
							float4 delta = float4(rand(float2(phase, 6 + seedOffset)) * 0.2 - 0.1, 0, 0, 0);
							bgcolor = tex2Dproj(_BackgroundTexture, grabPos + delta);
						} else if (glitchType < 0.7) {
							float4 delta = float4(rand(float2(_Time.y, 6 + uv.y + seedOffset)) * 0.2 - 0.1, 0, 0, 0);
							bgcolor.r = tex2Dproj(_BackgroundTexture, grabPos + delta).r;
						} else if (glitchType < 0.8) {
							float4 delta = float4(rand(float2(_Time.y, 6 + uv.y + seedOffset)) * 0.2 - 0.1, 0, 0, 0);
							bgcolor.g = tex2Dproj(_BackgroundTexture, grabPos + delta).g;
						} else if (glitchType < 0.9) {
							float4 delta = float4(rand(float2(_Time.y, 6 + uv.y + seedOffset)) * 0.2 - 0.1, 0, 0, 0);
							bgcolor.b = tex2Dproj(_BackgroundTexture, grabPos + delta).b;
						} else if (glitchType < 0.95) {
							bgcolor = half4(1, 1, 1, 2) - bgcolor;
						} else {
							bgcolor = half4(0, 0, 0, 1);
						}
					}
				}
				return bgcolor;
			}
			ENDCG
		}
	}
}