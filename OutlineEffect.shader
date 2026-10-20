Shader "TinyRestaurant/OutlineEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _PivotUV("Pivot UV", Vector) = (0.5, 0, 0, 0)
        _Distance("Outline Distance", Range(0, 1)) = 1
        _OutlineColor("Outline Color", Color) = (0,1,0,1)
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color * _Color;
                return o;
            }

            sampler2D _MainTex;
            float4 _PivotUV;
            float _Distance;
            float4 _MainTex_TexelSize;
            fixed4 _OutlineColor;

            // for pixel-art
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 original = tex2D(_MainTex, i.uv) * i.color;
                fixed originalMask = original.a > 0.001 ? 1.0 : 0.0;

                // using "erosion" idea
                fixed erodedMask = 1.0;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 offset = float2(x, y) * _MainTex_TexelSize.xy * max(0.0, _Distance);
                        float2 sampleUV = i.uv + offset;
                        fixed alpha = 0.0;

                        if (sampleUV.x >= 0.0 && sampleUV.x <= 1.0 && sampleUV.y >= 0.0 && sampleUV.y <= 1.0)
                            alpha = tex2D(_MainTex, sampleUV).a;

                        if (alpha <= 0.001) erodedMask = 0.0;
                    }
                }

                fixed mask = max(0.0, originalMask - erodedMask);

                if (mask > 0.0) return _OutlineColor;
                return original;
                //return fixed4(0, 0, 0, 0);
            }
            ENDCG
        }
    }
}
