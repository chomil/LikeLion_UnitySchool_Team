using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Game;
using Unity.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Serialization;

public class PlayerController : MonoBehaviour
{
    public static PlayerController Instance { get; private set; }

    private PlayerTCP myPlayerTcp;
    private Dictionary<string, OtherPlayerTCP> _otherPlayers = new();
    private GameObject SpawnPlayer;

    public PlayerTCP myPlayerTcpTemplate;
    public OtherPlayerTCP otherPlayerTcpTemplate;
    
    private int finishedPlayersCount = 0;
    private int totalPlayersCount;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
        SpawnPlayer = Instantiate(myPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
    }

    void Start()
    {
        //Main씬에서 플레이어 리스폰되지 않게 하기(임시)
        string temp = SceneChanger.Instance.GetCurrentScene();
        if (temp == "Main" || temp == "Loading")
        {
            SpawnPlayer.SetActive(false);
            gameObject.SetActive(false);
        }
        else
        {
            gameObject.SetActive(true);
        }

        myPlayerTcp = SpawnPlayer.GetComponent<PlayerTCP>();
    }

    /*public void OnRecevieChatMsg(ChatMessage chatmsg) //유저 간의 채팅 기능
    {
        UIManager.Instance.OnRecevieChatMsg(chatmsg);
    }*/
    
    void Update()
    {
        while (UnityMainThreadDispatcher.Instance.ExecutionQueue.Count > 0)
        {
            GameMessage msg = UnityMainThreadDispatcher.Instance.ExecutionQueue.Dequeue();
        
            if (msg.MessageCase == GameMessage.MessageOneofCase.RaceFinish)
            {
                OnRaceFinishMessageReceived(msg.RaceFinish);
            }
        }
    }
    
    
    public void OnOtherPlayerPositionUpdate(PlayerPosition playerPosition)
    {
        if (_otherPlayers.TryGetValue(
                playerPosition.PlayerId, out OtherPlayerTCP otherPlayer))
        {
            otherPlayer.destination = new Vector3(playerPosition.X, playerPosition.Y, playerPosition.Z);
            otherPlayer.OtherRot = new Vector3(playerPosition.Rx, playerPosition.Ry, playerPosition.Rz);
            return;
            
        }
    }
    
    public void SetTotalPlayersCount(int count)
    {
        totalPlayersCount = count;
    }
    
    public void OnPlayerFinished(string playerId)
    {
        finishedPlayersCount++;
        Debug.Log($"Player {playerId} finished. {finishedPlayersCount}/{totalPlayersCount} players have finished.");
        
        if (finishedPlayersCount == totalPlayersCount)
        {
            EndRace();
        }
    }
    
    private void EndRace()
    {
        Debug.Log("All players have finished the race!");
        GameManager.Instance.EndRace();
        
    }
    
    public void OnRaceFinishMessageReceived(RaceFinishMessage finishMessage)
    {
        Debug.Log($"Race finish message received for player: {finishMessage.PlayerId}");
        OnPlayerFinished(finishMessage.PlayerId);
    }

    public void SpawnOtherPlayer(SpawnPlayer serverPlayer)
    {
        GameObject SpawnPlayer = GameObject.Instantiate(otherPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
        OtherPlayerTCP otherPlayerTcp = SpawnPlayer.GetComponent<OtherPlayerTCP>();
        
        otherPlayerTcp.destination = new Vector3(serverPlayer.X, serverPlayer.Y, serverPlayer.Z);
        otherPlayerTcp.OtherRot = new Vector3(serverPlayer.Rx, serverPlayer.Ry, serverPlayer.Rz);
        
        _otherPlayers.TryAdd(serverPlayer.PlayerId, otherPlayerTcp);
    }


    public void OnOtherPlayerAnimationStateUpdate(PlayerAnimation playerAnimation)
    {
        if (_otherPlayers.TryGetValue(
                playerAnimation.PlayerId, out OtherPlayerTCP otherPlayer))
        {
            otherPlayer.AnimTrigger(playerAnimation);
        }
    }

    public void DespawnOtherPlayer(string playerId)
    {
        if (_otherPlayers.TryGetValue(playerId, out OtherPlayerTCP otherPlayer))
        {
            Destroy(otherPlayer.gameObject);
            _otherPlayers.Remove(playerId);
        }
    }
    
    // 관전 시스템
    public void SetPlayerToSpectatorMode(string playerId)
    {
        if (playerId == TCPManager.playerId)
        {
            // 로컬 플레이어를 관전 모드로 설정
            myPlayerTcp.GetComponent<PlayerMovement>().EnterSpectatorMode();
        }
        // 서버에 플레이어의 상태 변경을 알림
        TcpProtobufClient.Instance.SendPlayerStateUpdate(playerId, "Spectating");
    }

    public void SwitchSpectatorTarget(string targetPlayerId)
    {
        foreach (var otherPlayerTcp in _otherPlayers)
        {
            otherPlayerTcp.Value.GetComponent<SpectatorCamera>().ClearCamera();
        }

        if (_otherPlayers.TryGetValue(targetPlayerId, out OtherPlayerTCP targetPlayer))
        {
            targetPlayer.GetComponent<SpectatorCamera>().SetCamera();
        }
    }
}