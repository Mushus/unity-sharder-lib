Shader "Particles/KuruFuwa"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		LOD 100
		Blend One One
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#define PI 3.14159265357879

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float id: TEXCOORD0;
			};

			struct vsout
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 color : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			appdata vert (appdata v, uint vid: SV_VertexID)
			{
				v.id = vid;
				return v;
			}

			float rand(float2 uv) {
				return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
			}
			float randuv(float u, float v) {
				return fmod(rand(float2(u, v)) + u * 0.123 + v * 0.456, 1);
			}

			float3 hsv2rgb(float3 hsv)
			{
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);
				return hsv.z * lerp(K.xxx, saturate(p - K.xxx), hsv.y);
			}

			[maxvertexcount(96)]
		   	void geom (triangle appdata input[3], inout TriangleStream<vsout> outStream)
			{
				float2 uvoffset[6] = {
					float2(0, 0),
					float2(0, 1),
					float2(1, 0),
					float2(0, 1),
					float2(1, 0),
					float2(1, 1)
				};
				float3 offset[6] = {
					float3(-1, -1, 0),
					float3(-1,  1, 0),
					float3( 1, -1, 0),
					float3(-1,  1, 0),
					float3( 1, -1, 0),
					float3( 1,  1, 0)
				};
				float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);

				for (int k = 0; k < 16; k++) {
					float seedx = input[0].id + input[1].id * input[2].id * 0.1 + k * 10 + input[0].vertex.x;
					float seedy = input[0].id * input[1].id + input[2].id * 0.1 + k * 10 + input[0].vertex.y;
					int randOffset = k * 10 * seedy;
					float time = _Time.y * 1;
					float angle = time * (1 + randuv(seedx, seedy + 2) * 2) * (10 + k) * 0.1;
					float z = randuv(seedx, seedy + 0) * 2 - 1;
					float phi = randuv(seedx, seedy + 1) * PI * 2;
					float x = sqrt(1 - z * z) * cos(phi + angle);
					float y = sqrt(1 - z * z) * sin(phi + angle);
					float orbit = 0.5 + randuv(seedx, 4 + seedy);
					float size = (0.2 + randuv(seedx, 5 + seedy)) * 0.4;
					float3 color = hsv2rgb(float3(randuv(seedx, 6 + seedy), 1, 1));
					float3 center = float3(x, z, y) * orbit * 5;
					float4 centerView = UnityObjectToClipPos(center);
					for (int i = 0 ; i < 6; i++)
					{
						vsout o;
						float3 vpos = mul((float3x3)unity_ObjectToWorld, offset[i] * size);
						float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
						o.vertex = mul(UNITY_MATRIX_P, viewPos) + centerView;
						o.uv = uvoffset[i];
						o.color = color;
						outStream.Append(o);
						if (fmod(i, 3) + 1 == 0) {
							outStream.RestartStrip();
						}
					}
					outStream.RestartStrip();
				}
		   	}

			fixed4 frag (vsout i) : SV_Target
			{
				return tex2D(_MainTex, i.uv) * float4(i.color.r, i.color.g, i.color.b, 1) * 0.3;
			}
			ENDCG
		}
	}
}
