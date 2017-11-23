using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WireframeRenderer : MonoBehaviour {

  void Update() {
    var prop = new MaterialPropertyBlock ();
    prop.SetVector ("_WorldPosition", transform.position);

    foreach (var rend in GetComponentsInChildren<Renderer>()) {
      rend.SetPropertyBlock (prop);
    }
  }

}
