using UnityEngine;
using System.Collections.Generic;
using System;
using Game;

public class UnityMainThreadDispatcher : MonoBehaviour
{
    public readonly Queue<GameMessage> ExecutionQueue = new Queue<GameMessage>();
    public readonly Queue<MatchingMessage> ExecutionMatchingQueue = new Queue<MatchingMessage>();
    
    public static UnityMainThreadDispatcher Instance { get; private set; }

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
    
    public void Enqueue(GameMessage msg)
    {
        ExecutionQueue.Enqueue(msg);
    }

    public void Enqueue(MatchingMessage msg)
    {
        ExecutionMatchingQueue.Enqueue(msg);
    }
}