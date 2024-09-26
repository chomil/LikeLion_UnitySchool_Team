using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TCPManager : MonoBehaviour
{
    public static TCPManager Instance { get; private set; }

    public string playerId;
    
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
}