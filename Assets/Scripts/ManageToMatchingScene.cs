using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ManageToMatchingScene : MonoBehaviour
{
    public GameObject PlayerObj;
    public TextMeshProUGUI MatchingPlayerText;

    private PlayerMovement playerMovement;
    private Animator animator;
    private Tuple<int, int> matchingCount;
    
    // Start is called before the first frame update
    void Start()
    {
        animator = PlayerObj.GetComponent<Animator>();
        animator.SetTrigger("MatchingTrigger");
        
        matchingCount = SceneChanger.Instance.GetMatchingStatus();
    }

    // Update is called once per frame
    void Update()
    {
        matchingCount = SceneChanger.Instance.GetMatchingStatus();
        MatchingPlayerText.text = $"{matchingCount.Item1}/{matchingCount.Item2}";
    }
}
