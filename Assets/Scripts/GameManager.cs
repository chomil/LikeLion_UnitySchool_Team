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

        // RaceUI null 체크 추가
        if (RaceUI.Instance != null)
        {
            RaceUI.Instance.UpdateQualifiedCount(0, maxQualifiedPlayers);
        }
        else
        {
            Debug.LogWarning("RaceUI.Instance is null in GameManager Start()");
        }
    
        StartRace();
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
        }

        while (UnityMainThreadDispatcher.Instance?.ExecutionMatchingQueue.Count > 0)
        {
            MatchingMessage msg = UnityMainThreadDispatcher.Instance.ExecutionMatchingQueue.Dequeue();

            if (msg.MatchingCase == MatchingMessage.MatchingOneofCase.MatchingResponse)
            {
                SceneChanger.Instance.SetRaceMaps(msg.MatchingResponse);
            }
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        throw new NotImplementedException();
    }

    public void StartRace()
    {
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
        
        Debug.Log($"[HandleRaceFinish] Processing finish for player: {finishedPlayerId}, Current count: {currentQualifiedCount}, Max: {maxQualifiedPlayers}");
        
        // 이미 통과했거나 레이스가 끝났으면 무시
        if (qualifiedPlayers.Contains(finishedPlayerId))
        {
            Debug.Log($"[HandleRaceFinish] Player {finishedPlayerId} already qualified");
            return;
        }

        if (isRaceEnded)
        {
            Debug.Log($"[HandleRaceFinish] Race already ended");
            return;
        }

        // 최대 통과 인원 체크
        if (currentQualifiedCount >= maxQualifiedPlayers)
        {
            Debug.Log($"[HandleRaceFinish] Player {finishedPlayerId} eliminated - max qualified reached");
            HandlePlayerElimination(finishedPlayerId);
            return;
        }

        // 통과 처리
        currentQualifiedCount++;
        qualifiedPlayers.Add(finishedPlayerId);
        activePlayersForNextRound.Add(finishedPlayerId);
        Debug.Log($"[HandleRaceFinish] Player {finishedPlayerId} qualified! ({currentQualifiedCount}/{maxQualifiedPlayers})");

        // UI 업데이트
        RaceUI.Instance.UpdateQualifiedCount(currentQualifiedCount, maxQualifiedPlayers);
        
        // 로컬 플레이어인 경우 추가 처리
        if (finishedPlayerId == TCPManager.playerId)
        {
            Debug.Log($"[HandleRaceFinish] Local player {finishedPlayerId} qualified - updating UI and state");
            RaceUI.Instance.ShowStatusMessage("통과!");
            SoundManager.Instance.PlayQualifySound();
            PlayerMovement playerMovement = PlayerController.Instance.myPlayer.GetComponent<PlayerMovement>();
            if (playerMovement != null)
            {
                playerMovement.SetIdleState();
            }
        }
        
        // 통과 인원이 다 찼는지 체크
        if (currentQualifiedCount >= maxQualifiedPlayers)
        {
            Debug.Log($"[HandleRaceFinish] Max qualified players reached - eliminating remaining players");
        
            // 통과하지 못한 모든 플레이어를 탈락 처리
            foreach (string activePlayer in activePlayers)
            {
                if (!qualifiedPlayers.Contains(activePlayer))
                {
                    HandlePlayerElimination(activePlayer);
                }
            }
        
            // 다음 라운드로 전환
            EndRaceWithMaxQualified();
        }
    }
    
    
    private void HandleRaceEndMessage(RaceEndMessage raceEndMsg)
    {
        if (!isRaceEnded)
        {
            Debug.Log($"Received race end message from server");
            EndRaceWithMaxQualified();
        }
    }
    
    private void HandlePlayerElimination(string playerId)
    {
        Debug.Log($"Player {playerId} eliminated - maximum qualified players reached!");
    
        if (playerId == TCPManager.playerId)
        {
            RaceUI.Instance.ShowStatusMessage("탈락!");  // 탈락 메시지
            SoundManager.Instance.PlayEliminateSound();
            
            PlayerMovement playerMovement = PlayerController.Instance.myPlayer.GetComponent<PlayerMovement>();
            if (playerMovement != null)
            {
                playerMovement.SetIdleState();
                StartCoroutine(EnterSpectatorModeAfterDelay(playerId));
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
    
    public void EndRaceWithMaxQualified()
    {
        if (isRaceEnded) return;  // 이미 종료된 경우 중복 처리 방지
        
        isRaceEnded = true;
        Debug.Log($"Race ended - Maximum qualified players reached!");

        // 아직 도착하지 않은 모든 플레이어 탈락 처리
        foreach (string activePlayer in activePlayers)
        {
            if (!qualifiedPlayers.Contains(activePlayer))
            {
                HandlePlayerElimination(activePlayer);
            }
        }

        currentRound++;
        if (currentRound < QUALIFY_LIMITS.Length)
        {
            maxQualifiedPlayers = QUALIFY_LIMITS[currentRound];
            StartCoroutine(LoadNextMapWithDelay());
        }
        else
        {
            HandleGameWin(qualifiedPlayers[0]);
        }

        TcpProtobufClient.Instance.SendRaceEnd();
    }
    
    private IEnumerator LoadNextMapWithDelay()
    {
        yield return new WaitForSeconds(3f);  // 3초 대기
    
        if (currentRound >= QUALIFY_LIMITS.Length - 1)
        {
            // 우승자 처리
            HandleGameWin(qualifiedPlayers[0]);
        }
        else
        {
            // 다음 맵으로 이동
            SceneChanger.Instance.PlayRace();
        }
    }
    
    
    private IEnumerator EnterSpectatorModeAfterDelay(string playerId)
    {
        yield return new WaitForSeconds(2f);
        SpectatorManager.Instance.EnterSpectatorMode(playerId);
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
}