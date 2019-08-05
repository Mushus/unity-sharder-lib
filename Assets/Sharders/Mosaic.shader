Shader "Effect/Mosaic"
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
			};
			
			struct v2f
			{
				float4 vertex  : SV_POSITION;
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
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			sampler2D _BackgroundTexture;

			fixed4 frag (v2f i) : SV_Target
			{
				float mosaicSize = 0.1;
				float4 mosaicPos = float4(
					floor(i.grabPos.x / mosaicSize) * mosaicSize,
					floor(i.grabPos.y / mosaicSize)	* mosaicSize,
					i.grabPos.z,
					i.grabPos.w);
				half4 bgcolor = tex2Dproj(_BackgroundTexture, mosaicPos);
				return bgcolor;
			}
			ENDCG
		}
	}
}