Shader "Unlit/AttackRange"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _MiddleAlpha("MiddleAlpha", Float) = 0.5
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        LOD 100

        ZWrite Off 
        Blend SrcAlpha OneMinusSrcAlpha
        BlendOp Add

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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 localPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _MiddleAlpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.localPos = v.vertex.xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                //float alpha = pow(i.localPos.x, 2) + pow(i.localPos.z, 2); // linear fading alpha
                // Quadratic Bezier curves for the alpha
                float t = clamp(pow(i.localPos.x, 2) + pow(i.localPos.z, 2), 0, 1); // parameter t from [0, 1]
                float one_minus_t = 1 - t;
                float temp = 2 * one_minus_t * t * _MiddleAlpha + pow(one_minus_t, 2);
                return fixed4(_Color.xyz, 1 - temp);
            }
            ENDCG
        }
    }
}
