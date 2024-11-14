using System;
using System.Collections;
using System.Collections.Generic;
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

    [Header("Status UI Elements")] [SerializeField]
    private Image statusImage; // Round-over-border

    [SerializeField] private TextMeshProUGUI statusText;

    [Header("Victory UI Elements")] [SerializeField]
    private Image victoryImage; // 우승 이미지

    [SerializeField] private TextMeshProUGUI victoryText;

    private bool isMessageOpen = false;
    [SerializeField] private GameObject roundOver;
    [SerializeField] private GameObject roundQualified;
    [SerializeField] private GameObject roundEliminated;

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
        if (statusImage != null) statusImage.gameObject.SetActive(false);
        if (victoryImage != null) victoryImage.gameObject.SetActive(false);
        
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
                StartCoroutine(StateWindowCoroutine(roundOver));
                break;
            case RaceState.Qualify:
                StartCoroutine(StateWindowCoroutine(roundQualified));
                SoundManager.Instance?.PlayQualifySound();
                break;
            case RaceState.Eliminate:
                StartCoroutine(StateWindowCoroutine(roundEliminated));
                SoundManager.Instance?.PlayEliminateSound();
                break;
            case RaceState.Win:
                //임시
                StartCoroutine(StateWindowCoroutine(roundQualified));
                break;
            default:
                break;
        }
    }

    private IEnumerator StateWindowCoroutine(GameObject window)
    {    
        while (isMessageOpen)
        {
            yield return null;
        }
        //이 부분에서 효과음 넣거나, 애니메이션에서 효과음 넣기
        isMessageOpen = true;
        window.SetActive(true);
        yield return new WaitForSeconds(3.0f);
        window.SetActive(false);
        isMessageOpen = false;
    }

    public void HideStatusMessage()
    {
        roundOver.SetActive(false);
        roundQualified.SetActive(false);
        roundEliminated.SetActive(false);
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