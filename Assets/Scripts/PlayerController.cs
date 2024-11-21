using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Game;
using Unity.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Serialization;
using GameObject = UnityEngine.GameObject;

public class PlayerController : MonoBehaviour
{
    public static PlayerController Instance { get; private set; }
    
    public PlayerTCP myPlayerTcpTemplate;
    public OtherPlayerTCP otherPlayerTcpTemplate;
    [SerializeField] public Vector3 LobbyPlayerPos;
    
    private PlayerTCP myPlayerTcp;
    private Dictionary<string, OtherPlayerTCP> _otherPlayers = new();
    private Dictionary<string, Dictionary<int, string>> _otherCostumeMessages = new();
    public GameObject myPlayer { get; private set; }
    public bool canControlPlayers = false;
    
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

    public void OtherPlayerFinish(string name)
    {
        if (_otherPlayers.ContainsKey(name))
        {
            _otherPlayers[name].FinishRace();
        }
    }

    private void Start()
    {
        InitMainScene();   
    }

    private void OnEnable()
    {
        SceneManager.sceneLoaded += OnMainLoaded;
    }
    
    private void OnDisable() 
    {
        SceneManager.sceneLoaded -= OnMainLoaded;
    }

    void OnMainLoaded(Scene scene, LoadSceneMode mode) //클라이언트의 씬이 로드되고 호출됨
    {

        canControlPlayers = false;
        
        Debug.Log("Loading Main Scene - Initializing Player");
        if (scene.name == "Main")
        {
            Cursor.lockState = CursorLockMode.None;
            
            if (myPlayer == null)
            {
                myPlayer = Instantiate(myPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
                myPlayerTcp = myPlayer.GetComponent<PlayerTCP>();
            }
            //로비에서 플레이어 위치
            myPlayer.transform.position = LobbyPlayerPos;
            myPlayer.transform.rotation = Quaternion.Euler(0f, 180f, 0f);
            //로비에서 플레이어 카메라, 움직임 못하게 하기
            myPlayer.GetComponent<PlayerMovement>().cameraArm.SetActive(false);
            myPlayer.GetComponent<PlayerMovement>().enabled = false;

            GameManager.Instance.currentRound = 0;
        }
        
        if (SceneChanger.Instance && SceneChanger.Instance.isRacing)
        {            
            Cursor.lockState = CursorLockMode.Locked;
            GameManager.Instance.InitRace();
            
            //모든 플레이어가 씬 로딩하기 전까지 멈추기
            Time.timeScale = 0f;

            // 기존 플레이어 오브젝트가 있다면 제거
            if (myPlayer != null)
            {
                Destroy(myPlayer);
            }
        
            // 다른 플레이어들도 모두 제거
            foreach (var otherPlayer in _otherPlayers.Values)
            {
                if (otherPlayer != null)
                {
                    Destroy(otherPlayer.gameObject);
                }
            }
            _otherPlayers.Clear();

            // 새로운 라운드 시작 시 플레이어 위치 초기화
            myPlayer = Instantiate(myPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
            myPlayerTcp = myPlayer.GetComponent<PlayerTCP>();
        
            // 서버에 새 라운드 시작을 알림
            TcpProtobufClient.Instance.SendSpawnExistingPlayer(TCPManager.playerId);
            SendPlayerAllCostumes();
        }
    }

    public void InitPosInRace(int playerIndex) //모든 플레이어의 씬 로드가 끝나면 호출됨
    {
        Debug.Log(playerIndex + "번째 플레이어 준비완료");
        if (SceneChanger.Instance && SceneChanger.Instance.isRacing)
        {
            GameObject[] startsObj = GameObject.FindGameObjectsWithTag("PlayerStart");
            foreach (GameObject startObj in startsObj)
            {
                PlayerStart start = startObj.GetComponent<PlayerStart>();
                if (start && start.index==playerIndex)
                {
                    start.InitPlayerPosToThis(myPlayer);
                    //모든 플레이어가 씬 로딩 되면 시작되게
                    Time.timeScale = 1f;
                }
            }
        }

        
        //맵 테스트용 플레이어 스타트 지점 설정 코드입니다
        if (playerIndex == -1)
        {
            GameObject startObj = GameObject.FindGameObjectWithTag("PlayerStart");
            PlayerStart start = startObj.GetComponent<PlayerStart>();
            start.InitPlayerPosToThis(myPlayer);
        }
    }
    
    public void SendPlayerAllCostumes(string otherName= "")
    {
        GameData data = GameManager.Instance.gameData;
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Upper,data.playerInfo.playerItems[ItemType.Upper],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Lower,data.playerInfo.playerItems[ItemType.Lower],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Pattern,data.playerInfo.playerItems[ItemType.Pattern],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Color,data.playerInfo.playerItems[ItemType.Color],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Face,data.playerInfo.playerItems[ItemType.Face],otherName);
    }
    private void InitMainScene()
    {
        string temp = SceneChanger.Instance?.GetCurrentScene();

        if (temp is "Main" or "Loading" or "Winner" or "Costumize")
        {
            return;
        }
        
        //매칭 없이 에디터에서 레이스 맵 테스트만 할 때 캐릭터 생성
        if (!myPlayer)
        {
            myPlayer = Instantiate(myPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
            myPlayerTcp = myPlayer.GetComponent<PlayerTCP>();
            InitPosInRace(-1);
        }
    }

    void Update()
    {
        while (UnityMainThreadDispatcher.Instance.ExecutionQueue.Count > 0)
        {
            GameMessage msg = UnityMainThreadDispatcher.Instance.ExecutionQueue.Dequeue();
            if (msg == null)
            {
                continue;
            }
        }
    }
    
    
    public void OnOtherPlayerPositionUpdate(PlayerPosition playerPosition)
    {
        if (playerPosition == null || string.IsNullOrEmpty(playerPosition.PlayerId))
        {
            Debug.LogError("Received null position update");
            return;
        }

        if (_otherPlayers.TryGetValue(playerPosition.PlayerId, out OtherPlayerTCP otherPlayer))
        {
            if (otherPlayer != null)  // null 체크 추가
            {
                otherPlayer.destination = new Vector3(playerPosition.X, playerPosition.Y, playerPosition.Z);
                otherPlayer.OtherRot = new Vector3(playerPosition.Rx, playerPosition.Ry, playerPosition.Rz);
            }
            else
            {
                _otherPlayers.Remove(playerPosition.PlayerId);  // 잘못된 참조 제거
            }
        }
    }

    public void PlayersSetControl(bool canControl) //시작 카운트 후 애니메이션 이벤트로 호출됨
    {
        Debug.Log("컨트롤 " + canControl);
        canControlPlayers = canControl;
        if (myPlayer)
        {
            myPlayer.GetComponent<PlayerMovement>().SetControl(canControl);
        }
    }
    

    public void SpawnOtherPlayer(SpawnPlayer serverPlayer)
    {
        GameObject tempPlayer = GameObject.Instantiate(otherPlayerTcpTemplate.gameObject, Vector3.zero, Quaternion.identity);
        OtherPlayerTCP otherPlayerTcp = tempPlayer.GetComponent<OtherPlayerTCP>();
        
        otherPlayerTcp.destination = new Vector3(serverPlayer.X, serverPlayer.Y, serverPlayer.Z);
        otherPlayerTcp.OtherRot = new Vector3(serverPlayer.Rx, serverPlayer.Ry, serverPlayer.Rz);
        otherPlayerTcp.PlayerId = serverPlayer.PlayerId;
        _otherPlayers.TryAdd(serverPlayer.PlayerId, otherPlayerTcp);

        GameManager.Instance.RegisterPlayer(serverPlayer.PlayerId);
        
        //코스튬 로드
        if (_otherCostumeMessages.TryGetValue(serverPlayer.PlayerId, out Dictionary<int, string> otherCostumeMessage))
        {
            foreach (var pair in otherCostumeMessage)
            {
                tempPlayer.GetComponent<PlayerCostume>()?.ChangeCostume((ItemType)pair.Key,pair.Value);
            }
        }
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
        if (string.IsNullOrEmpty(playerId))
        {
            Debug.LogError("Attempted to despawn player with null/empty ID");
            return;
        }

        if (_otherPlayers.TryGetValue(playerId, out OtherPlayerTCP otherPlayer))
        {
            if (otherPlayer != null)
            {
                Destroy(otherPlayer.gameObject);
            }
            _otherPlayers.Remove(playerId);
        }
        
        GameManager.Instance.RemoveActivePlayer(playerId);
    }
    
    // 관전 시스템
    public void SetPlayerToSpectatorMode(string playerId)
    {
        if (playerId == TCPManager.playerId)
        {
            // 로컬 플레이어의 카메라와 움직임 비활성화
            if (myPlayer != null)
            {
                var playerMovement = myPlayer.GetComponent<PlayerMovement>();
                if (playerMovement != null)
                {
                    playerMovement.enabled = false;
                }

                // 메인 카메라 비활성화
                var playerCamera = myPlayer.GetComponentInChildren<Camera>();
                if (playerCamera != null)
                {
                    playerCamera.gameObject.SetActive(false);
                }
            }
        }
    }

    public void SwitchSpectatorTarget(string targetPlayerId)
    {
        if (_otherPlayers.TryGetValue(targetPlayerId, out OtherPlayerTCP targetPlayer))
        {
            SpectatorCamera.Instance.SetTarget(targetPlayer.transform);
        }
    }

    public void OnOtherPlayerCostumeUpdate(CostumeMessage costumeMessage)
    {
        if (costumeMessage == null || string.IsNullOrEmpty(costumeMessage.PlayerId))
        {
            Debug.LogError("Received null or invalid costume message");
            return;
        }

        //다른 플레이어가 이미 있으면 업데이트, 없으면 메시지 저장해놓기
        if (_otherPlayers.TryGetValue(costumeMessage.PlayerId, out OtherPlayerTCP otherPlayer))
        {
            if (otherPlayer != null && otherPlayer.gameObject != null)  // null 체크 추가
            {
                var playerCostume = otherPlayer.GetComponent<PlayerCostume>();
                if (playerCostume != null)
                {
                    playerCostume.ChangeCostume((ItemType)costumeMessage.PlayerCostumeType,
                        costumeMessage.PlayerCostumeName);
                }
            }
            else
            {
                // 파괴된 오브젝트의 참조 제거
                _otherPlayers.Remove(costumeMessage.PlayerId);
            }
        }
        else
        {
            if (_otherCostumeMessages.TryGetValue(costumeMessage.PlayerId, out Dictionary<int,string> otherCostumeMessages))
            {
                otherCostumeMessages.TryAdd(costumeMessage.PlayerCostumeType, costumeMessage.PlayerCostumeName);
            }
            else
            {
                _otherCostumeMessages.Add(costumeMessage.PlayerId, new Dictionary<int, string>());
                _otherCostumeMessages[costumeMessage.PlayerId].TryAdd(costumeMessage.PlayerCostumeType, costumeMessage.PlayerCostumeName);
            }
        }
    }

    //서버에서 보낸 그랩 메시지 처리
    public void GrabbedMyPlayer(bool grabbed)
    {
        var pmRb = myPlayer.GetComponent<Rigidbody>();
        var pm = myPlayer.GetComponent<PlayerMovement>();

        if (grabbed)
        {
            pm.PlayerSpeedControl(0.2f);
            pmRb.mass = 2f;
        }
        else
        {
            pm.PlayerSpeedControl(0);
            pmRb.mass = 1f;
        }
    }
}