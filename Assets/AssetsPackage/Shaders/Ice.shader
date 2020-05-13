Shader "Kiif/Particle/Ice" 
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		[HDR]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		_FresnelIndensity("Fresnel Indensity", float) = 1
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 100
		
		Cull Back
		//ZWrite Off

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed _FresnelIndensity;
			float4 _Color, _MainTex_ST, _FresnelColor;
			sampler2D _MainTex;

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

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.normalDir = mul(v.normal, (float3x3)unity_WorldToObject);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;

				float3 normalDir = normalize(i.normalDir);
				float3 viewDir = normalize(i.viewDir);

				fixed4 fresnel = pow(1 - dot(normalDir, viewDir), _FresnelIndensity) * _FresnelColor;

				return (col + fresnel) * i.color;
				//return fixed4((col.rgb * _Color.rgb + fresnel.rgb) * i.color.rgb, col.a + _Color.a + i.color.a);
			}
			ENDCG
		}


		//Pass
		//{
		//	Blend One One

		//	CGPROGRAM
		//	#pragma vertex vert
		//	#pragma fragment frag
		//	#include "UnityCG.cginc"

		//	fixed _FresnelIndensity;
		//	float4 _Color, _MainTex_ST, _FresnelColor;
		//	sampler2D _MainTex;

		//	struct appdata
		//	{
		//		float4 vertex : POSITION;
		//		float4 color : COLOR;
		//		float2 uv : TEXCOORD0;
		//		float3 normal : NORMAL;
		//	};

		//	struct v2f
		//	{
		//		float2 uv : TEXCOORD0;
		//		float4 vertex : SV_POSITION;
		//		float4 color : COLOR;
		//		float3 normalDir : TEXCOORD1;
		//		float3 viewDir : TEXCOORD2;
		//	};

		//	v2f vert(appdata v)
		//	{
		//		v2f o;
		//		o.vertex = UnityObjectToClipPos(v.vertex);
		//		o.color = v.color;
		//		o.normalDir = mul(v.normal, (float3x3)unity_WorldToObject);
		//		o.viewDir = WorldSpaceViewDir(v.vertex);
		//		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		//		return o;
		//	}

		//	fixed4 frag(v2f i) : SV_Target
		//	{
		//		fixed4 col = tex2D(_MainTex, i.uv) * _Color * i.color;

		//		float3 normalDir = normalize(i.normalDir);
		//		float3 viewDir = normalize(i.viewDir);

		//		fixed4 fresnel = pow(1 - dot(normalDir, viewDir), _FresnelIndensity) * _FresnelColor;

		//		return (col + fresnel) * i.color;
		//		//return fixed4((col.rgb * _Color.rgb + fresnel.rgb) * i.color.rgb, col.a + _Color.a + i.color.a);
		//	}
		//	ENDCG
		//}
	}
}
