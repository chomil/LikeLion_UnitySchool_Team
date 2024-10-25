using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using Random = UnityEngine.Random;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager Instance { get; private set; }
    
    public AudioSource sfxAudioSource; 
    public AudioSource bgmAudioSource;
    
    [Header("Race Sound Effects")]
    [SerializeField] private AudioClip qualifySound;    // 통과 사운드
    [SerializeField] private AudioClip eliminateSound;  // 탈락 사운드
    [SerializeField] private AudioClip victorySound;    // 우승 사운드
    
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

    public void PlayBGM(AudioClip clip, float volume = 1f)
    {
        if (bgmAudioSource.clip == clip)
        {
            bgmAudioSource.volume = volume;
        }
        else
        {
            StartCoroutine(ChangeBgm(clip, volume));
        }
    }

    private IEnumerator ChangeBgm(AudioClip nextClip, float volume)
    {
        float startVol = bgmAudioSource.volume;
        float curVol = bgmAudioSource.volume;
        float time = 0f;
        
        while (curVol > 0)
        {
            time += Time.deltaTime;
            curVol = math.lerp(startVol, 0, time*2);
            bgmAudioSource.volume = curVol;
            yield return null;
        }
        SetBgmVolume(0);

        float targetVol = volume;
        curVol = 0;
        time = 0;
        bgmAudioSource.clip = nextClip;
        bgmAudioSource.Play();

        while (curVol < targetVol)
        {
            time += Time.deltaTime;
            curVol = math.lerp(0, targetVol, time*2);
            bgmAudioSource.volume = curVol;
            yield return null;
        }
        bgmAudioSource.volume = targetVol;
    }
    public void StopBGM()
    {
        bgmAudioSource.Stop();
    }

    public void SetSfxVolume(float volume)
    {
        sfxAudioSource.volume = volume;
    }
    public void SetBgmVolume(float volume)
    {
        bgmAudioSource.volume = volume;
    }
    
    // 우승 탈락 통과
    public void PlayQualifySound()
    {
        PlaySfx(qualifySound, 1f);
    }

    public void PlayEliminateSound()
    {
        PlaySfx(eliminateSound, 1f);
    }

    public void PlayVictorySound()
    {
        PlaySfx(victorySound, 1f);
    }
}
