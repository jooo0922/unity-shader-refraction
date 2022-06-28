Shader "Custom/refraction"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        cull off // 면 추려내기 비활성화하여 쿼드에 양면 렌더링 적용

        CGPROGRAM

        // 별다른 연산을 하지 않는 기본형 커스텀라이트 함수 nolight 를 추가하고, 환경광을 제거함.
        #pragma surface surf nolight noambient

        sampler2D _MainTex;

        struct Input
        {
            float3 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {

        }

        // 별다른 연산을 하지 않는 기본형 커스텀라이트 함수 nolight
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(1, 0, 0, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
