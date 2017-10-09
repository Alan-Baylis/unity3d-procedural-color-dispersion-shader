using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotate_self : MonoBehaviour {
	void Update () {
		this.transform.Rotate(0.2f, 0.2f, 0.2f);
	}
}
