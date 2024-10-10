using System;
using System.Collections;
using System.Collections.Generic;
using Google.Protobuf.WellKnownTypes;
using Unity.VisualScripting;
using UnityEngine;
using Enum = System.Enum;
using Game;

public class OtherPlayerTCP : MonoBehaviour
{
    public Vector3 destination;
    public Vector3 OtherRot;
    public AnimState otherAnimState;

    private Animator _animator;
    private Rigidbody _rb;
    
    private Renderer _renderer;
    private bool hasFinished = false;

    void Start()
    {
        _animator = GetComponent<Animator>();
        _rb = GetComponent<Rigidbody>();
        _renderer = GetComponentInChildren<Renderer>();
    }

    void Update()
    {
        transform.rotation = Quaternion.Euler(OtherRot);
        transform.position = destination;
    }
    
    public void FinishRace()
    {
        if (!hasFinished)
        {
            hasFinished = true;
        
            // 플레이어 움직임 멈춤
            _rb.isKinematic = true;
        }
    }

    

    public void AnimTrigger(PlayerAnimation pa)
    {
        otherAnimState = (AnimState)Enum.Parse(typeof(AnimState), pa.PlayerAnimState);

        switch (otherAnimState)
        {
            case AnimState.Idle:
            case AnimState.Move:
                _animator.SetBool("isLanded", true);
                _animator.SetFloat("SpeedForward",pa.SpeedForward);
                _animator.SetFloat("SpeedRight",pa.SpeedRight);
                break;
            case AnimState.Jump:
                _animator.SetBool("isLanded", false);
                _animator.SetTrigger("JumpTrigger");
                break;
            case AnimState.Slide:
                _animator.SetBool("isLanded", false);
                _animator.SetTrigger("SlideTrigger");
                break;
            case AnimState.Ragdoll:
                _animator.SetBool("isLanded", false);
                _animator.SetTrigger("RagdollTrigger");
                break;
        }
    }
}