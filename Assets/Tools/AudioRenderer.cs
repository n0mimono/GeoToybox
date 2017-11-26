using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioRenderer : MonoBehaviour {
  [SerializeField]
  AudioWave wave;

  [SerializeField]
  float scale;

  float volume;
  float time;
  Vector4 ring;

  void Start() {
    wave.OnUpdateVolume += (meter, time) => UpdateOnAudio (meter, time);
  }

  void UpdateOnAudio(float[] meter, float time) {
    volume = meter[0] + meter[1] + meter[2] + meter[3];

    var height = -0.2f - Mathf.PingPong (time, 120f) / 120f - volume + 0.4f;

    var prop = new MaterialPropertyBlock ();
    prop.SetFloat ("_SoundTime", time);

    prop.SetVector ("_WorldPosition", transform.position);
    prop.SetFloat ("_BoxScale", volume * scale);
    prop.SetFloat ("_RingOffset", volume);

    prop.SetFloat ("_HeightOffset", height);

    foreach (var rend in GetComponentsInChildren<Renderer>()) {
      rend.SetPropertyBlock (prop);
    }
  }

}
