using UnityEngine;
using System;
using System.Collections.Concurrent;
using System.Net.Sockets;
using System.Threading;
using Google.Protobuf;
using Game;

public class TcpProtobufClient_MultiThread : MonoBehaviour
{
    public static TcpProtobufClient_MultiThread Instance { get; private set; }
    
    private TcpClient tcpClient;
    private Thread receiveThread;
    private NetworkStream stream;
    private bool isRunning = false;

    private const string SERVER_IP = "127.0.0.1";
    private const int SERVER_PORT = 8888;
    
    private ConcurrentQueue<GameMessage> messageQueue = new ConcurrentQueue<GameMessage>();

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
    }

    void ConnectToServer()
    {
        try
        {
            tcpClient = new TcpClient(SERVER_IP, SERVER_PORT);
            stream = tcpClient.GetStream();
            isRunning = true;
            receiveThread = new Thread(ReceiveLoop);
            receiveThread.Start();

            Debug.Log("Connected to server.");
        }
        catch (Exception e)
        {
            Debug.LogError($"Error connecting to server: {e.Message}");
        }
    }

    void ReceiveLoop()
    {
        byte[] lengthBuffer = new byte[4];
        while (isRunning)
        {
            try
            {
                int bytesRead = stream.Read(lengthBuffer, 0, 4);
                if (bytesRead == 0) break; // Connection closed

                int length = BitConverter.ToInt32(lengthBuffer, 0);
                byte[] messageBuffer = new byte[length];
                bytesRead = stream.Read(messageBuffer, 0, length);
                if (bytesRead == 0) break; // Connection closed

                GameMessage gameMessage = GameMessage.Parser.ParseFrom(messageBuffer);
                messageQueue.Enqueue(gameMessage);
            }
            catch (Exception e)
            {
                Debug.LogError($"Error in receive loop: {e.Message}");
                break;
            }
        }
    }
    
    Vector3 prevPosition = Vector3.zero;

    void Update()
    {
        if (transform.position != prevPosition)
        {
            SendPlayerPosition("정모", transform.position.x, transform.position.y, transform.position.z);
        }
        prevPosition = transform.position;
    }

    public void SendPlayerPosition(string playerId, float x, float y, float z)
    {
        var position = new PlayerPosition
        {
            PlayerId = playerId,
            X = x,
            Y = y,
            Z = z
        };
        var message = new GameMessage
        {
            PlayerPosition = position
        };
        SendMessage(message);
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
        SendMessage(message);
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
        SendMessage(message);
    }

    private void SendMessage(GameMessage message)
    {
        if (tcpClient != null && tcpClient.Connected)
        {
            byte[] messageBytes = message.ToByteArray();
            byte[] lengthBytes = BitConverter.GetBytes(messageBytes.Length);

            // 메시지 길이를 먼저 보냅니다
            stream.Write(lengthBytes, 0, 4);
            // 메시지 본문을 보냅니다
            stream.Write(messageBytes, 0, messageBytes.Length);
        }
    }

    void OnDisable()
    {
        isRunning = false;
        if (receiveThread != null) receiveThread.Interrupt();
        if (stream != null) stream.Close();
        if (tcpClient != null) tcpClient.Close();
    }
}