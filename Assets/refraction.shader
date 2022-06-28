Shader "Custom/refraction"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {} // GrabTexture 를 샘플링할 uv 좌표를 구겨줄 때 사용할 굴절 노이즈 텍스쳐를 받아올 인터페이스 추가
        _RefStrength ("Refraction Strength", Range(0, 0.1)) = 0.05 // 굴절 노이즈 텍스쳐 _MainTex 에서 샘플링한 텍셀값에 곱해서 굴절의 강도 조절값을 받아올 인터페이스 추가
    }
    SubShader
    {
        // 쿼드 메쉬는 다른 오브젝트들보다 가장 나중에 그려져야, 먼저 그려진 오브젝트들을 전부 배경으로써 캡쳐할 수 있음.
        // 따라서, "Queue"="Transparent" 로 설정해서 반투명 쉐이더로 분류시키면, '불투명 오브젝트들이 다 그려질 때까지 대기하는' 반투명 쉐이더의 원리를 이용한 것!
        Tags { "RenderType" = "Transparent" "Queue"="Transparent"}
        zwrite off // 반투명 쉐이더(알파 블렌딩 쉐이더) 사용 시, 부정확한 알파 소팅으로 인해 투명 픽셀에 의해 뒷쪽 오브젝트 픽셀이 잘리는 일이 없도록 zwrite(즉, 깊이테스트)를 비활성화 해줘야 함.
        cull off // 면 추려내기 비활성화하여 쿼드에 양면 렌더링 적용
        
        // GrabPass{} 를 선언하면, 현재 이 쉐이더가 적용된 쿼드 메쉬를 기준으로 쿼드 메쉬 뒷부분의 배경을 캡쳐해 줌.
        // 이렇게 캡쳐한 배경을 텍스쳐로 받아서 사용하려면 아래 CG 쉐이더 부분에 _GrabTexture 라는 이름으로 샘플러 변수를 선언해줘야 함.
        GrabPass {}

        CGPROGRAM

        // 별다른 연산을 하지 않는 기본형 커스텀라이트 함수 nolight 를 추가하고, 환경광을 제거함.
        #pragma surface surf nolight noambient alpha:fade

        sampler2D _GrabTexture; // GrabPass 를 선언하여 캡쳐한 화면을 텍스쳐로 받기 위해 _GrapTexture 샘플러 변수 선언.
        sampler2D _MainTex; // GrabTexture 를 샘플링할 uv 좌표를 구겨줄 때 사용할 굴절 노이즈 텍스쳐를 담는 샘플러 변수 선언
        float _RefStrength; // 굴절 노이즈 텍스쳐 _MainTex 에서 샘플링한 텍셀값에 곱해서 굴절의 강도를 조절해주는 값

        struct Input
        {
            float4 color:COLOR;
            float4 screenPos; // 현재 캡쳐된 화면의 UV 좌표계를 Input 구조체에 선언해서 꺼내쓰고자 함.
            float2 uv_MainTex; // 굴절 노이즈 텍스쳐를 샘플링할 버텍스 uv 좌표값 선언
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            float4 ref = tex2D(_MainTex, IN.uv_MainTex); // 굴절 노이즈 텍스쳐로부터 텍셀값을 샘플링함.

            // 현재 screenPos 의 xyz 값으로 색상을 찍어봤더니 카메라 거리에 따라 화면 uv 좌표값이 바뀌는 걸 볼 수 있었음.
            // 이처럼 카메라 거리에 따른 영향을 제거하기 위해 screenPos.rgb 값을 screenPos.a 값으로 나눠줌.
            // 정확한 원리는 잘 모르지만, 카메라 거리에 따라 r, g, a 값이 바뀌는 걸 색상으로 찍어서 확인해 본 바,
            // r, g 값을 a값으로 나눠줌으로써 (r / a) 와 (g / a) 값이 일정하게 유지되는 듯 함.
            float3 screenUV = IN.screenPos.rgb / IN.screenPos.a;
            // o.Emission = float3(screenUV.xy, 0);

            // 쿼드 메쉬의 뒷부분을 캡쳐한 텍스쳐 _GrabTexture 를 화면 좌표계인 screenUV 로 샘플링하면,
            // 말 그대로 쿼드 메쉬 뒷부분 배경의 캡쳐본을 샘플링해서 색깔로 찍어주기 때문에,
            // 마치 투명망토처럼 뒷부분이 그대로 비쳐져서 보이게 될 것임. -> 그래서 마치 쿼드 메쉬가 아예 사라진 것처럼 보임.
            // + 굴절 노이즈 텍스쳐를 샘플링한 텍스쳐의 x컴포넌트만(흑백 텍스쳐라 y, z 값을 사용해도 결과는 동일함.) 가져온 뒤, _RefStrength 와 곱해 값의 규모를 적절하게 줄여줘서 
            // GrabTexture 를 샘플링할 화면 좌표계 uv 에 더해주면, 굴절 노이즈 텍스쳐의 결을 따라 화면 좌표계 uv 가 구겨짐. 
            // -> 결과적으로 샘플링된 GrabTexture 텍셀을 찍어서 렌더링하면 역시 구겨진 모습으로 렌더링됨!
            o.Emission = tex2D(_GrabTexture, screenUV.xy + ref.x * _RefStrength); 
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
