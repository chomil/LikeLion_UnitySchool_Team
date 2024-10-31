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
    
    public string PlayerId { get;  set; }

    void Start()
    {
        _animator = GetComponent<Animator>();
        _rb = GetComponent<Rigidbody>();
        _renderer = GetComponentInChildren<Renderer>();
    }

    void Update()
    {
        if (!hasFinished)
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(OtherRot), Time.deltaTime * 10f);
            transform.position = Vector3.Lerp(transform.position, destination, Time.deltaTime * 10f);
        }
    }
    
    public void FinishRace()
    {
        if (!hasFinished)
        {
            hasFinished = true;
        
            // 플레이어 움직임 멈춤
            _rb.isKinematic = true;
        
            // Idle 애니메이션으로 전환
            _animator.SetBool("isLanded", true);
            _animator.SetFloat("SpeedForward", 0);
            _animator.SetFloat("SpeedRight", 0);
        
            // Idle 트리거가 있다면 사용
            _animator.SetTrigger("IdleTrigger");
        
            Debug.Log($"Other player finished the race: {gameObject.name}");
        }
    }

    public bool HasFinished()
    {
        return hasFinished;
    }

    public void AnimTrigger(PlayerAnimation pa)
    {
        if (hasFinished) return; // 레이스 완료시 애니메이션 업데이트 안함
        if ( !_animator) return;
        
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