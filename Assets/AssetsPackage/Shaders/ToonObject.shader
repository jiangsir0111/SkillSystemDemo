Shader "Kiif/Other/ToonObject" {
	Properties{
		[HDR]_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_EmissionTex("Emission Texture", 2D) = "black" {}
		_EmissionIntensity("Emission Intensity", Range(0, 5)) = 2.1
		_ShadowColor("Shadow Color", Color) = (0.7654859,0.8223484,0.8867924,1)
		[HDR]_BrightColor("Bright Color", Color) = (1,0.911791,0.9009434,1)
		[HDR]_RimColor("Rim Color", Color) = (0.5,0.5,0.5,0)
		[HDR]_LightColor("Light Color", Color) = (1.164272, 1.200494, 1.319508, 1)
		_LightPos("Light Position", Vector) = (-1000, 100, -1000, 0)
		_ShadowRange("Shadow Range", Range(0.01, 1)) = 0.45
		[HDR]_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_Specular("Specular", Range(0, 1)) = 0.1
		_Shininess("Shininess", Range(0.01, 1)) = 0.4
		_RimWidth("Rim Width", Range(0, 3)) = 1
		[Toggle]_Bloom("Bloom Effect",float) = 0
		[HDR]_BloomColor("Bloom Color", Color) = (1, 1, 1, 1)
		_OutlineWidth("Outline Width", Range(0,0.1)) = 0.005
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		
	}

		SubShader{
			Tags{ "Queue" = "Transparent-1" "RenderType" = "Opaque" }
			LOD 200

			//渲染正常的Pass
			Pass
			{
				//Blend SrcAlpha OneMinusSrcAlpha
				Cull Off
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"


				sampler2D _MainTex,_EmissionTex;
				fixed4 _MainTex_ST;
				fixed4 _Color;
				fixed4 _LightColor;
				fixed4 _LightPos;
				half _EmissionIntensity;
				fixed _RimWidth;
				fixed _Bloom;
				fixed _Specular;
				float _Shininess;
				fixed _ShadowRange;
				fixed4 _ShadowColor;
				fixed4 _BrightColor;
				fixed4 _RimColor;
				fixed4 _BloomColor;
				fixed4 _SpecularColor;

				struct appdata 
				{
					float4 vertex : POSITION;
					float4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float3 normal : NORMAL;
				};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				fixed3 normal : TEXCOORD0;
				float3 posWorld : TEXCOORD1;
				float3 normal2 : TEXCOORD2;
				float2 texcoord : TEXCOORD3;
				float3 viewDir : TEXCOORD4;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.normal = v.normal;	//主要的normal，用于光照等
				o.normal2 = mul(v.normal, (float3x3)unity_WorldToObject);		//用于fresnel的normal，与视野方向垂直，用于边缘发光；
				o.posWorld = /*mul(unity_ObjectToWorld,*/ v.vertex/*)*/;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				return o;
			}

			float4 frag(v2f i) :SV_Target
			{
				fixed3 normalDir = normalize(i.normal);		//主要的normal，用于光照等
				fixed3 normalDir2 = normalize(i.normal2);	//用于fresnel的normal，与视野方向垂直，用于边缘发光；
				half4 maintex = tex2D(_MainTex, i.texcoord);

				fixed shadowWidth = 0.1;

				//需要将模拟光源的点设置成模型空间的坐标，然后减去模型空间的点的位置，则返回模型空间中点到光源的方向向量
				//光照方向模拟
				fixed3 lightDir = normalize(mul((float3x3)unity_WorldToObject, _LightPos.xyz) - i.posWorld.xyz);
				fixed3 viewDir = normalize(i.viewDir);

				//阴影边缘硬化的主要代码	
				half d = dot(normalDir, lightDir) * 0.5 + 0.5;
				//因为没有光照，所以没有阴影部分了，所以这个shader不支持阴影
				half4 c = fixed4(maintex.rgb * _Color.rgb, _Color.a);
				c.rgb *= _LightColor.rgb;
				if (d < _ShadowRange)
					c.rgb *= _ShadowColor;
				else if (d >= _ShadowRange && d < _ShadowRange + shadowWidth)
					c.rgb *= lerp(_ShadowColor, _BrightColor, (d - _ShadowRange) / shadowWidth);
				else
					c.rgb *= _BrightColor;


				//边缘发光，主要用于boss或者人物释放技能时可以发光
				half rim = 1.0 - saturate(dot(viewDir, normalDir2));
				c.rgb = c.rgb + _RimColor.rgb * pow(rim, _RimWidth) * _RimColor.a;

				//高光
				fixed nh = saturate(dot(normalDir, lightDir));
				if (rim > 0.7 && nh > _Shininess)
					c.rgb += (_SpecularColor.rgb * _Specular);

				//发光
				fixed4 emission = tex2D(_EmissionTex, i.texcoord) * _EmissionIntensity;
				if (emission.a > 0)
					c.rgb = emission;


				if (_Bloom && d > 0.8 && rim > 0.6)
					c.rgb += _BloomColor;

				return c * i.color;
			}
				ENDCG
		}

			//渲染描边的Pass
			Pass
			{
				Cull Front
				Offset 50,50


				CGPROGRAM
				#include "UnityCG.cginc"
				#pragma vertex vert
				#pragma fragment frag

				fixed _OutlineWidth;
				fixed4 _OutlineColor;

				struct v2f
				{
					float4 pos : SV_POSITION;
				};

				v2f vert(appdata_full v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
					float2 offset = TransformViewToProjection(vnormal.xy);
					o.pos.xy += offset * _OutlineWidth;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					return _OutlineColor;
				}
				ENDCG
			}
		}

			Fallback "Diffuse"
}
