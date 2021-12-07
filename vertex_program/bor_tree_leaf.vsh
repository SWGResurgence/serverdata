//hlsl vs_2_0

#define textureCoordinateSetMAIN	textureCoordinateSet0
#define DECLARE_textureCoordinateSets	\
	float2 textureCoordinateSet0 : TEXCOORD0 : register(v7); 

#include "vertex_program/include/vertex_shader_constants.inc"
#include "vertex_program/include/functions.inc"

struct InputVertex
{
	float4  position              : POSITION0  : register(v0);
	float4  normal                : NORMAL0    : register(v3);
	DECLARE_textureCoordinateSets
};

struct OutputVertex
{
	float4  position               		: POSITION0;
	float3  diffuse                		: COLOR0;
	float   fog                    		: FOG;
	float2  tcs_MAIN  			: TEXCOORD0;
	float3  normal_o	  		: TEXCOORD1;
};

OutputVertex main(InputVertex inputVertex)
{
	
	float4 _wind_dir = float4(0.5,0.05,0.5,0);
    float _wind_size = 15;
    float _tree_sway_speed = 2;
    float _tree_sway_disp = 0.3;
    float _leaves_wiggle_disp = 0.07;
    float _leaves_wiggle_speed = 0.5;
    float _branches_disp = 0.3;
    float _tree_sway_stutter = 1.5;
    float _tree_sway_stutter_influence = 0.2;
    float _r_influence = 1;
    float _b_influence = 1;
	
	OutputVertex outputVertex;
	
	// transform vertex
	outputVertex.position = transform3d(inputVertex.position);
	
	float3 worldPos = mul (objectWorldMatrix, outputVertex.position).xyz;
	

	outputVertex.position.x += (cos(currentTime * _tree_sway_speed + (worldPos.x/_wind_size) + (sin(currentTime * _tree_sway_stutter * _tree_sway_speed + (worldPos.x/_wind_size)) * _tree_sway_stutter_influence) ) + 1)/2 * _tree_sway_disp * _wind_dir.x * (outputVertex.position.y / 10) + 
                    cos(currentTime * outputVertex.position.x * _leaves_wiggle_speed + (worldPos.x/_wind_size)) * _leaves_wiggle_disp * _wind_dir.x * 1 * _b_influence;
					
	outputVertex.position.y += (cos(currentTime * _tree_sway_speed + (worldPos.z/_wind_size) + (sin(currentTime * _tree_sway_stutter * _tree_sway_speed + (worldPos.z/_wind_size)) * _tree_sway_stutter_influence) ) + 1)/2 * _tree_sway_disp * _wind_dir.z * (outputVertex.position.y / 10) + 
                    cos(currentTime * outputVertex.position.z * _leaves_wiggle_speed + (worldPos.x/_wind_size)) * _leaves_wiggle_disp * _wind_dir.z * 1 * _b_influence;
					
	//outputVertex.position.z += cos(currentTime * _tree_sway_speed + (worldPos.z/_wind_size)) * _tree_sway_disp * _wind_dir.y * (outputVertex.position.y / 10);				
	
	// calculate fog
	outputVertex.fog = calculateFog(inputVertex.position);

	// copy texture coordinates
	outputVertex.tcs_MAIN = inputVertex.textureCoordinateSetMAIN;

	// calculate lighting
	outputVertex.diffuse =  lightData.ambient.ambientColor;
	outputVertex.diffuse += calculateDiffuseLighting(true, inputVertex.position, inputVertex.normal);

	// store vertex normal
	outputVertex.normal_o = inputVertex.normal;

	return outputVertex;
}
