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

        UpdateActivePlayersList();
        
        if (activePlayerIds.Count == 0)
        {
            Debug.LogWarning("No active players to spectate!");
            return;
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

        currentSpectatingIndex = 0;
        SwitchToCurrentSpectator();
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
            if (!player.HasFinished() && player.enabled)
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
        if (activePlayerIds.Count == 0 || spectatorCam == null) return;
        
        string targetPlayerId = activePlayerIds[currentSpectatingIndex];
        var targetPlayer = FindObjectsOfType<OtherPlayerTCP>()
            .FirstOrDefault(p => p.PlayerId == targetPlayerId);

        if(targetPlayer != null)
        {
            spectatorCam.SetTarget(targetPlayer.transform);
            SpectatorUI.Instance.UpdateSpectatingPlayerInfo(targetPlayerId);
        }
    }
}
