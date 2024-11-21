using System;
using System.Collections;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using Unity.Mathematics;
using Random = UnityEngine.Random;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager Instance { get; private set; }
    
    public AudioSource sfxAudioSource; 
    public AudioSource bgmAudioSource;
    
    [SerializedDictionary("Name", "Bgm")] public SerializedDictionary<string, AudioClip> bgms;
    [SerializedDictionary("Name", "Sfx")] public SerializedDictionary<string, AudioClip> sfxs;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
    
    public void PlaySfx(string name, float volume = 1f)
    {
        if (sfxs[name])
        {
            PlaySfx(sfxs[name], volume);
        }
    }
    
    public void PlaySfx(AudioClip clip, float volume = 1f)
    {
        if (clip)
        {
            sfxAudioSource.PlayOneShot(clip, volume);
        }
    }
    
    public void PlaySfx(List<AudioClip> clips, float volume = 1f)
    {
        if (clips.Count > 0)
        {
            int randomIndex = Random.Range(0, clips.Count);
            sfxAudioSource.PlayOneShot(clips[randomIndex],volume);
        }
    }
    public void PlayBGM(string name, float volume = 1f)
    {
        if (bgms[name])
        {
            PlayBGM(bgms[name], volume);
        }
    }

    public void PlayBGM(AudioClip clip, float volume = 1f)
    {
        if (bgmAudioSource.clip == clip)
        {
            bgmAudioSource.volume = volume;
        }
        else
        {
            bgmAudioSource.clip = clip;
            bgmAudioSource.volume = volume;
            bgmAudioSource.Play();
        }
    }

    public void StopBGM()
    {
        bgmAudioSource.Stop();
    }

    public void ReplayBGM()
    {
        bgmAudioSource.Play();
    }

    public void SetSfxVolume(float volume)
    {
        sfxAudioSource.volume = volume;
    }
    public void SetBgmVolume(float volume)
    {
        bgmAudioSource.volume = volume;
    }
    
    private void OnApplicationFocus(bool hasFocus)
    {
        AudioListener.volume = hasFocus?1:0;
    }
}
