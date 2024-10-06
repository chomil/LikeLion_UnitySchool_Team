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
    public StepTrigger stepCollider;

    private Animator _animator;
    private Rigidbody _rb;
    private bool isGrounded;
    private bool isSliding;
    private bool isAnimEnded;

    // Start is called before the first frame update
    void Start()
    {
        _animator = GetComponent<Animator>();
        _rb = GetComponent<Rigidbody>();
        stepCollider.OnStepEvent += OnStep; // 이벤트 바인딩
        isGrounded = true;
        isAnimEnded = true;
    }

    // Update is called once per frame
    void Update()
    {
        transform.rotation = Quaternion.Euler(OtherRot);
        transform.position = destination;
        
        _animator.SetBool("isLanded", isGrounded); //착지할 때 애니메이션
        
    }

    public void AnimTrigger(PlayerAnimation pa)
    {
        if (!isAnimEnded) return;
        
        otherAnimState = (AnimState)Enum.Parse(typeof(AnimState), pa.PlayerAnimState);

        switch (otherAnimState)
        {
            case AnimState.Idle:
                _animator.SetFloat("SpeedForward", 0);
                _animator.SetFloat("SpeedRight", 0);
                break;
            case AnimState.Move:
                _animator.SetFloat("SpeedForward",pa.SpeedForward);
                _animator.SetFloat("SpeedRight",pa.SpeedRight);
                break;
            case AnimState.Jump:
                isGrounded = false;
                _animator.SetTrigger("JumpTrigger");
                break;
            case AnimState.Slide:
                isGrounded = false;
                _animator.SetTrigger("SlideTrigger");
                break;
        }
    }

    private void OnStep(Collider other)
    {
        //바닥 체크
        if (_rb.velocity.y <= 0)
        {
            isGrounded = true;
        }
    }
}