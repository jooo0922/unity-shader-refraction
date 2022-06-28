Shader "Custom/refraction"
{
    Properties
    {

    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        cull off // �� �߷����� ��Ȱ��ȭ�Ͽ� ���忡 ��� ������ ����

        CGPROGRAM

        // ���ٸ� ������ ���� �ʴ� �⺻�� Ŀ���Ҷ���Ʈ �Լ� nolight �� �߰��ϰ�, ȯ�汤�� ������.
        #pragma surface surf nolight noambient

        // ���� �� ���̴��� ����� ���� �޽��� �������� ���� �޽� �޺κ��� ����� ĸ���ϴ� ���� GrapPass{} ��� �ϴµ�,
        // �� ĸ���� ȭ���� �ؽ��ķ� �޾ƿ����� _GrapTexture ��� �̸��� ���÷� ������ �����ϸ� ��.
        sampler2D _GrapTexture; 

        struct Input
        {
            float4 color:COLOR;
            float4 screenPos; // ���� ĸ�ĵ� ȭ���� UV ��ǥ�踦 Input ����ü�� �����ؼ� ���������� ��.
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // ���� screenPos �� xyz ������ ������ ���ô��� ī�޶� �Ÿ��� ���� ȭ�� uv ��ǥ���� �ٲ�� �� �� �� �־���.
            // ��ó�� ī�޶� �Ÿ��� ���� ������ �����ϱ� ���� screenPos.rgb ���� screenPos.a ������ ������.
            // ��Ȯ�� ������ �� ������, ī�޶� �Ÿ��� ���� r, g, a ���� �ٲ�� �� �������� �� Ȯ���� �� ��,
            // r, g ���� a������ ���������ν� (r / a) �� (g / a) ���� �����ϰ� �����Ǵ� �� ��.
            float3 screenUV = IN.screenPos.rgb / IN.screenPos.a;
            o.Emission = float3(screenUV.xy, 0);
        }

        // ���ٸ� ������ ���� �ʴ� �⺻�� Ŀ���Ҷ���Ʈ �Լ� nolight
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            // ����� Ŀ���� ����Ʈ�� ������� surf �Լ����� ����ϴ� o.Emission ���� ������.
            // �� �� ��ü������ �����ϸ�, �� Ŀ���� ����Ʈ �Լ��� ���ϰ��� ������ ���� ������� o.Emission �� �������� ����Ǵ� ����!
            return float4(0, 0, 0, 1);
        }
        ENDCG
    }
    FallBack "Regacy Shaders/Transparent/Vertexlit" // ���� �޽��� �׸��� ���꿡 ����� ����Ƽ ���� ���̴��� ������.
}
