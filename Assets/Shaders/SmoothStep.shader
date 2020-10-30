Shader "Unlit/SmoothStep"
{
    Properties
    {
        _Color("Main Color", Color)=(1,1,1,1)
        _MainTex("Main Texture",2D )= "white"{}
        _Base("Base",float )=0.0
        _Start("Start",float )=0.5
        _End("End",float )=1
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
            uniform float _Base;
            uniform float _Start;
            uniform float _End;

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

            float drawSmooth(float2 uv,float base,float start,float end)
            {
                if(uv.x>0.5 )
                {
                    return smoothstep(start,end,uv.x);
                }
                return base;
            }

            half4 frag(VertexOutput i): COLOR //half4( medium precision float ) will be treated as a color
            {

                float4 color= tex2D(_MainTex,i.texcoord) * _Color;
                color.a= drawSmooth(i.texcoord.x,_Base,_Start,_End);
                return color;
            }

            ENDCG
        }
    }
}
