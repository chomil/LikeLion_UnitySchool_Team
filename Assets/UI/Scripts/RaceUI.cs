using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Serialization;

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
    }

    public void UpdateQualifiedCount(int current, int max)
    {
        if (scoreText != null)
        {
            scoreText.text = $"{current}/{max}";
        }
    }

    public void ShowStatusMessage(string message, bool isVictory = false)
    {
        if (isVictory)
        {
            // 우승 메시지 표시
            if (victoryImage != null && victoryText != null)
            {
                victoryImage.gameObject.SetActive(true);
                victoryText.text = message;
                victoryText.gameObject.SetActive(true);
            }
        }
        else
        {
            // 일반 통과/탈락 메시지 표시
            if (statusImage != null && statusText != null)
            {
                statusImage.gameObject.SetActive(true);
                statusText.text = message;
                statusText.gameObject.SetActive(true);
            }
        }
    }

    public void HideStatusMessage()
    {
        if (statusImage != null) statusImage.gameObject.SetActive(false);
        if (victoryImage != null) victoryImage.gameObject.SetActive(false);
    }

    public void ShowRaceUI()
    {
        if (scoreImage != null)
        {
            scoreImage.gameObject.SetActive(true);
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