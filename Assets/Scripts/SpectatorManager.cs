using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class SpectatorManager : MonoBehaviour
{
    public static SpectatorManager Instance { get; private set; }

    private List<string> activePlayerIds = new List<string>();
    private int currentSpectatingIndex = -1;
    private bool isSpectating = false;
    private GameObject spectatorCameraPrefab;
    private SpectatorCamera spectatorCam;
    
    private List<string> finishedPlayerIds = new List<string>(); // 완주한 플레이어 목록 추가

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
        spectatorCameraPrefab = Resources.Load<GameObject>("Prefabs/Spectatorcamera(player)");
        if(spectatorCameraPrefab == null)
        {
            Debug.LogError("Spectator camera prefab not found!");
        }
    }

    public void EnterSpectatorMode(string playerId)
    {
        Debug.Log($"EnterSpectatorMode called for player: {playerId}");
        
        if (isSpectating)
        {
            Debug.Log("Already in spectator mode");
            return;
        }

        UpdateActivePlayersList();
        
        
        // 방금 완주한 플레이어는 activePlayerIds에서 제외
        activePlayerIds.RemoveAll(id => id == playerId || finishedPlayerIds.Contains(id));
        
        if (activePlayerIds.Count == 0)
        {
            Debug.LogWarning("No active players to spectate!");
            return;
        }
        
        isSpectating = true;
        
        if(spectatorCam == null && spectatorCameraPrefab != null)
        {
            Debug.Log("Creating spectator camera");
            var camObj = Instantiate(spectatorCameraPrefab);
            spectatorCam = camObj.GetComponent<SpectatorCamera>();
        }
        else
        {
            Debug.Log($"Spectator camera status - cam: {spectatorCam}, prefab: {spectatorCameraPrefab}");
        }
        

        var playerObj = PlayerController.Instance.myPlayer;
        if (playerObj != null)
        {
            var playerCam = playerObj.GetComponentInChildren<Camera>();
            if(playerCam != null)
                playerCam.gameObject.SetActive(false);
                
            var playerMovement = playerObj.GetComponent<PlayerMovement>();
            if(playerMovement != null)
                playerMovement.enabled = false;
        }
        
        // 관전 가능한 다른 플레이어 찾기
        var availablePlayers = FindObjectsOfType<OtherPlayerTCP>()
            .Where(p => p.PlayerId != playerId && !p.HasFinished()) // 완주한 플레이어와 현재 플레이어 제외
            .ToList();

        // 첫 번째로 관전할 플레이어 선택 및 즉시 전환
        if (activePlayerIds.Count > 0)
        {
            // 랜덤한 플레이어 선택
            var randomIndex = Random.Range(0, availablePlayers.Count);
            var targetPlayer = availablePlayers[randomIndex];
        
            // 선택된 플레이어의 인덱스 찾기
            currentSpectatingIndex = activePlayerIds.IndexOf(targetPlayer.PlayerId);
        
            if (currentSpectatingIndex != -1)
            {
                spectatorCam.gameObject.SetActive(true);
                spectatorCam.SetTarget(targetPlayer.transform);
                SpectatorUI.Instance.UpdateSpectatingPlayerInfo(targetPlayer.PlayerId);
            }
        }
        
        SpectatorUI.Instance.ShowSpectatorUI();
    }

    public void ResetSpectatorMode()
    {
        isSpectating = false;
        
        if(spectatorCam != null)
        {
            spectatorCam.ClearTarget();
            spectatorCam.gameObject.SetActive(false);
        }

        SpectatorUI.Instance.HideSpectatorUI();
        
        activePlayerIds.Clear();
        currentSpectatingIndex = -1;
    }

    public void OnSceneLoaded()
    {
        ResetSpectatorMode();
    }

    private void UpdateActivePlayersList()
    {
        activePlayerIds.Clear();
        var players = FindObjectsOfType<OtherPlayerTCP>();
        
        foreach (var player in players)
        {
            // 완주하지 않은 플레이어만 관전 목록에 추가
            if (player != null && 
                player.enabled && 
                !finishedPlayerIds.Contains(player.PlayerId))  // HasFinished() 대신 finishedPlayerIds 체크
            {
                activePlayerIds.Add(player.PlayerId);
                Debug.Log($"Added active player for spectating: {player.PlayerId}");
            }
        }

        // 관전 가능한 플레이어가 없는 경우 처리
        if (activePlayerIds.Count == 0)
        {
            Debug.Log("No active players left to spectate");
            DisableSpectatorMode();
        }

        Debug.Log($"Total active players: {activePlayerIds.Count}");
        
    }
    
    private void DisableSpectatorMode()
    {
        isSpectating = false;
        if(spectatorCam != null)
        {
            spectatorCam.ClearTarget();
            spectatorCam.gameObject.SetActive(false);
        }
        SpectatorUI.Instance.HideSpectatorUI();
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
        if (activePlayerIds.Count == 0 || spectatorCam == null) 
        {
            DisableSpectatorMode();
            return;
        }
        
        string targetPlayerId = activePlayerIds[currentSpectatingIndex];
        var targetPlayer = FindObjectsOfType<OtherPlayerTCP>()
            .FirstOrDefault(p => p.PlayerId == targetPlayerId);

        if(targetPlayer != null)
        {
            spectatorCam.SetTarget(targetPlayer.transform);
            SpectatorUI.Instance.UpdateSpectatingPlayerInfo(targetPlayerId);
        }
        else
        {
            // 타겟 플레이어를 찾지 못했거나 이미 완주한 경우 다음 플레이어로 전환
            activePlayerIds.RemoveAt(currentSpectatingIndex);
            if (activePlayerIds.Count > 0)
            {
                currentSpectatingIndex = currentSpectatingIndex % activePlayerIds.Count;
                SwitchToCurrentSpectator();
            }
            else
            {
                DisableSpectatorMode();
            }
        }
    }
    
    public void OnPlayerFinished(string playerId)
    {
        // 완주한 플레이어 목록에 추가
        if (!finishedPlayerIds.Contains(playerId))
        {
            finishedPlayerIds.Add(playerId);
            Debug.Log($"Added {playerId} to finished players list");
        }
        
        // 플레이어가 완주했을 때 호출
        if (activePlayerIds.Contains(playerId))
        {
            activePlayerIds.Remove(playerId);
            // 현재 관전 중인 플레이어가 완주한 경우 다음 플레이어로 전환
            if (currentSpectatingIndex >= activePlayerIds.Count)
            {
                currentSpectatingIndex = 0;
            }
            if (activePlayerIds.Count > 0)
            {
                SwitchToCurrentSpectator();
            }
            else
            {
                DisableSpectatorMode();
            }
            
            // 관전 목록 업데이트
            UpdateActivePlayersList();
        }
    }
}
