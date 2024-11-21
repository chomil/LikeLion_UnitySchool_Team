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
        //string tempId = Random.Range(0, 1000).ToString();
        
        // GameManager에 플레이어 등록
        if (GameManager.Instance.RegisterPlayer(TCPManager.playerId))
        {
            /*TCPManager.Instance.playerId = tempId;
            TcpProtobufClient.Instance.SendLoginMessage(tempId);*/

            // PlayerId 초기화 추가
            PlayerId = TCPManager.playerId;
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
            if (prevPos != transform.position)
            {
                TcpProtobufClient.Instance?.SendPlayerPosition(TCPManager.playerId,
                transform.position.x, transform.position.y, transform.position.z,
                myRotation.x,myRotation.y,myRotation.z, GetComponent<PlayerMovement>().curAnimState.ToString());
            }
            prevPos = transform.position;
        }
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (!hasFinished)
        {
            
            if (other.CompareTag("FinishLine"))
            {
                Debug.Log($"Player {PlayerId} entered finish line");
                FinishRace(true);
            }
            else if (other.CompareTag("Water"))
            {
                Debug.Log($"Player {PlayerId} fall in water");
                FinishRace(false);
            }
        }
    }
    
    public void FinishRace(bool survive)
    {
        if (!hasFinished)
        {
            hasFinished = true;
        
            // 완주 상태를 서버에 전송
            GameManager.Instance.PlayerFinished(PlayerId, survive);
        
            // 완주 후 애니메이션/위치 동기화를 위한 마지막 상태 전송
            Vector3 myRotation = transform.GetChild(0).transform.eulerAngles;
            TcpProtobufClient.Instance?.SendPlayerPosition(
                TCPManager.playerId,
                transform.position.x, transform.position.y, transform.position.z,
                myRotation.x, myRotation.y, myRotation.z,
                "Idle"  // 완주 시 Idle 상태로 변경
            );
            
            
            // SpectatorManager에 완주 알림
            SpectatorManager.Instance?.OnPlayerFinished(PlayerId);
        }
    }
    public bool HasFinished()
    {
        return hasFinished;
    }
    

    private bool IsLocalPlayer()
    {
        return TCPManager.playerId == PlayerId;
    }
}