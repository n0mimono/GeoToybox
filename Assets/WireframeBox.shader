Shader "Wireframe/Box" {
  Properties {
    _MainTex ("Texture", 2D) = "white" {}

    [Header(Wireframe)]
    _Color ("Color", Color) = (1,1,1,1)
    _Width ("Width", Float) = 0.005

    [Header(Surface)]
    _Tint ("Tint", Color) = (1,1,1,1)

    [Header(Box)]
    _BoxScale ("Box Scale", Float) = 0.01

    [Header(Local)]
    _HeightOffset ("Height Offest", Float) = 0
    _HeightPower ("Height Power", Float) = 0

    [Header(Rim)]
    _RimPower ("Rim Power", Float) = 1
    _RimAmplitude ("Rim Amplitude", Float) = 1
    _RimTint ("Rim Tint", Color) = (1,1,1,1)
  }

  SubShader {
    Tags { "RenderType"="Transparent" "Queue"="Transparent" }
    LOD 100

    // 0: wireframe pass
    Pass {
      Cull Off
      Blend SrcAlpha OneMinusSrcAlpha
      ZWrite Off

      CGPROGRAM
      #pragma target 4.0
      #pragma vertex vert
      #pragma geometry geo
      #pragma fragment frag
      #pragma multi_compile_fog
      #include "UnityCG.cginc"

      struct appdata {
        float4 vertex : POSITION;
        float4 color : COLOR;
      };

      struct v2g {
        float4 vertex : POSITION;
        float4 color  : TEXCOORD0;
      };

      struct g2f {
        float4 vertex : SV_POSITION;
        float4 color  : TEXCOORD0;
        UNITY_FOG_COORDS(2)
      };

      float4 _Color;
      float _Width;
      
      v2g vert (appdata v) {
        v2g o;
        o.vertex = v.vertex;
        o.color  = v.color;
        return o;
      }

      [maxvertexcount(21)]
      void geo(triangle v2g v[3], inout TriangleStream<g2f> TriStream) {
        for (int i = 0; i < 3; i++) {
          v2g vb = v[(i + 0) % 3];
          v2g v1 = v[(i + 1) % 3];
          v2g v2 = v[(i + 2) % 3];

          float3 dir = normalize((v1.vertex.xyz + v2.vertex.xyz) * 0.5 - vb.vertex.xyz);

          g2f o;
          o.color  = _Color * v[0].color;

          o.vertex = UnityObjectToClipPos(float4(v1.vertex.xyz, 1));
          UNITY_TRANSFER_FOG(o,o.vertex);
          TriStream.Append(o);

          o.vertex = UnityObjectToClipPos(float4(v2.vertex.xyz, 1));
          UNITY_TRANSFER_FOG(o,o.vertex);
          TriStream.Append(o);

          o.vertex = UnityObjectToClipPos(float4(v2.vertex.xyz + dir * _Width, 1));
          UNITY_TRANSFER_FOG(o,o.vertex);
          TriStream.Append(o);
          TriStream.RestartStrip();

          o.vertex = UnityObjectToClipPos(float4(v1.vertex.xyz, 1));
          UNITY_TRANSFER_FOG(o,o.vertex);
          TriStream.Append(o);

          o.vertex = UnityObjectToClipPos(float4(v1.vertex.xyz + dir * _Width, 1));
          UNITY_TRANSFER_FOG(o,o.vertex);
          TriStream.Append(o);

          o.vertex = UnityObjectToClipPos(float4(v2.vertex.xyz + dir * _Width, 1));
          UNITY_TRANSFER_FOG(o,o.vertex);
          TriStream.Append(o);
          TriStream.RestartStrip();
        }

      }

      fixed4 frag (g2f i) : SV_Target {
        fixed4 col = i.color;
        UNITY_APPLY_FOG(i.fogCoord, col);
        return col;
      }
      ENDCG
    }

    // 1: surface pass
    Pass {
      Cull Back
      Blend SrcAlpha OneMinusSrcAlpha

      CGPROGRAM
      #pragma target 4.0
      #pragma vertex vert
      #pragma geometry geo
      #pragma fragment frag
      #pragma multi_compile_fog
      #include "UnityCG.cginc"

      struct appdata {
        float4 vertex : POSITION;
        float2 uv     : TEXCOORD0;
        float4 color  : COLOR;
        float3 normal : NORMAL;
      };

      struct v2f {
        float4 vertex : SV_POSITION;        
        float2 uv     : TEXCOORD0;
        float4 wpos   : TEXCOORD1;
        float4 color  : TEXCOORD2;
        float3 normal : TEXCOORD3;
        UNITY_FOG_COORDS(4)
      };

      sampler2D _MainTex; float4 _MainTex_ST;
      float4 _WorldPosition;

      float4 _Tint;
      float _BoxScale;

      float _HeightOffset;
      float _HeightPower;

      float _RimPower;
      float _RimAmplitude;
      float4 _RimTint;

      v2f vert (appdata v) {
        v2f o;
        o.vertex = v.vertex;
        o.uv     = TRANSFORM_TEX(v.uv, _MainTex);
        o.wpos   = mul(unity_ObjectToWorld, v.vertex);
        o.color  = v.color;
        o.normal = v.normal;
        return o;
      }

      float halpha(float y) {
        return pow(y + _HeightOffset, _HeightPower);
      }

      #define ADD_VERT(v, n) \
        o.vertex = UnityObjectToClipPos(v); \
        o.normal = UnityObjectToWorldNormal(n); \
        UNITY_TRANSFER_FOG(o,o.vertex); \
        TriStream.Append(o);
      
      #define ADD_TRI(p0, p1, p2, n) \
        ADD_VERT(p0, n) ADD_VERT(p1, n) \
        ADD_VERT(p2, n) \
        TriStream.RestartStrip();
      
      [maxvertexcount(36)]
      void geo(triangle v2f v[3], inout TriangleStream<v2f> TriStream) {
        float4 wpos = (v[0].wpos + v[1].wpos + v[2].wpos) / 3;
        float4 vertex = (v[0].vertex + v[1].vertex + v[2].vertex) / 3;
        float2 uv = (v[0].uv + v[1].uv + v[2].uv) / 3;

        v2f o = v[0];
        o.uv = uv;
        o.wpos = wpos;
        float scale = _BoxScale;

        float4 v0 = float4( 1, 1, 1,1)*scale + float4(vertex.xyz,0);
        float4 v1 = float4( 1, 1,-1,1)*scale + float4(vertex.xyz,0);
        float4 v2 = float4( 1,-1, 1,1)*scale + float4(vertex.xyz,0);
        float4 v3 = float4( 1,-1,-1,1)*scale + float4(vertex.xyz,0);
        float4 v4 = float4(-1, 1, 1,1)*scale + float4(vertex.xyz,0);
        float4 v5 = float4(-1, 1,-1,1)*scale + float4(vertex.xyz,0);
        float4 v6 = float4(-1,-1, 1,1)*scale + float4(vertex.xyz,0);
        float4 v7 = float4(-1,-1,-1,1)*scale + float4(vertex.xyz,0);

        float3 n0 = float3( 1, 0, 0);
        float3 n1 = float3(-1, 0, 0);
        float3 n2 = float3( 0, 1, 0);
        float3 n3 = float3( 0,-1, 0);
        float3 n4 = float3( 0, 0, 1);
        float3 n5 = float3( 0, 0,-1);

        ADD_TRI(v0, v2, v3, n0);
        ADD_TRI(v3, v1, v0, n0);
        ADD_TRI(v5, v7, v6, n1);
        ADD_TRI(v6, v4, v5, n1);

        ADD_TRI(v4, v0, v1, n2);
        ADD_TRI(v1, v5, v4, n2);
        ADD_TRI(v7, v3, v2, n3);
        ADD_TRI(v2, v6, v7, n3);

        ADD_TRI(v6, v2, v0, n4);
        ADD_TRI(v0, v4, v6, n4);
        ADD_TRI(v5, v1, v3, n5);
        ADD_TRI(v3, v7, v5, n5);
      }

      fixed4 frag (v2f i) : SV_Target {
        float3 normalDir = normalize(i.normal);
        float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);
        float NNdotV = 1 - dot(normalDir, viewDir);
        float rim = pow(NNdotV, _RimPower) * _RimAmplitude;

        float4 col = tex2D(_MainTex, i.uv) * i.color * _Tint;
        col.rgb = col.rgb * _RimTint.a + rim * _RimTint.rgb;
        //col.a *= saturate(halpha(i.wpos.y - _WorldPosition.y));

        //UNITY_APPLY_FOG(i.fogCoord, col);
        return col;
      }
      ENDCG
    }

  }
}
