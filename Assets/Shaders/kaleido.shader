
Shader "Custom/Kaleido" {

    Properties
    {
        _MainTex("Main Texture",2D )= "white"{}
        _Speed("div time",float)=10
        _Section("Sections",float)=10
        _NbSprite("nb Sprite",float)=10
    }
    SubShader {
   
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float2 _Screen;
            uniform float _Speed;
            uniform float _Section;
            uniform float _NbSprite;

           
           struct VertexInput
            {
                float4 vertex:POSITION;
                float4 texcoord:TEXCOORD0;
            };

            struct VertexOutput{
                float4 position : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };
           
            VertexOutput vert(VertexInput v) {
                VertexOutput o;
                o.position = UnityObjectToClipPos (v.vertex);
           
                o.texcoord.xy= (v.texcoord.xy *_MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }
 
            static float PI = 3.141592658;

            fixed4 frag(VertexOutput i) : COLOR {
                //set base position to 
                float2 pos = float2(i.position.xy-0.5*_ScreenParams.xy) / (_ScreenParams.y/_NbSprite);

                float rad = length(pos);
                float angle = atan2(pos.x, pos.y);

                float time = _Time.y/_Speed;
                float ma = angle-(PI*2.0/_Section)*floor(angle/(PI*2.0/_Section)) ;
                ma = abs(ma - PI/_Section);
                
                float x = cos(ma) * rad;
                float y = sin(ma) * rad;
                    
                
                return tex2D(_MainTex, float2(x-time, y-time));
            }

           
            ENDCG
        }
    }
}