using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ManageToMatchingScene : MonoBehaviour
{
    public GameObject PlayerObj;

    private PlayerMovement playerMovement;
    private Animator animator;
    
    // Start is called before the first frame update
    void Start()
    {
        animator = PlayerObj.GetComponent<Animator>();
        animator.SetTrigger("MatchingTrigger");
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
