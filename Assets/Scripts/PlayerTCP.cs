using System;
using System.Collections;
using System.Collections.Generic;
using System.Numerics;
using UnityEngine;
using Random = UnityEngine.Random;
using Vector3 = UnityEngine.Vector3;

public class PlayerTCP : MonoBehaviour
{
    //public float Speed = 5.0f;
    
    private Vector3 prevPos;

    private bool hasFinished = false;
    public string PlayerId { get; private set; }
    
    // Start is called before the first frame update
    void Start()
    {
        /*임시로 서버에 보내는 아이디*/
        string tempId = Random.Range(0, 1000).ToString();
        
        // GameManager에 플레이어 등록
        if (GameManager.Instance.RegisterPlayer(tempId))
        {
            TCPManager.Instance.playerId = tempId;
            TcpProtobufClient.Instance.SendLoginMessage(tempId);

            // PlayerId 초기화 추가
            PlayerId = tempId;

            prevPos = transform.position;
        }
        else
        {
            // 플레이어 수가 초가된 경우 처리하기
            Debug.LogWarning("Max player limit reached. This player will be inactive.");
            gameObject.SetActive(false);
        }
    }

    private void Update()
    {
        if (!hasFinished)
        {
            Vector3 myRotation = transform.GetChild(0).transform.eulerAngles;
            TcpProtobufClient.Instance.SendPlayerPosition(TCPManager.Instance.playerId,
                transform.position.x, transform.position.y, transform.position.z,
                myRotation.x,myRotation.y,myRotation.z, GetComponent<PlayerMovement>().curAnimState.ToString());
            prevPos = transform.position;
        }
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("FinishLine") && !hasFinished)
        {
            FinishRace();
        }
    }
    
    public void FinishRace()
    {
        if (!hasFinished)
        {
            hasFinished = true;
            GameManager.Instance.PlayerFinished(PlayerId);
            if (IsLocalPlayer())
            {
                SendRaceFinishMessage();
                Debug.Log($"Local player {PlayerId} finished the race!");
            }
        
            // PlayerMovement의 SetIdleState 호출
            PlayerMovement playerMovement = GetComponent<PlayerMovement>();
            if (playerMovement != null)
            {
                playerMovement.SetIdleState();
            }
        }
    }
    
    
    private void SendRaceFinishMessage()
    {
        TcpProtobufClient.Instance.SendRaceFinish(PlayerId);
    }

    private bool IsLocalPlayer()
    {
        return TCPManager.Instance.playerId == PlayerId;
    }
}