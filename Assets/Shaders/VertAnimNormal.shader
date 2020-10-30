Shader "Unlit/VertexAnimNormal"
{
    Properties
    {
        _Speed("Speed", Float) = 1
        _Frequency("Frequency", Float) = 1
        _Amplitude("Amplitude", Float) = 1
        _Color("Main Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
    }
    Subshader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjection" = "True"
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
        uniform float _Speed;
        uniform float _Frequency;
        uniform float _Amplitude;

        struct VertexInput
        {
            float4 vertex: POSITION;
            float4 normal: NORMAL;
            float4 texcoord: TEXCOORD0;
        };

        struct VertexOutput
        {
            float4 pos : POSITION;
            float4 texcoord : TEXCOORD0;
        };

        float4 vertexAnimNormal(float4 vertPos,float4 vertNormal, float2 uv)
        {
            vertPos += sin((uv.x - _Time.y * _Speed) * _Frequency) * _Amplitude * vertNormal;
            return vertPos;
        }

        VertexOutput vert(VertexInput v)
        {
            VertexOutput o;
            v.vertex = vertexAnimNormal(v.vertex,v.normal, v.texcoord);

            o.pos = UnityObjectToClipPos(v.vertex);
            o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
            return o;
        }

        half4 frag(VertexOutput i) : COLOR
        {
            float4 color = tex2D(_MainTex, i.texcoord) * _Color;
            return color;
        }

        ENDCG
        }
    }
}
