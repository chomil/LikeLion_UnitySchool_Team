using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class RaceResultsPanel : MonoBehaviour
{
    public TextMeshProUGUI titleText;
    public TextMeshProUGUI[] playerResultTexts;
    public Button closeButton;

    private void Start()
    {
        closeButton.onClick.AddListener(Hide);
        Hide(); // 시작 시 패널을 숨깁니다
    }

    public void Show(List<PlayerResult> results)
    {
        gameObject.SetActive(true);
        UpdateResults(results);
    }

    public void Hide()
    {
        gameObject.SetActive(false);
    }

    private void UpdateResults(List<PlayerResult> results)
    {
        for (int i = 0; i < playerResultTexts.Length; i++)
        {
            if (i < results.Count)
            {
                playerResultTexts[i].text = $"{i + 1}. {results[i].playerId} - {results[i].finishTime:F2}s";
                playerResultTexts[i].gameObject.SetActive(true);
            }
            else
            {
                playerResultTexts[i].gameObject.SetActive(false);
            }
        }
    }
}