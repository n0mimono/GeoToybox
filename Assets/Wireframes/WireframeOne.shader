Shader "Wireframe/One" {
  Properties {
    _MainTex ("Texture", 2D) = "white" {}

    [Header(Wireframe)]
    _Color ("Color", Color) = (1,1,1,1)
    _Width ("Width", Float) = 0.005
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
        float4 color : TEXCOORD0;
      };

      struct g2f {
        float4 vertex : SV_POSITION;        
        float4 color  : TEXCOORD0;
        UNITY_FOG_COORDS(1)
      };

      float4 _Color;
      float _Width;
      
      v2g vert (appdata v) {
        v2g o;
        o.vertex = v.vertex;
        o.color = v.color;
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

  }
}
