using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CountDown : MonoBehaviour
{
    public void EndCountdown()
    {
        PlayerController.Instance.PlayersSetControl(true);
    }
}
