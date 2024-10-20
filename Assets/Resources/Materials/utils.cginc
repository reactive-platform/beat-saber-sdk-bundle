float3 get_curved_position(const float3 local_pos, const float radius)
{
    return (radius < 1e-10f)
               ? local_pos
               : float3(
                   sin(local_pos.x / radius) * radius,
                   local_pos.y,
                   cos(local_pos.x / radius) * radius - radius
               );
}

float2 rotate_uv(float2 uv, const float angle)
{
    const float c = cos(angle);
    const float s = sin(angle);
    return float2(
        c * uv.x + s * uv.y,
        -s * uv.x + c * uv.y
    );
}

float4 alpha_blend(float4 source, float4 destination)
{
    return source * source.a + destination * (1 - source.a);
}

float4 apply_fake_bloom(float4 source_color, const float fake_bloom_value)
{
    const float fake_bloom_brightness = pow(source_color.a, 2) * fake_bloom_value;

    return float4(
        source_color.r + fake_bloom_brightness,
        source_color.g + fake_bloom_brightness,
        source_color.b + fake_bloom_brightness,
        source_color.a
    );
}

float map(float val, float inMin, float inMax, float outMin, float outMax)
{
    return (val - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}


//<------- COLOR CONVERSIONS (from https://www.chilliant.com/rgb2hsv.html) -------------->

float3 HUEtoRGB(in float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R, G, B));
}

float3 HSVtoRGB(in float3 HSV)
{
    float3 RGB = HUEtoRGB(HSV.x);
    return ((RGB - 1) * HSV.y + 1) * HSV.z;
}

static const float Epsilon = 1e-10;

float3 RGBtoHCV(in float3 RGB)
{
    // Based on work by Sam Hocevar and Emil Persson
    float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0 / 3.0) : float4(RGB.gb, 0.0, -1.0 / 3.0);
    float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
    return float3(H, C, Q.x);
}

float3 RGBtoHSV(in float3 RGB)
{
    float3 HCV = RGBtoHCV(RGB);
    float S = HCV.y / (HCV.z + Epsilon);
    return float3(HCV.x, S, HCV.z);
}

// <---- Color utils

float3 transform_rgb(float3 rgb, float hue_shift, float saturation, float brightness)
{
    float3x3 RGB_YIQ = float3x3(
        0.299, 0.587, 0.114,
        0.5959, -0.275, -0.3213,
        0.2115, -0.5227, 0.3112
    );

    float3x3 YIQ_RGB = float3x3(
        1, 0.956, 0.619,
        1, -0.272, -0.647,
        1, -1.106, 1.702
    );

    float3 YIQ = mul(RGB_YIQ, rgb);
    float hue = atan2(YIQ.z, YIQ.y) - hue_shift;
    float chroma = length(YIQ.yz) * saturation;
    float Y = YIQ.x + brightness;
    float I = chroma * cos(hue);
    float Q = chroma * sin(hue);
    return mul(YIQ_RGB, float3(Y, I, Q));
}
