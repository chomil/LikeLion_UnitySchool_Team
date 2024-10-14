using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class TCPManager : MonoBehaviour
{
    public static TCPManager Instance { get; private set; }

    public static string playerId;

    private static bool hasExecuted = false;
    
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
        //플레이어 아이디 생성
        GeneratePlayerId();
    }

    //게임 실행 시에 단 한번만 작동하도록 함(최종적으로 클라와 서버의 인증과정이 필요)
    private void GeneratePlayerId()
    {
        if (!hasExecuted)
        {
            playerId = Random.Range(0, 1000).ToString();
            GameManager.Instance.RegisterPlayer(playerId);
            TcpProtobufClient.Instance.SendLoginMessage(playerId);
            hasExecuted = true;
        }
    }
}