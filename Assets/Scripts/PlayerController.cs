using System.Collections;
using System.Collections.Generic;
using Game;
using Unity.Collections;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public static PlayerController Instance { get; private set; }

    private Player myPlayer;
    private Dictionary<string, OtherPlayer> _otherPlayers = new();

    public Player MyPlayerTemplate;
    public OtherPlayer OtherPlayerTemplate;
    
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
        GameObject SpawnPlayer = GameObject.Instantiate(MyPlayerTemplate.gameObject, Vector3.zero, Quaternion.identity);
        myPlayer = SpawnPlayer.GetComponent<Player>();
    }

    /*public void OnRecevieChatMsg(ChatMessage chatmsg) //유저 간의 채팅 기능
    {
        UIManager.Instance.OnRecevieChatMsg(chatmsg);
    }*/
    
    public void OnOtherPlayerPositionUpdate(PlayerPosition playerPosition)
    {
        if (_otherPlayers.TryGetValue(
                playerPosition.PlayerId, out OtherPlayer otherPlayer))
        {
            otherPlayer.destination = new Vector3(playerPosition.X, playerPosition.Y, playerPosition.Z);
            otherPlayer.OtherRot = new Vector3(playerPosition.Rx, playerPosition.Ry, playerPosition.Rz);
            return;
        }
        
        GameObject SpawnPlayer = GameObject.Instantiate(OtherPlayerTemplate.gameObject, 
            new Vector3(playerPosition.X, playerPosition.Y + 1f, playerPosition.Z), 
            Quaternion.Euler(playerPosition.Rx,playerPosition.Ry,playerPosition.Rz));
        _otherPlayers.Add(playerPosition.PlayerId, SpawnPlayer.GetComponent<OtherPlayer>());
    }
}