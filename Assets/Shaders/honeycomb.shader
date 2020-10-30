
Shader "Custom/honeycomb" {

    SubShader {
   
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
           
            struct v2f{
                float4 position : SV_POSITION;
            };
           
            v2f vert(float4 v:POSITION) : SV_POSITION {
                v2f o;
                o.position = UnityObjectToClipPos (v);
                return o;
            }

            float3 hash(float x) 
            { 
                return frac(mul(sin(mul((float3(x,x,x)+float3(23.32445,132.45454,65.78943)),float3(23.32445,32.45454,65.78943))),4352.34345)); 
                
            }

            float3 noise(float x)
            {
                float p = frac(x); x-=p;
                return lerp(hash(x),hash(x+1.0),p);
            }

            float3 noiseq(float x)
            {
                return (noise(x)+noise(x+10.25)+noise(x+20.5)+noise(x+30.75))*0.25;
            }

             fixed4 frag(v2f i) : SV_Target {
           
                float time=_Time.y*0.15;
                float3 k1=noiseq(time)*float3(0.1,0.19,0.3)+float3(1.3,0.8,.63);
                float3 k2=noiseq(time+1000.0)*float3(0.2,0.2,0.05)+float3(0.9,0.9,.05);
                //float k3=clamp(texture(iChannel0,vec2(0.01,0.)).x,0.8,1.0); float k4=clamp(texture(iChannel0,vec2(0.2,0.)).x,0.5,1.0); k2+=vec3((k3-0.8)*0.05); k1+=vec3((k4-0.5)*0.01);
                float g=pow(abs(sin(time*0.8+9000.0)),4.0);
                
                float2 R = _ScreenParams.xy;
                
                float2 r1=(i.position / R.y-float2(0.5*R.x/R.y,0.5));
                float l = length(r1);
                float2 rotate=float2(cos(time),sin(time));
                r1=float2(r1.x*rotate.x+r1.y*rotate.y,r1.y*rotate.x-r1.x*rotate.y);
                float2 c3 = abs(r1.xy/l);
                if (c3.x>0.5) c3=abs(c3*0.5+float2(-c3.y,c3.x)*0.86602540);
                c3=normalize(float2(c3.x*2.0,(c3.y-0.8660254037)*7.4641016151377545870));
                float4 O;
                O = float4(c3*l*70.0*(g+0.12), .5,0);
                for (int i = 0; i < 128; i++) {
                    O.xzy = (k1 * abs(O.xyz/dot(O,O)-k2));
                }
                return O;
            }

            ENDCG
        }
    }
}