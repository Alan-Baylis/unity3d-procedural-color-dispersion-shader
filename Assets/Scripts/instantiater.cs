using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class instantiater : MonoBehaviour {
	public GameObject obj;
	public int row;
	public int col;

	void Start () {
		for (int i = 0; i < row; i++) {
			for (int j = 0; j < col; j++) {
				Vector3 _n_loc = obj.transform.position;
				Vector3 _size = obj.transform.localScale;

				_n_loc.x += i * _size.x;
				_n_loc.z += j * _size.z;
				_n_loc.y += Random.Range (-.1f, .1f);

				float s = Random.Range (0.1f, 1.4f);
				obj.transform.localScale = new Vector3 (s, s, s);

				Instantiate (obj.transform, _n_loc, Quaternion.identity);
			}
		}
	}
}
