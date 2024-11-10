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
    private const int MaxPlayers = 60;
    private HashSet<string> activePlayers = new HashSet<string>();
    
    [SerializedDictionary("Name","Bgm")]
    public SerializedDictionary<string, AudioClip> bgms;

    public GameData gameData;
    
    // 통과 시스템
    // private readonly int[] QUALIFY_LIMITS = { 60, 30, 15, 8, 1 };  
    // 테스트용 코드
    private readonly int[] QUALIFY_LIMITS = { 3, 2, 1 };  // 4명 시작 기준: 3명 통과 -> 2명 통과 -> 1명 우승
    private int currentRound = 0;                                  
    public int maxQualifiedPlayers { get; private set; }          
    private int currentQualifiedCount = 0;
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
            /*if (msg.MessageCase == GameMessage.MessageOneofCase.Chat)
            {
                PlayerController.Instance.OnRecevieChatMsg(msg.Chat);
            }*/
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

    public void InitRace()
    {
        // maxQualifiedPlayers를 현재 라운드의 제한 인원으로 설정
        maxQualifiedPlayers = QUALIFY_LIMITS[currentRound];

        // 마지막 라운드 여부 확인 (finalList 체크 대신 currentRound로 판단)
        isFinalRace = (currentRound == QUALIFY_LIMITS.Length - 1);

        // 디버그 로그
        if (isFinalRace)
        {
            Debug.Log("Final Race: Only one player can win!");
        }
        else
        {
            Debug.Log($"Round {currentRound + 1}: Players to qualify: {maxQualifiedPlayers}");
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
        RaceUI.Instance?.UpdateQualifiedCount(0, maxQualifiedPlayers);
        RaceUI.Instance?.HideStatusMessage();
        
        Debug.Log($"Race Started! Max players to qualify: {maxQualifiedPlayers}");
        PlayerController.Instance?.SetTotalPlayersCount(activePlayers.Count);
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
    
        Debug.Log($"Handling race finish for player {finishedPlayerId}. Current qualified: {currentQualifiedCount}, Max: {maxQualifiedPlayers}");

        // 이미 최대 인원이 통과했는지 먼저 체크
        if (currentQualifiedCount >= maxQualifiedPlayers)
        {
            HandlePlayerElimination(finishedPlayerId);
            return;
        }

        // 통과 처리
        currentQualifiedCount++;
        qualifiedPlayers.Add(finishedPlayerId);
        activePlayersForNextRound.Add(finishedPlayerId);

        Debug.Log($"Player {finishedPlayerId} qualified. Current count: {currentQualifiedCount}/{maxQualifiedPlayers}");

        // UI 업데이트
        RaceUI.Instance?.UpdateQualifiedCount(currentQualifiedCount, maxQualifiedPlayers);

        if (finishedPlayerId == TCPManager.playerId)
        {
            RaceUI.Instance?.ShowStatusMessage("통과!");
            SoundManager.Instance?.PlayQualifySound();
            
            // 통과한 플레이어 관전 모드 전환
            Debug.Log($"[GameManager] Starting spectator mode for qualified player {finishedPlayerId}");
            StartCoroutine(EnterSpectatorModeAfterDelay(finishedPlayerId));
            
            // 통과 메시지를 잠시 후 숨김
            StartCoroutine(HideStatusMessageAfterDelay());
        }

        // 최대 인원 도달 시 나머지 플레이어 탈락 처리 및 다음 라운드 진행
        if (currentQualifiedCount >= maxQualifiedPlayers)
        {
            StartCoroutine(DelayedEliminationAndNextRound());
        }
    }
    
    private IEnumerator DelayedEliminationAndNextRound()
    {
        Debug.Log("Starting delayed elimination and next round");
        yield return new WaitForSeconds(1f);

        foreach (string activePlayer in activePlayers)
        {
            if (!qualifiedPlayers.Contains(activePlayer))
            {
                HandlePlayerElimination(activePlayer);
                Debug.Log($"Player {activePlayer} eliminated in delayed elimination");
            }
        }

        yield return new WaitForSeconds(2f);
        EndRaceWithMaxQualified();
    }
    
    private IEnumerator HideStatusMessageAfterDelay()
    {
        yield return new WaitForSeconds(2f); // 통과 메시지를 2초간 보여줌
        RaceUI.Instance?.HideStatusMessage();
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
            RaceUI.Instance?.ShowStatusMessage("탈락!");
            SoundManager.Instance?.PlayEliminateSound();
        
            PlayerMovement playerMovement = PlayerController.Instance?.myPlayer?.GetComponent<PlayerMovement>();
            if (playerMovement != null)
            {
                playerMovement.SetIdleState();
                SceneChanger.Instance.isRacing = false;
            }
        }
    }
    
    private bool IsAllPlayersFinished()
    {
        return activePlayers.Count > 0 && 
               (currentQualifiedCount >= maxQualifiedPlayers || 
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

        bool isLocalPlayerQualified = qualifiedPlayers.Contains(TCPManager.playerId);
        Debug.Log($"Local player qualified: {isLocalPlayerQualified}");

        // 모든 플레이어 상태 처리
        foreach (string activePlayer in activePlayers)
        {
            if (!qualifiedPlayers.Contains(activePlayer))
            {
                HandlePlayerElimination(activePlayer);
            }
        }

        // 탈락한 플레이어는 여기서 중단
        if (!isLocalPlayerQualified)
        {
            Debug.Log("Local player eliminated - stopping game progression");
            SceneChanger.Instance.isRacing = false;
            return;
        }

        // 통과한 플레이어는 다음 라운드 준비
        Debug.Log("Qualified player - proceeding to next round");
        currentRound++;

        // RaceUI 초기화
        RaceUI.Instance?.HideStatusMessage();
    
        if (currentRound < QUALIFY_LIMITS.Length)
        {
            maxQualifiedPlayers = QUALIFY_LIMITS[currentRound];
            Debug.Log($"Loading next round: {currentRound}, Max qualified: {maxQualifiedPlayers}");
        
            // 모든 통과 플레이어가 동시에 다음 맵으로 이동하도록 함
            SceneChanger.Instance.isRacing = true;  // 이 부분 추가
            StartCoroutine(LoadNextMapWithDelay());
        }
        else
        {
            HandleGameWin(qualifiedPlayers[0]);
        }

        // 서버에 라운드 종료 알림
        if (TCPManager.playerId == finishedPlayerId)  // 첫 번째로 완주한 플레이어만 전송
        {
            TcpProtobufClient.Instance.SendRaceEnd();
        }
    }
    
    
    private IEnumerator LoadNextMapWithDelay()
    {
        Debug.Log("Starting map load delay");
        yield return new WaitForSeconds(3f);
    
        if (SceneChanger.Instance != null && SceneChanger.Instance.isRacing)
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
            RaceUI.Instance.ShowStatusMessage("우승!", true);  // isVictory = true로 설정
        }
    }
    
    public void ResetRace()
    {
        currentQualifiedCount = 0;
        qualifiedPlayers.Clear();
        isRaceEnded = false;
    }
    
    // 관전 추가 코드 
    // 레이스 상태 확인을 위한 메서드 추가
    public bool IsRaceActive()
    {
        return !isRaceEnded;
    }
    
    // 관전 모드 전환을 위한 코루틴 추가
    private IEnumerator EnterSpectatorModeAfterDelay(string playerId)
    {
        Debug.Log($"[GameManager] Waiting before spectator mode transition...");
        yield return new WaitForSeconds(2f);
    
        if (SpectatorManager.Instance != null)
        {
            Debug.Log($"[GameManager] Activating spectator mode for player {playerId}");
            SpectatorManager.Instance.EnterSpectatorMode(playerId);
        }
        else
        {
            Debug.LogError("[GameManager] SpectatorManager.Instance is null!");
        }
    }
}