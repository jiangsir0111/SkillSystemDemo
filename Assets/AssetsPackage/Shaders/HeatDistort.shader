Shader "Kiif/Particle/HeatDistort" {
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_DistortIntensity("Distort Intensity", Range(0.001, 10)) =  1
	}
		SubShader
		{
			Tags{"RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent +1000"}
			Cull Off

			Pass
			{
				ZWrite On
				ColorMask 0
			}

			GrabPass
			{
				"_GrabTempTex"
			}

			Pass
			{
				ZWrite Off
				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _GrabTempTex,_MainTex;
				float4 _GrabTempTex_ST,_MainTex_ST;
				half _DistortIntensity;

				struct appdata
				{
					fixed4 vertex : POSITION;
					fixed4 color : COLOR;
					fixed2 uv : TEXCOORD0;
				};

				struct v2f
				{
					fixed4 pos : SV_POSITION;
					fixed4 color : COLOR;
					fixed4 grabPos : TEXCOORD0;
					fixed2 uv : TEXCOORD1;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.grabPos = ComputeGrabScreenPos(o.pos);
					o.uv = TRANSFORM_TEX(v.uv,_MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 main = tex2D(_MainTex,i.uv);
					half offset = main.a * main.r * i.color.a * _DistortIntensity;
					fixed4 uvOffset = fixed4(offset,offset,offset,offset);
					fixed4 color = tex2Dproj(_GrabTempTex, i.grabPos + uvOffset);
					
					return color;
				}
				ENDCG
			}
		}
	FallBack "Mobile/Particles/Additive"
}
