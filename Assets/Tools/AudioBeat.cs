using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioBeat : MonoBehaviour {
  [SerializeField]
  AudioWave wave;

  [SerializeField]
  Transform[] trans;

  [SerializeField]
  float scale;

  void Start() {
    wave.OnUpdateVolume += (meter) => {
      for (int i = 0; i < trans.Length; i++) {
        trans[i].localScale = new Vector3(1f, 0f, 1f) + Vector3.up * meter[i] * scale;
      }
    };
  }

}
