Shader "Kiif/Other/Fresnel" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_FresnelIndensity("Fresnel Indensity", Range(0, 2)) = 1
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent+1" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 100
		Blend SrcAlpha One

		Pass
		{
			Tags{ "LightMode=" = "Forward" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float3 normalDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			float _FresnelIndensity;
			float4 _Color;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.normalDir = mul(v.normal, (float3x3)unity_WorldToObject);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 normalDir = normalize(i.normalDir);
				float3 viewDir = normalize(i.viewDir);

				float4 col = _Color * i.color;
				float Fresnel = pow(1 - dot(normalDir, viewDir), _FresnelIndensity);

				return col * Fresnel;
			}
			ENDCG
		}
	}
}
