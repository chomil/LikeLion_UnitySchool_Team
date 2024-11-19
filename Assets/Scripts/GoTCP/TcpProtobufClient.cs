using UnityEngine;
using System;
using System.Net.Sockets;
using System.Threading;
using Google.Protobuf;
using Game;

public static class MessageTypes
{
    public const byte GameMessageType = 0x01;   // GameMessage 타입
    public const byte MatchingMessageType = 0x02; // MatchingMessage 타입
}

public class TcpProtobufClient : MonoBehaviour
{
    public static TcpProtobufClient Instance { get; private set; }
    
    private TcpClient tcpClient;
    private NetworkStream stream;
    private bool isRunning = false;

    private const string SERVER_IP = "127.0.0.1"; // 로컬호스트
    //private const string SERVER_IP = "211.188.58.240"; //공인 IP	
    private const int SERVER_PORT = 8888;

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
    
    void Start()
    {
        ConnectToServer();
        SendLoginMessage(TCPManager.playerId);
    }

    void ConnectToServer()
    {
        try
        {
            tcpClient = new TcpClient(SERVER_IP, SERVER_PORT);
            stream = tcpClient.GetStream();
            isRunning = true;
            StartReceiving();

            Debug.Log("Connected to server.");
        }
        catch (Exception e)
        {
            Debug.LogError($"Error connecting to server: {e.Message}");
        }
    }

    void StartReceiving()
    {
        byte[] lengthBuffer = new byte[5];
        stream.BeginRead(lengthBuffer, 0, 5, OnLengthReceived, lengthBuffer);
    }
    
    void OnLengthReceived(IAsyncResult ar)
    {
        try
        {
            int bytesRead = stream.EndRead(ar);
            if (bytesRead == 0) return; // 연결 종료

            byte[] lengthBuffer = (byte[])ar.AsyncState;
            byte messageType = lengthBuffer[0]; // 첫 번째 바이트는 메시지 타입
            uint length = BitConverter.ToUInt32(lengthBuffer, 1); // 나머지 4바이트로 메시지 길이
            byte[] messageBuffer = new byte[length];
            
            stream.BeginRead(messageBuffer, 0, (int)length, OnMessageReceived, new Tuple<byte, byte[]>(messageType, messageBuffer));
        }
        catch (Exception e)
        {
            Debug.LogError($"Error receiving message length: {e.Message}");
        }
    }

    void OnMessageReceived(IAsyncResult ar)
    {
        try
        {
            var state = (Tuple<byte, byte[]>)ar.AsyncState;
            byte messageType = state.Item1;
            byte[] messageBuffer = state.Item2;

            int bytesRead = stream.EndRead(ar);
            if (bytesRead == 0) return; // 연결 종료

            // 메시지를 파싱합니다.
            byte[] actualMessageBytes = new byte[bytesRead];
            Array.Copy(messageBuffer, 0, actualMessageBytes, 0, bytesRead);
            
            if (messageType == MessageTypes.GameMessageType)
            {
                // Protobuf 파싱
                GameMessage gameMessage = GameMessage.Parser.ParseFrom(actualMessageBytes);
                UnityMainThreadDispatcher.Instance.Enqueue(gameMessage);
            }
            else if (messageType == MessageTypes.MatchingMessageType)
            {
                MatchingMessage matchingMessage = MatchingMessage.Parser.ParseFrom(actualMessageBytes);
                UnityMainThreadDispatcher.Instance.Enqueue(matchingMessage);
            }
            
            StartReceiving(); // 다음 메시지 수신 대기
        }
        catch (Exception e)
        {
            Debug.LogError($"Error receiving message: {e.Message}");
        }
    }
    
    public void SendPlayerPosition(string playerId, float x, float y, float z, float rx, float ry, float rz, string animState)
    {
        var position = new PlayerPosition
        {
            PlayerId = playerId,
            X = x,
            Y = y,
            Z = z,
            Rx = rx,
            Ry = ry,
            Rz = rz
        };
        var message = new GameMessage
        {
            PlayerPosition = position
        };
        //SendMessage(message);
        SendGameMessage(message);
    }

    public void SendPlayerCostume(string playerId, int cosType, string cosName, string otherId)
    {
        otherId = otherId ?? "";
        
        var costume = new CostumeMessage
        {
            PlayerId = playerId,
            PlayerCostumeType = cosType,
            PlayerCostumeName = cosName,
            OtherPlayerId = otherId
        };
        var message = new GameMessage
        {
            PlayerCostume = costume
        };
        //SendMessage(message);
        SendGameMessage(message);
    }

    public void SendChatMessage(string sender, string content)
    {
        var chat = new ChatMessage
        {
            Sender = sender,
            Content = content
        };
        var message = new GameMessage
        {
            Chat = chat
        };
        //SendMessage(message);
        SendGameMessage(message);
    }
    
    public void SendLoginMessage(string playerId)
    {
        var login = new LoginMessage()
        {
            PlayerId = playerId
        };
        var message = new GameMessage
        {
            Login = login
        };
        //SendMessage(message);
        SendGameMessage(message);
    }

    public void SendPlayerAnimation(string playerAnim, string playerId, float speedF, float speedR)
    {
        var anim = new PlayerAnimation()
        {
            PlayerAnimState = playerAnim,
            PlayerId = playerId,
            SpeedForward = speedF,
            SpeedRight = speedR
        };
        var message = new GameMessage
        {
            PlayerAnimState = anim
        };
        //SendMessage(message);
        SendGameMessage(message);
    }
    
    public void SendPlayerLogout(string playerId)
    {
        var msg = new LogoutMessage()
        {
            PlayerId = playerId,
        };
        var message = new GameMessage
        {
            Logout = msg
        };
        //SendMessage(message);
        SendGameMessage(message);
    }

    public void SendSpawnExistingPlayer(string playerId)
    {
        var msg = new SpawnPlayer()
        {
            PlayerId = playerId,
        };
        var message = new GameMessage
        {
            SpawnExistingPlayer = msg
        };
        SendGameMessage(message);
    }
    
    public void SendMatchingRequest(string playerId, bool waiting)
    {
        var msg = new MatchingRequest()
        {
            PlayerId = playerId,
            Waiting = waiting
        };
        var message = new MatchingMessage()
        {
            MatchingRequest = msg
        };
        SendMatchingMessage(message);
    }
    
    public void SendPlayerGrabInfo(string playerId, bool grabbing)
    {
        var msg = new PlayerGrabInfo()
        {
            PlayerId = playerId,
            CurrentGrab = grabbing
        };
        var message = new GameMessage
        {
            PlayerGrabInfo = msg
        };
        SendGameMessage(message);
    }
    
    //메시지 전송 함수(GameMessage)
    private void SendGameMessage(GameMessage message)
    {
        SendMessage(MessageTypes.GameMessageType, message.ToByteArray());
    }

    //메시지 전송 함수(MatchingMessage)
    private void SendMatchingMessage(MatchingMessage message)
    {
        SendMessage(MessageTypes.MatchingMessageType, message.ToByteArray());
    }

    //메세지 전송 함수
    private void SendMessage(byte messageType, byte[] messageBytes)
    {
        if (tcpClient != null && tcpClient.Connected)
        {
            byte[] lengthBytes = BitConverter.GetBytes(messageBytes.Length + 1); // 타입 바이트 포함
            byte[] typeBytes = new byte[] { messageType };

            // 메시지 길이를 먼저 보냅니다
            stream.Write(lengthBytes, 0, 4);
            // 메시지 타입을 보냅니다
            stream.Write(typeBytes, 0, 1);
            // 메시지 본문을 보냅니다
            stream.Write(messageBytes, 0, messageBytes.Length);
        }
    }
    
    public void SendRaceFinish(string playerId, bool survive)
    {
        Debug.Log($"SendRaceFinish 메서드 시작: Player {playerId}");
        var finishMsg = new RaceFinishMessage
        {
            PlayerId = playerId,
            FinishTime = (long)(Time.time * 1000),  // 밀리초 단위의 완주 시간
            Survive = survive
        };
        var message = new GameMessage
        {
            RaceFinish = finishMsg
        };
        SendGameMessage(message);
        Debug.Log($"레이스 완주 메시지 전송 완료: Player {playerId}");
    }

    void OnDisable()
    {
        isRunning = false;
        if (stream != null) stream.Close();
        if (tcpClient != null) tcpClient.Close();
    }
    
    public void SendPlayerStateUpdate(string playerId, string state)
    {
        // // 여기에 서버로 플레이어 상태를 전송하는 로직을 구현합니다.
        // var stateUpdate = new PlayerStateUpdate
        // {
        //     PlayerId = playerId,
        //     State = state
        // };
        // var message = new GameMessage
        // {
        //     PlayerStateUpdate = stateUpdate
        // };
        // SendMessage(message);
    }
    
    public void SendRaceEnd()  // 추가된 부분
    {
        var raceEndMsg = new RaceEndMessage
        {
            // 필요한 정보 추가
            PlayerId = TCPManager.playerId
        };
        var message = new GameMessage
        {
            RaceEnd = raceEndMsg
        };
        SendGameMessage(message);
        Debug.Log($"Race end message sent from player {TCPManager.playerId}");
    }
}