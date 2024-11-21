using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using AYellowpaper.SerializedCollections;
using Game;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using Random = UnityEngine.Random;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    private float raceStartTime;
    private bool isRaceActive = false;
    private const int MaxPlayers = 30;
    private HashSet<string> activePlayers = new HashSet<string>();


    public GameData gameData;


    //스테이지 관련 변수들

    public int currentRound = 0;

    // 통과 처리는 서버에서 받아온걸로 쓰기
    private int curQualifyLimit = 0; //현재 라운드 통과 제한
    private List<string> finishedPlayers = new List<string>();
    private bool isRaceEnded = false;
    private bool isFinalRace = false;
    private HashSet<string> activePlayersForNextRound = new HashSet<string>();

    public RaceType curRaceType;


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
#if UNITY_EDITOR
        EditorApplication.quitting += OnApplicationQuit;
#endif
        SoundManager.Instance.PlayBGM("Main",0.1f);
        InitRace();
    }

    public void InitializeData()
    {
        gameData.playerInfo.playerItems = new Dictionary<ItemType, string>();
        //gameData.playerInfo.playerItems.Add(ItemType.Upper,"없음");
        //gameData.playerInfo.playerItems.Add(ItemType.Lower,"없음");
        //임시로 랜덤 코스튬
        gameData.playerInfo.playerItems[ItemType.Pattern] =
            gameData.allItemDatas[ItemType.Pattern][Random.Range(0, gameData.allItemDatas[ItemType.Pattern].Count)]
                .itemName;
        gameData.playerInfo.playerItems[ItemType.Color] =
            gameData.allItemDatas[ItemType.Color][Random.Range(0, gameData.allItemDatas[ItemType.Color].Count)]
                .itemName;
        gameData.playerInfo.playerItems[ItemType.Face] =
            gameData.allItemDatas[ItemType.Face][Random.Range(0, gameData.allItemDatas[ItemType.Face].Count)].itemName;
        gameData.playerInfo.playerItems[ItemType.Upper] =
            gameData.allItemDatas[ItemType.Upper][Random.Range(0, 1)].itemName;
        gameData.playerInfo.playerItems[ItemType.Lower] =
            gameData.allItemDatas[ItemType.Lower][Random.Range(0, 1)].itemName;
        //
    }

    private void OnApplicationQuit()
    {
        TcpProtobufClient.Instance?.SendPlayerLogout(TCPManager.playerId);
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
                UpdatePlayerCount(msg.PlayerCount.TotalPlayers, msg.PlayerCount.CurrentAlive,
                    msg.PlayerCount.QualifyLimit);
            }

            if (msg.MessageCase == GameMessage.MessageOneofCase.PlayerGrabInfo)
            {
                PlayerController.Instance.GrabbedMyPlayer(msg.PlayerGrabInfo.CurrentGrab);
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
        if (curRaceType == RaceType.Race)
        {
            RaceUI.Instance?.UpdateQualifiedCount(total - alive, limit, curRaceType);
        }
        else
        {
            RaceUI.Instance?.UpdateQualifiedCount(total - alive, total - limit, curRaceType);
        }
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

        if (currentRound>0 && activePlayersForNextRound.Count > 0)
        {
            activePlayers = new HashSet<string>(activePlayersForNextRound);
        }

        isRaceEnded = false;
        //currentQualifiedCount = 0;
        finishedPlayers.Clear();
        activePlayersForNextRound.Clear();

        // UI 초기화
        RaceUI.Instance?.ShowRaceUI();
        UpdatePlayerCount(activePlayers.Count, activePlayers.Count, curQualifyLimit);
        //RaceUI.Instance?.HideStatusMessage();

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
    
    public void RemoveActivePlayer(string playerId)
    {
        activePlayers.Remove(playerId);
    }

    public void PlayerFinished(string playerId, bool survive)
    {
        // 이미 통과했거나 레이스가 끝났으면 무시
        if (finishedPlayers.Contains(playerId) || isRaceEnded)
            return;
        Debug.Log($"Sending race finish message for player {playerId}");
        TcpProtobufClient.Instance.SendRaceFinish(playerId, survive);
    }


    private void HandleRaceFinishMessage(RaceFinishMessage finishMsg)
    {
        string finishedPlayerId = finishMsg.PlayerId;

        // 통과 처리
        finishedPlayers.Add(finishedPlayerId);

        // UI 업데이트
        Debug.Log($"피니시 플레이어 {finishedPlayerId}, 내 아이디 {TCPManager.playerId}");
        if (finishedPlayerId == TCPManager.playerId)
        {
            PlayerMovement playerMovement = PlayerController.Instance?.myPlayer?.GetComponent<PlayerMovement>();
            playerMovement?.SetControl(false);
            playerMovement?.SetFinished(true);

            if (curRaceType == RaceType.Race)
            {
                SoundManager.Instance.PlaySfx("Finish");
                RaceUI.Instance?.ShowStateWindow(RaceState.Qualify);
            }
            else
            {
                RaceUI.Instance?.ShowStateWindow(RaceState.Eliminate);
            }

            // 끝난 플레이어 관전 모드 전환
            Debug.Log($"[GameManager] Starting spectator mode for qualified player {finishedPlayerId}");
            StartCoroutine(EnterSpectatorModeAfterDelay(finishedPlayerId));
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

            PlayerMovement playerMovement = PlayerController.Instance?.myPlayer?.GetComponent<PlayerMovement>();
            if (playerMovement != null)
            {
                playerMovement.SetControl(false);
                playerMovement.SetFinished(true);
                SceneChanger.Instance.isRacing = false;
            }
        }
    }

    public void EndRaceWithMaxQualified(string finishedPlayerId = "")
    {
        if (isRaceEnded) return;

        SoundManager.Instance.StopBGM();
        
        isRaceEnded = true;

        activePlayersForNextRound.Clear();

        if (curRaceType == RaceType.Race) //레이스 
        {
            activePlayersForNextRound = new HashSet<string>(finishedPlayers);
        }
        else //레이스 라운드가 아니라 생존 라운드 이면
        {
            foreach (var playerId in activePlayers)
            {
                if (!finishedPlayers.Contains(playerId))
                {
                    activePlayersForNextRound.Add(playerId);
                }
            }
        }

        Debug.Log($"Race ended - Maximum qualified players reached!");

        //레이스 오버 메시지 출력
        RaceUI.Instance?.ShowStateWindow(RaceState.Over);

        //레이스 오버시 컨트롤 끄기
        PlayerController.Instance.PlayersSetControl(false);
        PlayerMovement playerMovement = PlayerController.Instance?.myPlayer?.GetComponent<PlayerMovement>();
        if (playerMovement != null)
        {
            playerMovement.SetFinished(true);
        }

        bool isLocalPlayerQualified = activePlayersForNextRound.Contains(TCPManager.playerId);
        Debug.Log($"Local player qualified: {isLocalPlayerQualified}");


        // 탈락한 플레이어는 여기서 중단
        if (!isLocalPlayerQualified)
        {
            Debug.Log("Local player eliminated - stopping game progression");
            if (curRaceType == RaceType.Race)
            {
                HandlePlayerElimination(TCPManager.playerId);
                Debug.Log($"Player {TCPManager.playerId} eliminated in delayed elimination");
            }

            SceneChanger.Instance.isRacing = false;
            
            StartCoroutine(RaceUI.Instance?.OpenExitWindow(7.0f));
            return;
        }


        currentRound++;
        Debug.Log($"currentRound: {currentRound}, activePlayersForNextRound.Count: {activePlayersForNextRound.Count}");
        if (currentRound < 4 && activePlayersForNextRound.Count > 1)
        {
            Debug.Log($"Loading next round: {currentRound}, Max qualified: {curQualifyLimit}");
            // 통과한 플레이어는 다음 라운드 준비
            Debug.Log("Qualified player - proceeding to next round");
            if (curRaceType != RaceType.Race)
            {
                RaceUI.Instance?.ShowStateWindow(RaceState.Qualify);
            }

            // 모든 통과 플레이어가 동시에 다음 맵으로 이동하도록 함
            SceneChanger.Instance.isRacing = true; // 이 부분 추가
            StartCoroutine(LoadNextMapWithDelay());
        }
        else if(activePlayersForNextRound.Count==1)
        {
            HandleGameWin(activePlayersForNextRound.First());
        }
    }

    private IEnumerator LoadSceneWithDelay(float time, string name)
    {
        yield return new WaitForSeconds(time);
        SceneChanger.Instance.isRacing = false;
        SceneManager.LoadScene(name);
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
            RaceUI.Instance?.ShowStateWindow(RaceState.Win);
            //우승자 씬으로 넘어가기
            StartCoroutine(LoadSceneWithDelay(7, "Winner"));
        }
    }

    public void ResetRace()
    {
        finishedPlayers.Clear();
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