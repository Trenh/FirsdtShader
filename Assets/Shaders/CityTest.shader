Shader "Unlit/Infinite"
{
    Properties
    {
        _Color("Main Color", Color)=(1,1,1,1)
        _MainTex("Main Texture",2D )= "white"{}
		
		_iMouse("iMouse", Vector) = (0,0,0,0)
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

			uniform fixed4     _iMouse;// mouse pixel coords. xy: current (if MLB down), zw: click

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
// Created by genis sole - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

// A remastered version of this can be found here: https://www.shadertoy.com/view/MtyGWK 
// Adds a better traversal, stronger lighting, softer shadows and AO.

const float PI = 3.1416;

float2 hash2( float2 p )
{
    // procedural white noise	
	return frac(sin(float2(dot(p,float2(127.1,311.7)),
                          dot(p,float2(269.5,183.3))))*43758.5453);
}

// From http://www.iquilezles.org/www/articles/voronoilines/voronoilines.htm
float3 voronoi( in float2 x )
{
    float2 n = floor(x);
    float2 f = frac(x);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
	float2 mg, mr;

    float md = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float2 g = float2(float(i),float(j));
		float2 o = hash2( n + g );
		#ifdef ANIMATE
        o = 0.5 + 0.5*sin( iTime + 6.2831*o );
        #endif
        float2 r = g + o - f;
        float d = dot(r,r);

        if( d<md )
        {
            md = d;
            mr = r;
            mg = g;
        }
    }

    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 8.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        float2 g = mg + float2(float(i),float(j));
		float2 o = hash2( n + g );
		#ifdef ANIMATE
        o = 0.5 + 0.5*sin( iTime + 6.2831*o );
        #endif	
        float2 r = g + o - f;

        if( dot(mr-r,mr-r)>0.00001 )
        md = min( md, dot( 0.5*(mr+r), normalize(r-mr) ) );
    }

    return float3( md, mr );
}


// Modified version of the above iq's voronoi borders. 
// Returns the distance to the border in a given direction.
float3 voronoi( in float2 x, in float2 dir)
{
    float2 n = floor(x);
    float2 f = frac(x);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
	float2 mg, mr;

    float md = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float2 g = float2(float(i),float(j));
		float2 o = hash2( n + g );
        float2 r = g + o - f;
        float d = dot(r,r);

        if( d<md )
        {
            md = d;
            mr = r;
            mg = g;
        }
    }

    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 1e5;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        float2 g = mg + float2(float(i),float(j));
		float2 o = hash2( n + g );
		float2 r = g + o - f;

    
 		if( dot(r-mr,r-mr) > 1e-5 ) {
            float2 l = r-mr;
            
            if (dot(dir, l) > 1e-5) {
            	md = min(md, dot(0.5*(mr+r), l)/dot(dir, l));
            }
        }
        
    }
    
    return float3( md, n+mg);
}

bool IRayAABox(in float3 ro, in float3 rd, in float3 invrd, in float3 bmin, in float3 bmax, 
               out float3 p0, out float3 p1) 
{
    float3 t0 = (bmin - ro) * invrd;
    float3 t1 = (bmax - ro) * invrd;

    float3 tmin = min(t0, t1);
    float3 tmax = max(t0, t1);
    
    float fmin = max(max(tmin.x, tmin.y), tmin.z);
    float fmax = min(min(tmax.x, tmax.y), tmax.z);
    
    p0 = ro + rd*fmin;
    p1 = ro + rd*fmax;
 
    return fmax >= fmin;   
}

float3 AABoxNormal(float3 bmin, float3 bmax, float3 p) 
{
    float3 n1 = -(1.0 - smoothstep(0.0, 0.03, p - bmin));
    float3 n2 = (1.0 -  smoothstep(0.0, 0.03, bmax - p));
    
    return normalize(n1 + n2);
}

const float3 background = float3(0.04,0.04,0.04);
const float3 scmin = -float3(1.77, 1.0, 1.77);
const float3 scmax = float3(1.77, 1.5, 1.77);

// From http://iquilezles.org/www/articles/palettes/palettes.htm
float3 pal( in float t, in float3 a, in float3 b, in float3 c, in float3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

float3 color(float2 p) {
    return pal(3.434+(hash2(p).x*0.02), 
               float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,0.7,0.4),float3(0.0,0.15,0.20)  );
}

float disp(in float2 p) {
    return scmin.y + 0.1 + hash2(p).x * 0.5 + tex2D(_MainTex, float2(hash2(p).x, 0.0)).r*2.0;
}

float4 map(in float2 p, in float2 dir) {
    float3 v = voronoi(p*2.0, dir)*0.5;
    return float4(v, disp(v.yz));
}

float ShadowFactor(in float3 ro, in float3 rd) {
	float3 p0 = float3(0.0,0.0,0.0);
    float3 p1 = float3(0.0,0.0,0.0);
    
    IRayAABox(ro, rd, 1.0/rd, scmin, scmax, p0, p1);
    p0 = ro + rd*0.02;
    
    float2 dir = normalize(rd.xz);
    float sf = rd.y / length(rd.xz);

    float m = -1e5;
    
    const int max_steps = 32;
    for (int i = max_steps; i > 0; --i) {
        if (p0.y < m) break;
        
        if (dot((p1 - p0), rd) < 0.0) return 1.0;
  
        float4 v = map(p0.xz, dir);
        
        m = v.w;
        if (p0.y < m) return 0.0;
        
        p0 += rd*(length(float2(v.x, v.x*sf)) + 0.02);
    }
    
    p0 += rd * (m - p0.y)/rd.y;
    if (dot((p1 - p0), rd) < 0.0) return 1.0;   
    
    return 0.0;
}

float3 Shade(in float3 p, in float3 n, in float3 ld, in float2 c) {
    float3 col = color(c);
	return (col * 0.15 + col * max(0.0, dot(n,ld)) * ShadowFactor(p, ld) * 0.85) * 3.5;
}

float3 Render(in float3 ro, in float3 rd, in float3 ld) {
    float3 p0 = float3(0.0,0.0,0.0);
    float3 p1 = float3(0.0,0.0,0.0);
    
    if (!IRayAABox(ro, rd, 1.0/rd, scmin, scmax, p0, p1)) return background;
    
    float2 dir = normalize(rd.xz);
    float sf = rd.y / length(rd.xz);
    
    float2 lvp = float2(0,0);
    float2 vp = p0.xz;
    
    float m = -1e5;
    
    float3 n = float3(0.0,0.0,0.0);
    
    const int max_steps = 32;
    for (int i = max_steps; i > 0; --i) {
        if (p0.y < m) {
            n = float3(0.0, 1.0, 0.0);
            break;
        }
        
        if (dot((p1 - p0), rd) < 0.0) return background;
  
        float4 v = map(p0.xz, dir);
		
        lvp = vp;
        vp = v.yz;
        
        m = v.w;
        if (p0.y < m) break;
        
        p0 += rd*(length(float2(v.x, v.x*sf)) + 0.02);
    }
    
    
    
    if (n.y != 0.0) {
    	p0 += rd * (-p0.y + m)/rd.y;
        if (dot((p1 - p0), rd) < 0.0) return background;
    }
    
    n = normalize(lerp(float3(normalize(lvp - vp), 0.0).xzy, n, 
                  smoothstep(0.00, 0.03, voronoi(p0.xz*2.0).x*0.5)));
    
    if (all(p0.xz== lvp)) {
    	n = AABoxNormal(scmin, scmax, p0); 
    }
    
    return Shade(p0, n, ld, vp);
}

void CameraOrbitRay(in float2 fragCoord, in float n, in float3 c, in float d, 
                    out float3 ro, out float3 rd, out float3x3 t) 
{
    float a = 1.0/max(_ScreenParams .x, _ScreenParams.y);
    rd = normalize(float3((fragCoord - _ScreenParams.xy*0.5)*a, n));
 
    ro = float3(0.0, 0.0, -d);
    
    float ff = min(1.0, step(0.001, _iMouse.x) + step(0.001, _iMouse.y));
    float2 m = PI*ff + float2(((_iMouse.xy + 0.1) / _ScreenParams.xy) * (PI*2.0));
    m.y = -m.y;
    m.y = sin(m.y*0.5)*0.6 + 0.6;
        
    float3x3 rotX = float3x3(1.0, 0.0, 0.0, 0.0, cos(m.y), sin(m.y), 0.0, -sin(m.y), cos(m.y));
    float3x3 rotY = float3x3(cos(m.x), 0.0, -sin(m.x), 0.0, 1.0, 0.0, sin(m.x), 0.0, cos(m.x));
    
    t = mul(rotY, rotX);
    
    ro = mul(t,  ro);
    ro = c + ro;

    rd = mul(t , rd);
    
    rd = normalize(rd);
}

float3 LightDir(in float3x3 t) 
{
    float3 l = normalize(float3(1.0, 1.0, -1.0));
    return mul(t , l);
}

  half4 frag(VertexOutput i): COLOR //half4( medium precision float ) will be treated as a color
           {
    static float3 ro = float3(0.0,0.0,0.0);
    static float3 rd = float3(0.0,0.0,0.0);
    static float3x3 t = float3x3(1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0);
    
    CameraOrbitRay(i.texcoord, 1.0, float3(0.0,0.0,0.0), 10.0, ro, rd, t);
	return float4(pow(Render(ro, rd, LightDir(t)), float3(0.5454,0.5454,0.5454)), 1.0);
}



          
            ENDCG
        }
    }
}
