using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MatchingSceneUI : MonoBehaviour
{
    public TextMeshProUGUI MatchingPlayerText;

    private Tuple<int, int> matchingCount;
    
    // Start is called before the first frame update
    void Start()
    {
        matchingCount = SceneChanger.Instance.GetMatchingStatus();
    }

    // Update is called once per frame
    void Update()
    {
        matchingCount = SceneChanger.Instance.GetMatchingStatus();
        MatchingPlayerText.text = $"{matchingCount.Item1}/{matchingCount.Item2}";
    }
}
