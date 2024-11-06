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
                playerMove.StartBoostSpeed(boostMultiplier);
            else
                playerMove.StartBoostSpeed(1/boostMultiplier);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            var playerMove = other.GetComponent<PlayerMovement>();
            playerMove.EndBoostSpeed();
        }
    }
}
