using System.Collections;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using UnityEngine;

public class EventSound : MonoBehaviour
{
    public float volume = 1f;
    public SerializedDictionary<string, AudioClip> sounds;

    public void PlaySound(string soundName)
    {
        if (sounds[soundName])
        {
            SoundManager.Instance?.PlaySfx(sounds[soundName], volume);
        }
    }
}
