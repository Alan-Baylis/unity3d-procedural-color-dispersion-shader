using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class oil_bubble : MonoBehaviour {
	public Camera cam_scene;
	public RenderTexture tex_scene;
	public RenderTexture tex_dispersion_src;
	public RenderTexture tex_dispersion_dst;
	public Texture tex_noise;
	public Material mat_ar_stream_dispersed;

	int is_init = 0;
	
	void Update () {
		scene_to_texture ();
		cal_dispersion ();

		if (is_init == 0)
			is_init = 1;
	}

	void scene_to_texture(){
		cam_scene.targetTexture = tex_scene;

		RenderTexture.active = tex_scene;
		cam_scene.Render ();

		RenderTexture.active = null;
		cam_scene.targetTexture = null;
	}

	void cal_dispersion(){
		Material m = mat_ar_stream_dispersed;

		m.SetTexture ("tex_scene", tex_scene);
		m.SetTexture ("tex_noise", tex_noise);
		m.SetInt ("is_init", is_init);

		Graphics.Blit (null, tex_dispersion_dst, m);

		RenderTexture temp = tex_dispersion_dst;
		tex_dispersion_dst = tex_dispersion_src;
		tex_dispersion_src = temp;
	}
}
