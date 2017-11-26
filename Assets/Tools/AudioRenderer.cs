using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioRenderer : MonoBehaviour {
  [SerializeField]
  AudioWave wave;

  [SerializeField]
  float scale;

  float volume;
  Vector4 ring;

  void Start() {
    wave.OnUpdateVolume += (meter) => {
      volume = meter[0] + meter[1] + meter[2] + meter[3];
    };
  }

  void Update() {
    Vector4 amps = new Vector4 (
      3f * Mathf.Cos(2f * Mathf.PI * Time.time / 15f),
      3f * Mathf.Cos(2f * Mathf.PI * Time.time / 27f),
      1f * Mathf.Cos(2f * Mathf.PI * Time.time / 35f),
      1f * Mathf.Sin(2f * Mathf.PI * Time.time / 55f)
    );
    float height = -0.2f - Mathf.PingPong (Time.time, 120f) / 120f;

    var prop = new MaterialPropertyBlock ();
    prop.SetVector ("_WorldPosition", transform.position);
    prop.SetFloat ("_BoxScale", volume * scale);
    prop.SetFloat ("_RingOffset", volume);

    prop.SetVector ("_RingOffset", amps);
    prop.SetFloat ("_HeightOffset", height);

    foreach (var rend in GetComponentsInChildren<Renderer>()) {
      rend.SetPropertyBlock (prop);
    }
  }

}
