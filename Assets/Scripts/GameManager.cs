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
    [SerializeField] public int maxQualifiedPlayers = 10; // 첫 번째 맵의 통과 인원 (인스펙터에서 조정 가능)
    private int currentQualifiedCount = 0;
    private List<string> qualifiedPlayers = new List<string>();
    private bool isRaceEnded = false;
    private bool isFinalRace = false; // 현재 맵이 마지막 맵인지 여부
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
        // // 우승자 테스트용 코드
        // isFinalRace = true;  // 테스트를 위해 강제로 최종 라운드 설정
        // maxQualifiedPlayers = 1;  // 우승자 1명
        // Debug.Log("Test Mode: Final Race - Only one player can win!");
        
        // finalList에 있는 맵인지 확인하여 최종 레이스 여부 판단
        isFinalRace = SceneChanger.Instance.finalList.Contains(SceneChanger.Instance.GetCurrentScene());
        
        // 마지막 맵이면 통과 인원을 1명으로 설정
        if (isFinalRace)
        {
            maxQualifiedPlayers = 1;
            Debug.Log("Final Race: Only one player can win!");
        }
        else
        {
            maxQualifiedPlayers = 10; // 일반 레이스의 통과 인원
            Debug.Log($"Regular Race: {maxQualifiedPlayers} players can qualify");
        }
        RaceUI.Instance.UpdateQualifiedCount(0, maxQualifiedPlayers);
        StartRace();
    }

    public void InitializeData()
    {
        gameData.playerInfo.playerItems = new Dictionary<ItemType, string>();
        //gameData.playerInfo.playerItems.Add(ItemType.Upper,"없음");
        //gameData.playerInfo.playerItems.Add(ItemType.Lower,"없음");
        //임시로 랜덤 코스튬
        gameData.playerInfo.playerItems[ItemType.Upper] = gameData.allItemDatas[ItemType.Upper][Random.Range(0,6)].itemName;
        gameData.playerInfo.playerItems[ItemType.Lower] = gameData.allItemDatas[ItemType.Lower][Random.Range(0,6)].itemName;
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
            //var data = UnityMainThreadDispatcher.Instance.ExecutionQueue.Dequeue();
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

            if (msg.MessageCase == GameMessage.MessageOneofCase.PlayerCostume)
            {
                PlayerController.Instance.OnOtherPlayerCostumeUpdate(msg.PlayerCostume);
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

        while (UnityMainThreadDispatcher.Instance?.ExecutionMatchingQueue.Count > 0)
        {
            MatchingMessage msg = UnityMainThreadDispatcher.Instance.ExecutionMatchingQueue.Dequeue();

            if (msg.MatchingCase == MatchingMessage.MatchingOneofCase.MatchingResponse)
            {
                SceneChanger.Instance.SetRaceMaps(msg.MatchingResponse);
                //Debug.Log(msg.MatchingResponse.MapName);
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
        RaceUI.Instance.ShowRaceUI();
        RaceUI.Instance.UpdateQualifiedCount(0, maxQualifiedPlayers);
        RaceUI.Instance.HideStatusMessage();
        
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

        // 최대 통과 인원 체크
        if (currentQualifiedCount >= maxQualifiedPlayers)
        {
            // 통과 실패 처리
            HandlePlayerElimination(playerId);
            return;
        }

        // 통과 처리
        currentQualifiedCount++;
        qualifiedPlayers.Add(playerId);
        activePlayersForNextRound.Add(playerId);  // 다음 라운드 진출자 목록에 추가
        Debug.Log($"Player {playerId} qualified! ({currentQualifiedCount}/{maxQualifiedPlayers})");

        // UI 업데이트
        UpdateQualificationUI();
        
        if (playerId == TCPManager.playerId)
        {
            RaceUI.Instance.ShowStatusMessage("통과!");
            SoundManager.Instance.PlayQualifySound();  // 통과 소리
            PlayerMovement playerMovement = PlayerController.Instance.myPlayer.GetComponent<PlayerMovement>();
            if (playerMovement != null)
            {
                playerMovement.SetIdleState();
            }
        }

        // 최대 인원 도달 시 레이스 종료
        if (currentQualifiedCount >= maxQualifiedPlayers)
        {
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
    
    public void EndRace() 
    {
        EndRaceWithMaxQualified(); 
    }
    
    public void EndRaceWithMaxQualified()
    {
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

        // 현재 맵이 마지막 맵인지 확인
        if (SceneChanger.Instance.GetCurrentScene() == SceneChanger.Instance.finalList[0]) // 최종 맵 체크
        {
            // 우승자 처리
            HandleGameWin(qualifiedPlayers[0]);
        }
        else
        {
            // 다음 맵으로 이동
            StartCoroutine(LoadNextMap());
        }

        TcpProtobufClient.Instance.SendRaceEnd();
    }
    
    private IEnumerator LoadNextMap()
    {
        yield return new WaitForSeconds(5f); // 5초 대기
        SceneChanger.Instance.PlayRace(); // 다음 맵 로드
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

    private void UpdateQualificationUI()
    {
        RaceUI.Instance.UpdateQualifiedCount(currentQualifiedCount, maxQualifiedPlayers);
    
        if (isFinalRace)
        {
            if (currentQualifiedCount > 0)
            {
                RaceUI.Instance.ShowStatusMessage("우승!", true);  // isVictory = true
                SoundManager.Instance.PlayVictorySound();  // 우승 소리
            }
        }
        else if (currentQualifiedCount >= maxQualifiedPlayers)
        {
            RaceUI.Instance.ShowStatusMessage("통과!");  // 일반 통과
        }
    }

    public void ResetRace()
    {
        currentQualifiedCount = 0;
        qualifiedPlayers.Clear();
        isRaceEnded = false;
    }
}