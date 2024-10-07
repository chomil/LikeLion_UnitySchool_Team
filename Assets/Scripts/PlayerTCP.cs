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
    
    // Start is called before the first frame update
    void Start()
    {
        /*임시로 서버에 보내는 아이디*/
        string tempId = Random.Range(0, 1000).ToString();
        TCPManager.Instance.playerId = tempId;
        TcpProtobufClient.Instance.SendLoginMessage(tempId);

        prevPos = transform.position;
    }

    private void Update()
    {
        Vector3 dis = transform.position - prevPos;
        dis.Normalize();
        
        if (dis.sqrMagnitude > 0)
        {
            Vector3 myRotation = transform.GetChild(0).transform.eulerAngles;
            TcpProtobufClient.Instance.SendPlayerPosition(TCPManager.Instance.playerId,
                transform.position.x, transform.position.y, transform.position.z,
                myRotation.x,myRotation.y,myRotation.z, GetComponent<PlayerMovement>().curAnimState.ToString());
            prevPos = transform.position;
        }
    }
}