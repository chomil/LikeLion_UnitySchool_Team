using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Serialization;


public enum RaceState
{
    None, Over, Qualify, Eliminate, Win
}

public class RaceUI : MonoBehaviour
{
    public static RaceUI Instance { get; private set; }

    [Header("Score UI Elements")] [SerializeField]
    private Image scoreImage; // HUD_tips_1080p

    [SerializeField] private TextMeshProUGUI scoreText;

    private bool isMessageOpen = false;
    [SerializeField] private GameObject roundOver;
    [SerializeField] private GameObject roundQualified;
    [SerializeField] private GameObject roundEliminated;
    [SerializeField] private GameObject roundWinner;
    
    [SerializeField] private GameObject exitWindow;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start()
    {
        // 시작할 때 UI 표시
        ShowRaceUI();
    }

    public void UpdateQualifiedCount(int current, int max, RaceType raceType)
    {
        if (scoreText != null)
        {
            if (raceType == RaceType.Race)
            {
                scoreText.text = $"성공\n{current}/{max}"; 
                Debug.Log($"Updating score text: {current}/{max}");  // 디버그 추가
            }
            else
            {
                scoreText.text = $"실패\n{current}/{max}"; 
                Debug.Log($"Updating score text: {current}/{max}"); 
            }
        }
    }

    public void ShowStateWindow(RaceState state)
    {
        switch (state)
        {
            case RaceState.Over:
                StartCoroutine(StateWindowCoroutine(roundOver,state));
                break;
            case RaceState.Qualify:
                StartCoroutine(StateWindowCoroutine(roundQualified,state));
                break;
            case RaceState.Eliminate:
                StartCoroutine(StateWindowCoroutine(roundEliminated,state));
                break;
            case RaceState.Win:
                StartCoroutine(StateWindowCoroutine(roundWinner,state));
                break;
            default:
                break;
        }
    }

    public IEnumerator OpenExitWindow(float delay)
    {
        yield return new WaitForSeconds(delay);
        exitWindow.SetActive(true);

        SoundManager.Instance.PlaySfx("UIPop");
        exitWindow.transform.DOScale(1.2f, 0.1f).SetLoops(2, LoopType.Yoyo);
    }

    private IEnumerator StateWindowCoroutine(GameObject window, RaceState state)
    {    
        while (isMessageOpen)
        {
            yield return null;
        }

        if (state == RaceState.Eliminate)
        {
            SoundManager.Instance.PlaySfx("PlayerLose");
            SoundManager.Instance.PlaySfx("Lose", 0.2f);
        }
        else if (state == RaceState.Qualify)
        {
            SoundManager.Instance.PlaySfx("PlayerFinish");
            SoundManager.Instance.PlaySfx("Win", 0.2f);
        }
        else if (state == RaceState.Over)
        {
            SoundManager.Instance.PlaySfx("RaceEnd");
        }
        else if (state == RaceState.Win)
        {
            SoundManager.Instance.PlaySfx("Win", 0.2f);
        }
        
        isMessageOpen = true;
        window.SetActive(true);
        yield return new WaitForSeconds(3.0f);
        window.SetActive(false);
        isMessageOpen = false;
    }

    public void HideRaceWindows()
    {
        roundOver?.SetActive(false);
        roundQualified?.SetActive(false);
        roundEliminated?.SetActive(false);
        roundWinner?.SetActive(false);
        exitWindow?.SetActive(false);
        isMessageOpen = false;
    }

    public void ShowRaceUI()
    {
        if (scoreImage != null)
        {
            scoreImage.gameObject.SetActive(true);
            // UI가 보이는지 디버그로 확인
            Debug.Log("Race UI is shown");
        }
    }

    public void HideRaceUI()
    {
        if (scoreImage != null)
        {
            scoreImage.gameObject.SetActive(false);
        }
    }
}