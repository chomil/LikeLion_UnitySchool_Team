using System.Collections;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using Game;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    private Dictionary<string, float> playerFinishTimes = new Dictionary<string, float>();
    private float raceStartTime;
    private bool isRaceActive = false;
    private const int MaxPlayers = 60;
    private HashSet<string> activePlayers = new HashSet<string>();
    
    [SerializedDictionary("Name","Bgm")]
    public SerializedDictionary<string, AudioClip> bgms;
    
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
    }
    
    private void OnApplicationQuit()
    {
        TcpProtobufClient.Instance.SendPlayerLogout(TCPManager.playerId);
    }
    

    void Update()
    {
        while (UnityMainThreadDispatcher.Instance.ExecutionQueue.Count > 0)
        {
            GameMessage msg = UnityMainThreadDispatcher.Instance.ExecutionQueue.Dequeue();
            /*if (msg.MessageCase == GameMessage.MessageOneofCase.Chat)
            {
                PlayerController.Instance.OnRecevieChatMsg(msg.Chat);
            }*/

            if (msg.MessageCase == GameMessage.MessageOneofCase.PlayerPosition)
            {
                PlayerController.Instance.OnOtherPlayerPositionUpdate(msg.PlayerPosition);
            }
            
            if (msg.MessageCase == GameMessage.MessageOneofCase.PlayerAnimState)
            {
                PlayerController.Instance.OnOtherPlayerAnimationStateUpdate(msg.PlayerAnimState);
            }

            if (msg.MessageCase == GameMessage.MessageOneofCase.SpawnPlayer)
            {
                PlayerController.Instance.SpawnOtherPlayer(msg.SpawnPlayer);
            }

            if (msg.MessageCase == GameMessage.MessageOneofCase.SpawnExistingPlayer)
            {
                PlayerController.Instance.SpawnOtherPlayer(msg.SpawnExistingPlayer);
            }

            if (msg.MessageCase == GameMessage.MessageOneofCase.Logout)
            {
                PlayerController.Instance.DespawnOtherPlayer(msg.Logout.PlayerId);
            }
        }
    }
    
    public void StartRace()
    {
        raceStartTime = Time.time;
        isRaceActive = true;
        playerFinishTimes.Clear();
        activePlayers.Clear();
        Debug.Log($"Race Started! Max players: {MaxPlayers}");
    }
    
    public bool RegisterPlayer(string playerId)
    {
        if (activePlayers.Count >= MaxPlayers)
        {
            Debug.Log($"Player {playerId} couldn't join. Max player limit reached.");
            return false;
        }
        
        activePlayers.Add(playerId);
        Debug.Log($"Player {playerId} joined. Total players: {activePlayers.Count}/{MaxPlayers}");
        return true;
    }
    
    public void PlayerFinished(string playerId)
    {
        if (!isRaceActive || !activePlayers.Contains(playerId)) return;

        if (!playerFinishTimes.ContainsKey(playerId))
        {
            float finishTime = Time.time - raceStartTime;
            playerFinishTimes.Add(playerId, finishTime);
            Debug.Log($"Player {playerId} finished in {finishTime:F2} seconds!");

            // 추가: PlayerController에 완주 정보 전달
            PlayerController.Instance.OnPlayerFinished(playerId);

            if (playerFinishTimes.Count == activePlayers.Count)
            {
                EndRace();
            }
        }
    }
    
    private void EndRace()
    {
        isRaceActive = false;
        Debug.Log("Race Ended! Final Results:");
        
        List<KeyValuePair<string, float>> sortedResults = new List<KeyValuePair<string, float>>(playerFinishTimes);
        sortedResults.Sort((pair1, pair2) => pair1.Value.CompareTo(pair2.Value));

        for (int i = 0; i < sortedResults.Count; i++)
        {
            Debug.Log($"{i + 1}. Player {sortedResults[i].Key}: {sortedResults[i].Value:F2} seconds");
        }
    }
    
    private int GetTotalPlayerCount()
    {
        // 실제 플레이어 수를 반환하는 로직을 구현
        // 연결된 클라이언트 수나 고정된 플레이어 수를 반환
        return 2; // 임시로 2명
    }

    public void StartNewRace()
    {
        playerFinishTimes.Clear();
        isRaceActive = false;
        // 플레이어 위치 초기화 등 새 레이스 시작 준비
        ResetPlayerPositions();
        StartRace();
    }
    private void ResetPlayerPositions()
    {
        // 모든 플레이어의 위치를 시작 지점으로 초기화하는 로직
        // foreach (var player in allPlayers)
        // {
        //      player.transform.position = startPosition;
        //      player.ResetState();
        // }
    }
}