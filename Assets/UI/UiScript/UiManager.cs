using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }

    public TextMeshProUGUI finishMessageText;
    public TextMeshProUGUI racePositionsText;
    public RaceResultsPanel raceResultsPanel;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void ShowFinishMessage()
    {
        finishMessageText.text = "골인!";
        finishMessageText.gameObject.SetActive(true);
    }

    public void UpdateRacePositions(int position, string playerId)
    {
        racePositionsText.text += $"{position}등: {playerId}\n";
    }

    public void ShowRaceResults(List<PlayerResult> results)
    {
        raceResultsPanel.Show(results);
    }
}

public struct PlayerResult
{
    public string playerId;
    public float finishTime;

    public PlayerResult(string id, float time)
    {
        playerId = id;
        finishTime = time;
    }
}
