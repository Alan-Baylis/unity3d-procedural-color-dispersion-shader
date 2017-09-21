using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class attraction : MonoBehaviour {
	public Camera cam;

	void Update () {
		Vector3 target = cam.transform.forward * 2.0f;
		Vector3 np	= this.transform.position;
		Vector3 dir = target - np;
		float dist = Vector3.Magnitude (dir);
		dir = Vector3.Normalize (dir);

		np = np + dir * dist * 0.01f;

		this.transform.position = np;
	}
}
