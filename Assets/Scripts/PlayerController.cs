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
    
    public PlayerTCP myPlayerTcpTemplate;
    public OtherPlayerTCP otherPlayerTcpTemplate;
    [SerializeField] public Vector3 LobbyPlayerPos;
    
    private PlayerTCP myPlayerTcp;
    private Dictionary<string, OtherPlayerTCP> _otherPlayers = new();
    private GameObject myPlayer;
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
        
        InitMainScene();   
    }

    private void OnEnable()
    {
        SceneManager.sceneLoaded += OnMainLoaded;
    }
    
    private void OnDisable() {
        SceneManager.sceneLoaded -= OnMainLoaded;
    }

    void OnMainLoaded(Scene scene, LoadSceneMode mode)
    {
        if (scene.name == "Main")
        {
            if (myPlayer == null)
            {
                myPlayer = Instantiate(myPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
            }
            //로비에서 플레이어 위치
            myPlayer.transform.position = LobbyPlayerPos;
            myPlayer.transform.rotation = Quaternion.Euler(0f, 180f, 0f);
            //로비에서 플레이어 카메라, 움직임 못하게 하기
            myPlayer.GetComponent<PlayerMovement>().cameraArm.SetActive(false);
            myPlayer.GetComponent<PlayerMovement>().enabled = false;
        }
    }

    private void InitMainScene()
    {
        string temp = SceneChanger.Instance?.GetCurrentScene();

        if (temp == "Main") return;
        
        if (temp == "Loading")
        {
            myPlayer.SetActive(false);
        }
        else
        {
            myPlayer = Instantiate(myPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
        }

        myPlayerTcp = myPlayer.GetComponent<PlayerTCP>();
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
        
        GameData data = GameManager.Instance.gameData;
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Upper,data.playerInfo.playerItems[ItemType.Upper]);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Lower,data.playerInfo.playerItems[ItemType.Lower]);
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
    public void OnOtherPlayerCostumeUpdate(CostumeMessage costumeMessage)
    {
        if (_otherPlayers.TryGetValue(costumeMessage.PlayerId, out OtherPlayerTCP otherPlayer))
        {      
            otherPlayer.GetComponent<PlayerCostume>()?.ChangeCostume((ItemType)costumeMessage.PlayerCostumeType,costumeMessage.PlayerCostumeName);
        }
    }
}