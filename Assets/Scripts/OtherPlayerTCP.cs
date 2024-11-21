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
            //예측값-실제값 간 보간으로 수정 권장
            //transform.rotation = Quaternion.Euler(OtherRot);
            //transform.position = destination;
            
            Quaternion targetRotation = Quaternion.Euler(OtherRot);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, Time.deltaTime * 5.0f);

            transform.position = Vector3.Lerp(transform.position, destination, Time.deltaTime * 5.0f);
            if (Vector3.Distance(transform.position,destination) > 1)
            {
                transform.position = destination;
            }
        }
    }
    
    public void FinishRace()
    {
        if (!hasFinished)
        {
            hasFinished = true;

            SkinnedMeshRenderer[] renders = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
            Collider[] colliders = gameObject.GetComponentsInChildren<Collider>();

            foreach (var render in renders)
            {
                render.enabled = false;
            }
            foreach (var collider in colliders)
            {
                collider.enabled = false;
            }
            
            // 완주 시 마지막 위치 정확히 적용
            transform.position = destination;
            transform.rotation = Quaternion.Euler(OtherRot);
            
            // SpectatorManager에 완주 알림
            SpectatorManager.Instance?.OnPlayerFinished(PlayerId);
            Debug.Log($"Other player {PlayerId} finished race");
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
            case AnimState.GrabOn:
                _animator.SetBool("IsGrabbing", true) ;
                break;
            case AnimState.GrabOff:
                _animator.SetBool("IsGrabbing", false) ;
                break;
        }
    }
}