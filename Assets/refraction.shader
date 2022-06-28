Shader "Custom/refraction"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        cull off // �� �߷����� ��Ȱ��ȭ�Ͽ� ���忡 ��� ������ ����

        CGPROGRAM

        // ���ٸ� ������ ���� �ʴ� �⺻�� Ŀ���Ҷ���Ʈ �Լ� nolight �� �߰��ϰ�, ȯ�汤�� ������.
        #pragma surface surf nolight noambient

        sampler2D _MainTex;

        struct Input
        {
            float3 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {

        }

        // ���ٸ� ������ ���� �ʴ� �⺻�� Ŀ���Ҷ���Ʈ �Լ� nolight
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(1, 0, 0, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
