Shader "Custom/refraction"
{
    Properties
    {

    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        cull off // 면 추려내기 비활성화하여 쿼드에 양면 렌더링 적용

        CGPROGRAM

        // 별다른 연산을 하지 않는 기본형 커스텀라이트 함수 nolight 를 추가하고, 환경광을 제거함.
        #pragma surface surf nolight noambient

        // 현재 이 쉐이더가 적용된 쿼드 메쉬를 기준으로 쿼드 메쉬 뒷부분의 배경을 캡쳐하는 것을 GrapPass{} 라고 하는데,
        // 이 캡쳐한 화면을 텍스쳐로 받아오려면 _GrapTexture 라는 이름의 샘플러 변수를 선언하면 됨.
        sampler2D _GrapTexture; 

        struct Input
        {
            float4 color:COLOR;
            float4 screenPos; // 현재 캡쳐된 화면의 UV 좌표계를 Input 구조체에 선언해서 꺼내쓰고자 함.
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // 현재 screenPos 의 xyz 값으로 색상을 찍어봤더니 카메라 거리에 따라 화면 uv 좌표값이 바뀌는 걸 볼 수 있었음.
            // 이처럼 카메라 거리에 따른 영향을 제거하기 위해 screenPos.rgb 값을 screenPos.a 값으로 나눠줌.
            // 정확한 원리는 잘 모르지만, 카메라 거리에 따라 r, g, a 값이 바뀌는 걸 색상으로 찍어서 확인해 본 바,
            // r, g 값을 a값으로 나눠줌으로써 (r / a) 와 (g / a) 값이 일정하게 유지되는 듯 함.
            float3 screenUV = IN.screenPos.rgb / IN.screenPos.a;
            o.Emission = float3(screenUV.xy, 0);
        }

        // 별다른 연산을 하지 않는 기본형 커스텀라이트 함수 nolight
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            // 참고로 커스텀 라이트의 결과값은 surf 함수에서 계산하는 o.Emission 과는 별개임.
            // 좀 더 구체적으로 설명하면, 이 커스텀 라이트 함수의 리턴값을 포함한 최종 결과값에 o.Emission 이 더해져서 연산되는 것임!
            return float4(0, 0, 0, 1);
        }
        ENDCG
    }
    FallBack "Regacy Shaders/Transparent/Vertexlit" // 쿼드 메쉬의 그림자 연산에 사용할 유니티 내장 쉐이더를 지정함.
}
