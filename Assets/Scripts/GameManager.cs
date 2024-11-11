using System;
using System.Collections;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using Game;
using UnityEngine;
using Random = UnityEngine.Random;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    private float raceStartTime;
    private bool isRaceActive = false;
    private const int MaxPlayers = 30;
    private HashSet<string> activePlayers = new HashSet<string>();
    
    [SerializedDictionary("Name","Bgm")]
    public SerializedDictionary<string, AudioClip> bgms;

    public GameData gameData;
    
    private int currentRound = 0; 
    // 통과 처리는 서버에서 받아온걸로 쓰기
    private int curQualifyLimit = 0 ; //현재 라운드 통과 제한
    private int currentQualifiedCount = 0; //현재 통과 인원
    
    private List<string> qualifiedPlayers = new List<string>();
    private bool isRaceEnded = false;
    private bool isFinalRace = false;                             
    private HashSet<string> activePlayersForNextRound = new HashSet<string>();
    
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(this.gameObject);
            
            InitializeData();
        }
        else
        {
            Destroy(gameObject);
        }
    }
    
    private void Start()
    {
        InitRace();
    }

    public void InitializeData()
    {
        gameData.playerInfo.playerItems = new Dictionary<ItemType, string>();
        //gameData.playerInfo.playerItems.Add(ItemType.Upper,"없음");
        //gameData.playerInfo.playerItems.Add(ItemType.Lower,"없음");
        //임시로 랜덤 코스튬
        gameData.playerInfo.playerItems[ItemType.Pattern] = gameData.allItemDatas[ItemType.Pattern][Random.Range(0,gameData.allItemDatas[ItemType.Pattern].Count)].itemName;
        gameData.playerInfo.playerItems[ItemType.Color] = gameData.allItemDatas[ItemType.Color][Random.Range(0,gameData.allItemDatas[ItemType.Color].Count)].itemName;
        gameData.playerInfo.playerItems[ItemType.Face] = gameData.allItemDatas[ItemType.Face][Random.Range(0,gameData.allItemDatas[ItemType.Face].Count)].itemName;
        gameData.playerInfo.playerItems[ItemType.Upper] = gameData.allItemDatas[ItemType.Upper][Random.Range(0,1)].itemName;
        gameData.playerInfo.playerItems[ItemType.Lower] = gameData.allItemDatas[ItemType.Lower][Random.Range(0,1)].itemName;
        //
    }
    
    private void OnApplicationQuit()
    {
        TcpProtobufClient.Instance.SendPlayerLogout(TCPManager.playerId);
    }
    

    void Update()
    {
        while (UnityMainThreadDispatcher.Instance?.ExecutionQueue.Count > 0)
        {
            GameMessage msg = UnityMainThreadDispatcher.Instance.ExecutionQueue.Dequeue();
            
            if (msg == null)
            {
                continue;
            }

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
            
            if (msg.MessageCase == GameMessage.MessageOneofCase.PlayerCostume)
            {
                PlayerController.Instance.OnOtherPlayerCostumeUpdate(msg.PlayerCostume);
            }

            if (msg.MessageCase == GameMessage.MessageOneofCase.Logout)
            {
                PlayerController.Instance.DespawnOtherPlayer(msg.Logout.PlayerId);
            }
            
            if (msg.MessageCase == GameMessage.MessageOneofCase.RaceFinish)
            {
                HandleRaceFinishMessage(msg.RaceFinish);
            }

            // 기존 RaceEnd 메시지 처리도 유지
            if (msg.MessageCase == GameMessage.MessageOneofCase.RaceEnd)
            {
                HandleRaceEndMessage(msg.RaceEnd);
            }

            //몇번째 플레이어인지
            if (msg.MessageCase == GameMessage.MessageOneofCase.PlayerIndex)
            {
                PlayerController.Instance.InitPosInRace(msg.PlayerIndex.PlayerIndex);
            }
            
            //플레이어 카운트는 서버에서 받아서 업데이트
            if (msg.MessageCase == GameMessage.MessageOneofCase.PlayerCount)
            {
                UpdatePlayerCount(msg.PlayerCount.TotalPlayers, msg.PlayerCount.CurrentAlive, msg.PlayerCount.QualifyLimit);
            }
        }

        while (UnityMainThreadDispatcher.Instance?.ExecutionMatchingQueue.Count > 0)
        {
            MatchingMessage msg = UnityMainThreadDispatcher.Instance.ExecutionMatchingQueue.Dequeue();

            if (msg.MatchingCase == MatchingMessage.MatchingOneofCase.MatchingResponse)
            {
                SceneChanger.Instance.SetRaceMaps(msg.MatchingResponse);
            }
            
            if (msg.MatchingCase == MatchingMessage.MatchingOneofCase.MatchingUpdate)
            {
                SceneChanger.Instance.SetMatchingStatus(msg.MatchingUpdate);
            }
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        throw new NotImplementedException();
    }

    public void UpdatePlayerCount(int total, int alive, int limit)
    {
        Debug.Log($"Update Player Count total{total}, alive{alive}, limit{limit}");
        curQualifyLimit = limit;
        RaceUI.Instance?.UpdateQualifiedCount(total-alive, limit);
    }

    public void InitRace()
    {
        // 마지막 라운드 여부 확인 (finalList 체크 대신 currentRound로 판단)
        isFinalRace = (currentRound == 3);

        // 디버그 로그
        if (isFinalRace)
        {
            Debug.Log("Final Race: Only one player can win!");
        }
        else
        {
            Debug.Log($"Round {currentRound + 1}: Players to qualify: {curQualifyLimit}");
        }

        if (activePlayersForNextRound.Count > 0)
        {
            activePlayers = new HashSet<string>(activePlayersForNextRound);
            activePlayersForNextRound.Clear();
        }
        
        isRaceEnded = false;
        currentQualifiedCount = 0;
        qualifiedPlayers.Clear();
        
        // UI 초기화
        RaceUI.Instance?.ShowRaceUI();
        RaceUI.Instance?.UpdateQualifiedCount(0, curQualifyLimit);
        RaceUI.Instance?.HideStatusMessage();
        
        Debug.Log($"Race Started! Max players to qualify: {curQualifyLimit}");
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
        // 이미 통과했거나 레이스가 끝났으면 무시
        if (qualifiedPlayers.Contains(playerId) || isRaceEnded)
            return;
        Debug.Log($"Sending race finish message for player {playerId}");
        TcpProtobufClient.Instance.SendRaceFinish(playerId);
    }
    
    
    private void HandleRaceFinishMessage(RaceFinishMessage finishMsg) 
    {
        string finishedPlayerId = finishMsg.PlayerId;
    
        Debug.Log($"Handling race finish for player {finishedPlayerId}. Current qualified: {currentQualifiedCount}, Max: {curQualifyLimit}");

        // 통과 처리
        currentQualifiedCount++;
        qualifiedPlayers.Add(finishedPlayerId);
        activePlayersForNextRound.Add(finishedPlayerId);

        Debug.Log($"{currentQualifiedCount}명 통과 {curQualifyLimit}명 목표");
        
        // UI 업데이트
        Debug.Log($"피니시 플레이어 {finishedPlayerId}, 내 아이디 {TCPManager.playerId}");
        if (finishedPlayerId == TCPManager.playerId)
        {
            PlayerMovement playerMovement = PlayerController.Instance?.myPlayer?.GetComponent<PlayerMovement>();
            playerMovement?.SetControl(false);
            playerMovement?.SetFinished(true);
            
            RaceUI.Instance?.ShowStateWindow(RaceState.Qualify);
            SoundManager.Instance?.PlayQualifySound();
        }
    }
    
    
    private void HandleRaceEndMessage(RaceEndMessage raceEnd)
    {
        Debug.Log($"Received race end message for player: {raceEnd.PlayerId}");
    
        if (!isRaceEnded)
        {
            Debug.Log("Race ending process starting");
            EndRaceWithMaxQualified(raceEnd.PlayerId);
        }
        else
        {
            Debug.Log("Race already ended, ignoring end message");
        }
    }
    
    private void HandlePlayerElimination(string playerId)
    {
        Debug.Log($"Eliminating player {playerId}");

        if (playerId == TCPManager.playerId)
        {
            // 로컬 플레이어 탈락 처리
            RaceUI.Instance?.ShowStateWindow(RaceState.Eliminate);
            SoundManager.Instance?.PlayEliminateSound();
        
            PlayerMovement playerMovement = PlayerController.Instance?.myPlayer?.GetComponent<PlayerMovement>();
            if (playerMovement != null)
            {
                playerMovement.SetControl(false);
                playerMovement.SetFinished(true);
                SceneChanger.Instance.isRacing = false;
            }
        }
    }
    
    private bool IsAllPlayersFinished()
    {
        return activePlayers.Count > 0 && 
               (currentQualifiedCount >= curQualifyLimit || 
                currentQualifiedCount >= activePlayers.Count);
    }

    public void CheckRaceEndCondition()
    {
        if (!isRaceEnded && IsAllPlayersFinished())
        {
            EndRaceWithMaxQualified();
        }
    }
    
    public void EndRaceWithMaxQualified(string finishedPlayerId = "")
    {
        if (isRaceEnded) return;
   
        isRaceEnded = true;
        Debug.Log($"Race ended - Maximum qualified players reached!");
        
        //레이스 오버 메시지 출력
        RaceUI.Instance?.ShowStateWindow(RaceState.Over);
        
        //레이스 오버시 컨트롤 끄기
        PlayerMovement playerMovement = PlayerController.Instance?.myPlayer?.GetComponent<PlayerMovement>();
        if (playerMovement != null)
        {
            playerMovement.SetControl(false);
        }

        bool isLocalPlayerQualified = qualifiedPlayers.Contains(TCPManager.playerId);
        Debug.Log($"Local player qualified: {isLocalPlayerQualified}");


        // 탈락한 플레이어는 여기서 중단
        if (!isLocalPlayerQualified)
        {
            Debug.Log("Local player eliminated - stopping game progression");
            SceneChanger.Instance.isRacing = false;
            HandlePlayerElimination(TCPManager.playerId);
            Debug.Log($"Player {TCPManager.playerId} eliminated in delayed elimination");
            return;
        }

        // 통과한 플레이어는 다음 라운드 준비
        Debug.Log("Qualified player - proceeding to next round");
        currentRound++;
    
        if (currentRound < 4)
        {
            Debug.Log($"Loading next round: {currentRound}, Max qualified: {curQualifyLimit}");
        
            // 모든 통과 플레이어가 동시에 다음 맵으로 이동하도록 함
            SceneChanger.Instance.isRacing = true;  // 이 부분 추가
            StartCoroutine(LoadNextMapWithDelay());
        }
        else
        {
            HandleGameWin(qualifiedPlayers[0]);
        }
    }
    
    
    private IEnumerator LoadNextMapWithDelay()
    {
        Debug.Log("Starting map load delay");
        yield return new WaitForSeconds(7f);
    
        if (SceneChanger.Instance && SceneChanger.Instance.isRacing)
        {
            Debug.Log("Loading next map");
            SceneChanger.Instance.PlayRace();
        }
        else
        {
            Debug.LogWarning("Scene change cancelled - racing flag is false");
        }
    }
    
    
    private void HandleGameWin(string winnerId)
    {
        Debug.Log($"Player {winnerId} won the game!");
        // 우승 처리 (UI 표시, 효과음 등)
        if (winnerId == TCPManager.playerId)
        {
            RaceUI.Instance.ShowStateWindow(RaceState.Win);
        }
    }
    
    public void ResetRace()
    {
        currentQualifiedCount = 0;
        qualifiedPlayers.Clear();
        isRaceEnded = false;
    }
}