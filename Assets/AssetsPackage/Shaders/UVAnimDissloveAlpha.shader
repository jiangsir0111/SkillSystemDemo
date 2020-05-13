Shader "Kiif/Particle/UVAnimDissolveAlpha"
{
	Properties
	{
		[HDR]_Color("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Particle Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "white" {}
		_DissolveTex("Dissolve Texture", 2D) = "white" {}
		_UVSpeed("UVSpeed(X:U  Y:V)", vector) = (0, 0, 0, 0)
		[Toggle]_UVon("UV On",float) = 0
		[Toggle]_Dissolve("Dissolve On",float) = 0
	}

		SubShader
		{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off Lighting Off ZWrite Off

			Pass
			{

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _MainTex, _MaskTex, _DissolveTex;
				fixed4 _Color, _UVSpeed;
				float4 _MainTex_ST, _DissolveTex_ST;
				fixed _UVon, _Dissolve;

				struct appdata_t
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					fixed4 uv1 : TEXCOORD0;
					float2 uv : TEXCOORD1;
				};

				struct v2f
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					fixed4 uv1 : TEXCOORD0;
					float2 uv : TEXCOORD1;
				};

				v2f vert(appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.uv = v.uv;
					o.uv1 = v.uv1;
					return o;
				}

				fixed4 frag(v2f i) : COLOR
				{
					float2 uv = float2(i.uv.x + _UVSpeed.x * _Time.g, i.uv.y + _UVSpeed.y * _Time.g);
					if (_UVon)
						uv = float2(i.uv1.z, i.uv1.w) + i.uv;
					fixed4 mask = tex2D(_MaskTex, TRANSFORM_TEX(i.uv, _MainTex));
					fixed4 main = tex2D(_MainTex, TRANSFORM_TEX(uv, _MainTex));

					fixed dissolve = 1;
					if (_Dissolve)
					{
						dissolve = tex2D(_DissolveTex, TRANSFORM_TEX(i.uv, _DissolveTex)).r;
						dissolve = step(i.uv1.x, dissolve);
					}

					return fixed4(main.rgb * _Color.rgb * i.color.rgb, main.a * main.r * i.color.a * mask.r * dissolve);
				}
				ENDCG
			}
		}
}
