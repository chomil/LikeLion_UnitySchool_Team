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

    void Start()
    {
        _animator = GetComponent<Animator>();
        _rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        transform.rotation = Quaternion.Euler(OtherRot);
        transform.position = destination;
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