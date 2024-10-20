Shader "BeatLeader/UIAdditiveGlow"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Cull Off
        ZWrite Off
        BlendOp Add
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "utils.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv0 : TEXCOORD;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 avatar_uv : TEXCOORD0;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float _FakeBloomAmount;

            v2f vert (const appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(get_curved_position(v.vertex, v.uv2.x));
                o.avatar_uv = v.uv0;
                o.color = v.color;
                return o;
            }

            float4 frag (const v2f i) : SV_Target
            {
                const float4 tex = tex2D(_MainTex, i.avatar_uv);
                
                const float alpha = min(i.color.a, 0.5f) * 2 * tex.a;
                const float glow = max(i.color.a - 0.5f, 0) * 2 * tex.a;
                
                float4 col = float4(i.color.rgb * tex.rgb, glow);
                col.rgb *= alpha;
                return apply_fake_bloom(col, 0.6f * _FakeBloomAmount);
            }
            ENDCG
        }
    }
}