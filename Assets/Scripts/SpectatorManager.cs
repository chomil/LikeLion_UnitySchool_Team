using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpectatorManager : MonoBehaviour
{
    public static SpectatorManager Instance { get; private set; }

    private List<string> activePlayerIds = new List<string>();
    private int currentSpectatingIndex = -1;

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

    public void EnterSpectatorMode(string playerId)
    {
        // 플레이어를 관전 모드로 전환
        PlayerController.Instance.SetPlayerToSpectatorMode(playerId);
        
        // UI 업데이트
        SpectatorUI.Instance.ShowSpectatorUI();

        // 다음 관전 대상으로 전환
        SwitchToNextSpectator();
    }

    public void UpdateActivePlayers(List<string> players)
    {
        activePlayerIds = players;
    }

    public void SwitchToNextSpectator()
    {
        if (activePlayerIds.Count == 0) return;

        currentSpectatingIndex = (currentSpectatingIndex + 1) % activePlayerIds.Count;
        string targetPlayerId = activePlayerIds[currentSpectatingIndex];
        
        PlayerController.Instance.SwitchSpectatorTarget(targetPlayerId);
        SpectatorUI.Instance.UpdateSpectatingPlayerInfo(targetPlayerId);
    }

    public void SwitchToPreviousSpectator()
    {
        if (activePlayerIds.Count == 0) return;

        currentSpectatingIndex = (currentSpectatingIndex - 1 + activePlayerIds.Count) % activePlayerIds.Count;
        string targetPlayerId = activePlayerIds[currentSpectatingIndex];
        
        PlayerController.Instance.SwitchSpectatorTarget(targetPlayerId);
        SpectatorUI.Instance.UpdateSpectatingPlayerInfo(targetPlayerId);
    }
}
