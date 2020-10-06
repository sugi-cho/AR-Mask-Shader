Shader "Unlit/TransparentMask"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Power("rim power", Float) = 2
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
		LOD 100 ZWrite Off
		GrabPass{"_CameraTransparentTexture"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 gPos : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex, _CameraTransparentTexture;
			float4 _MainTex_ST;
			half _Power;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.gPos = ComputeGrabScreenPos(o.vertex);
				o.normal = mul((float3x3)UNITY_MATRIX_V, UnityObjectToWorldNormal(v.normal));
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half rim = 1 - saturate(dot(i.normal, float3(0,0,1)));
				rim = pow(rim, _Power);
				half mask = tex2D(_MainTex, i.uv);

				half2 gUV = i.gPos.xy / i.gPos.w;
				half4 col = tex2D(_CameraTransparentTexture, gUV);
				col = lerp(col, col * rim, mask);

				return col;
			}
			ENDCG
		}
	}
}
