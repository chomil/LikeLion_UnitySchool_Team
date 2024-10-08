using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FinishLine : MonoBehaviour
{ 
    private void OnTriggerEnter(Collider other)
    {
        PlayerTCP player = other.GetComponent<PlayerTCP>();
        if (player != null)
        {
            player.FinishRace();
        }
    }
}
