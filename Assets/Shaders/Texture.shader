Shader "Unlit/Texture"
{
    Properties
    {
        _Color("Main Color", Color)=(1,1,1,1)
        _MainTex("Main Texture",2D )= "white"{}
    }
     Subshader
    {
        Tags
        {
            "Order"="Transparent"
            "RenderType"= "Transparent"
            "IgnoreProjector" = "True"
        }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

            struct VertexInput
            {
                float4 vertex:POSITION;
                float4 texcoord:TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos:SV_POSITION;
                float4 texcoord:TEXCOORD0;
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy= (v.texcoord.xy *_MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            half4 frag(VertexOutput i): COLOR //half4( medium precision float ) will be treated as a color
            {
                return tex2D(_MainTex,i.texcoord) * _Color;
            }

            ENDCG
        }
    }
}
