using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class SpeedBoostZone : MonoBehaviour
{
    public float boostMultiplier = 1f;
    public Vector3 direction; //가속을 줄 방향 설정
    
    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            var playerMove = other.GetComponent<PlayerMovement>();
            float dir = Vector3.Dot(playerMove.GetMoveVector(), direction);
            
            
            if(dir > 0)
                playerMove.PlayerSpeedControl(boostMultiplier); //가속 방향이 이동방향이랑 일치할 경우 
            else
                playerMove.PlayerSpeedControl(1/boostMultiplier); //반대인 경우
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            var playerMove = other.GetComponent<PlayerMovement>();
            playerMove.PlayerSpeedControl(0);
        }
    }
}
