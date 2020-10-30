Shader "Unlit/Circle"
{
    Properties
    {
        _Color("Main Color", Color)=(1,1,1,1)
        _MainTex("Main Texture",2D )= "white"{}
        _Center("Center ",Float )=0.5
        _Radius("Radius",Float )=0.5
        _Feather("Feather",Range(0,0.5))=0.05

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
            uniform float _Center;
            uniform float _Radius;
            uniform float _Feather;

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

            float drawCircle(float2 uv,float2 center,float radius,float feather)
            {
                float circle = pow((uv.y -center.y),2) + pow((uv.x - center.x),2);
                float radiusSquare = pow(radius,2);
                if(circle<radiusSquare)
                {
                    return smoothstep(radiusSquare,radiusSquare-feather,circle);
                
                }
                return 0;
            }

            half4 frag(VertexOutput i): COLOR //half4( medium precision float ) will be treated as a color
            {

                float4 color= tex2D(_MainTex,i.texcoord) * _Color;
                color.a= drawCircle(i.texcoord.xy,_Center,_Radius,_Feather);
                return color;
            }

            ENDCG
        }
    }
}
