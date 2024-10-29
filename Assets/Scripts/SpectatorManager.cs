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

        // 다음 관전 대상으로 전환
        SwitchToNextSpectator();
        
        Debug.Log($"Entering spectator mode for player: {playerId}");
        
        // 활성 플레이어 목록 갱신
        UpdateActivePlayersList();
        
        if (activePlayerIds.Count == 0)
        {
            Debug.LogWarning("No active players to spectate!");
            return;
        }

        // 현재 플레이어를 관전자로 전환
        PlayerController.Instance.SetPlayerToSpectatorMode(playerId);
        
        // UI 활성화
        SpectatorUI.Instance.ShowSpectatorUI();

        // 첫 번째 관전 대상 설정
        currentSpectatingIndex = 0;
        SwitchToCurrentSpectator();
    }

    public void UpdateActivePlayers(List<string> players)
    {
        activePlayerIds = players;
    }
    
    private void UpdateActivePlayersList()
    {
        activePlayerIds.Clear();
        var players = FindObjectsOfType<OtherPlayerTCP>();
        
        foreach (var player in players)
        {
            if (!player.HasFinished() && player.enabled)  // 활성화된 플레이어만 추가
            {
                activePlayerIds.Add(player.PlayerId);
                Debug.Log($"Added active player: {player.PlayerId}");
            }
        }

        Debug.Log($"Total active players: {activePlayerIds.Count}");
    }

    public void SwitchToNextSpectator()
    {
        if (activePlayerIds.Count == 0) return;
        currentSpectatingIndex = (currentSpectatingIndex + 1) % activePlayerIds.Count;
        SwitchToCurrentSpectator();
    }

    public void SwitchToPreviousSpectator()
    {
        if (activePlayerIds.Count == 0) return;
        currentSpectatingIndex--;
        if (currentSpectatingIndex < 0) 
            currentSpectatingIndex = activePlayerIds.Count - 1;
        SwitchToCurrentSpectator();
    }
    
    private void SwitchToCurrentSpectator()
    {
        if (activePlayerIds.Count == 0) return;
        
        string targetPlayerId = activePlayerIds[currentSpectatingIndex];
        Debug.Log($"Switching to spectator target: {targetPlayerId}");
        
        PlayerController.Instance.SwitchSpectatorTarget(targetPlayerId);
        SpectatorUI.Instance.UpdateSpectatingPlayerInfo(targetPlayerId);
    }
}
