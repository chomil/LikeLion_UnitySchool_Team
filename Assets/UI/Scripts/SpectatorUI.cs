using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SpectatorUI : MonoBehaviour
{
    public static SpectatorUI Instance { get; private set; }
    
    [Header("Spectator UI")]
    public GameObject spectatorPanel;
    public Text spectatingPlayerText;
    public Text controlsInfoText;
    
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

    private void Start()
    {
        HideSpectatorUI();
        UpdateControlsInfo();
    }

    private void Update()
    {
        if (spectatorPanel.activeSelf)
        {
            // Page Up 키를 누르면 다음 플레이어로 전환
            if (Input.GetKeyDown(KeyCode.PageUp))
            {
                SpectatorManager.Instance.SwitchToNextSpectator();
            }
            // Page Down 키를 누르면 이전 플레이어로 전환
            else if (Input.GetKeyDown(KeyCode.PageDown))
            {
                SpectatorManager.Instance.SwitchToPreviousSpectator();
            }
        }
    }

    public void ShowSpectatorUI()
    {
        spectatorPanel.SetActive(true);
    }

    public void HideSpectatorUI()
    {
        spectatorPanel.SetActive(false);
    }

    public void UpdateSpectatingPlayerInfo(string playerId)
    {
        spectatingPlayerText.text = $"현재 관전 중: Player {playerId}";
    }

    private void UpdateControlsInfo()
    {
        controlsInfoText.text = "Page Up: 다음 플레이어 | Page Down: 이전 플레이어";
    }
    
}
