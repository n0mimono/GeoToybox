using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class AudioWave : MonoBehaviour {
  [SerializeField] float speed = 0.5f;

  AudioSource source;

  public delegate void UpdateVolumeHandler(float[] meter);
  public event UpdateVolumeHandler OnUpdateVolume;

  float[] spec = new float[1024];
  float[] meter = new float[4];
  float[] smooth = new float[4];

  void Start() {
    source = GetComponent<AudioSource> ();
  }

  void Update() {
    source.GetSpectrumData (spec, 0, FFTWindow.Hamming);

    for (var i = 0; i < meter.Length; i++) {
      meter [i] = 0f;
    }
    for (var i = 0; i < spec.Length; i++) {
      if      (i < 128)  meter[0] += spec[i];
      else if (i < 256)  meter[1] += spec[i];
      else if (i < 512)  meter[2] += spec[i];
      else               meter[3] += spec[i];
    }
    for (var i = 0; i < meter.Length; i++) {
      smooth [i] = Mathf.Lerp (smooth [i], meter [i], speed * Time.deltaTime);
    }

    if (OnUpdateVolume != null) {
      OnUpdateVolume (smooth);
    }
  }

}
