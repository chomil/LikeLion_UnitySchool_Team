using System;
using System.Collections;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using Unity.VisualScripting;
using UnityEngine;

public enum AnimState{ //서버에 애니메이션 정보를 전송하기 위한 enum
    Idle,
    Move,
    Jump,
    Slide,
    Ragdoll
}

public class PlayerMovement : MonoBehaviour
{
    public GameObject playerCharacter;
    
    public GameObject cameraArm;

    public StepTrigger stepCollider;

    public AnimState curAnimState; //현재 나의 애니메이션 상태
    public AnimState nextAnimState; //다음 나의 애니메이션 상태

    private Rigidbody rigid;
    private Animator anim;
    
    private Vector3 moveVector;
    
    private float speed = 3.5f;
    private float jumpPower = 6f;
    private float slidePower = 5f;
    private bool isGrounded = false;
    private bool isJumping = false;
    private bool isSliding = false;
    private bool isRagdoll = false;

    private float camPitchAngle = 0f;
    private float camYawAngle = 0f;
    private string lastSentAnimationState; 
    
    private bool isFinished = false;

    public bool canControl = true;

    [SerializedDictionary("Name","Audio List")]
    public SerializedDictionary<string, List<AudioClip>> moveSounds;
    
    void Awake()
    {
        rigid = GetComponent<Rigidbody>();
        anim = GetComponent<Animator>();
    }

    void Start()
    {
        if (canControl == false)
        {
            rigid.isKinematic = true;
            return;
        }
        Cursor.lockState = CursorLockMode.Locked;
        Physics.gravity = new Vector3(0f,-12f,0f);
        stepCollider.OnStepEvent += OnStep; // 이벤트 바인딩
        curAnimState = AnimState.Idle; //초기화
    }

    void Update()
    {
        if (isFinished || canControl == false)
        {
            return;
        }
        
        if (curAnimState != AnimState.Ragdoll)
        {        
            // 점프 입력 처리
            if (Input.GetButtonDown("Jump") && isGrounded==true && isJumping==false)
            {
                Jump(jumpPower);
                SoundManager.Instance.PlaySfx(moveSounds["Jump"], 0.5f);
            }
        
            // 슬라이드
            if (Input.GetButtonDown("Slide") && isSliding==false)
            {
                rigid.velocity = Vector3.zero;
                Vector3 slideVec = playerCharacter.transform.forward + Vector3.up;
                slideVec.Normalize();
                rigid.AddForce(slideVec * slidePower, ForceMode.Impulse);
                isGrounded = false;
                isSliding = true;
                nextAnimState = AnimState.Slide;
                SoundManager.Instance.PlaySfx(moveSounds["Slide"], 0.5f);
            }
        }
        

        
        // 입력 받기
        float moveX = Input.GetAxis("Horizontal");
        float moveZ = Input.GetAxis("Vertical");
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");


        //마우스 이동에 따른 카메라 공전
        camYawAngle += mouseX;
        camPitchAngle -= mouseY;
        camPitchAngle = Mathf.Clamp(camPitchAngle, 0f, 80f);
        cameraArm.transform.rotation = Quaternion.Euler(camPitchAngle, camYawAngle, 0);

        // 카메라의 방향에 따라 이동 방향 결정
        Vector3 forward = cameraArm.transform.forward;
        forward.y = 0;
        Vector3 right = cameraArm.transform.right;
        right.y = 0;
        forward.Normalize();
        right.Normalize();
        moveVector = right * moveX + forward * moveZ;
        if (moveVector.magnitude > 1)
        {
            moveVector.Normalize();
        }

        if (isGrounded && isRagdoll==false) //지면 이동
        {
            //이동
            rigid.velocity = new Vector3(moveVector.x * speed, rigid.velocity.y, moveVector.z * speed);
            if (moveVector != Vector3.zero)
            {            
                //땅에선 입력 이동방향에 따른 플레이어 회전 처리
                float angle = Vector3.SignedAngle(playerCharacter.transform.forward, moveVector.normalized, Vector3.up);
                Quaternion targetRotation = Quaternion.Euler(0, angle, 0);                
                playerCharacter.transform.rotation = Quaternion.RotateTowards(playerCharacter.transform.rotation,
                    playerCharacter.transform.rotation * targetRotation, 360f * Time.deltaTime);
                
                nextAnimState = AnimState.Move;
            }
            else
            {
                nextAnimState = AnimState.Idle;
            }

        }
        else //공중
        {
            Vector3 speedVec = rigid.velocity;
            speedVec.y = 0;
            
            //에어 컨트롤 적용
            rigid.AddForce(moveVector, ForceMode.Force);
            
            //공중에서 벨로시티에 따른 플레이어 회전 처리
            float angle = Vector3.SignedAngle(playerCharacter.transform.forward, speedVec.normalized, Vector3.up);
            Quaternion targetRotation = Quaternion.Euler(0, angle, 0);                
            playerCharacter.transform.rotation = Quaternion.RotateTowards(playerCharacter.transform.rotation,
                playerCharacter.transform.rotation * targetRotation, 360f * Time.deltaTime);
        }
    }

    public void LateUpdate()
    {        
        if (isFinished || canControl == false)
        {
            return;
        }
        
        StateChange();

        if (rigid.velocity.magnitude > 20f)
        {
            rigid.velocity = rigid.velocity.normalized * 20f;
        }
    }


    public void StateChange()
    {
        if (curAnimState != nextAnimState) //트리거 처리
        {
            curAnimState = nextAnimState;
            switch (curAnimState)
            {
                case AnimState.Jump:
                    anim.SetTrigger("JumpTrigger");
                    anim.SetBool("isLanded", false);
                    break;
                case AnimState.Slide:
                    anim.SetTrigger("SlideTrigger");
                    anim.SetBool("isLanded", false);
                    break;
                case AnimState.Ragdoll:
                    anim.SetTrigger("RagdollTrigger");
                    anim.SetBool("isLanded", false);
                    break;
            }
            
            TcpProtobufClient.Instance?.SendPlayerAnimation(curAnimState.ToString(), TCPManager.playerId,0,0);
        }

        
        if (curAnimState == AnimState.Idle || curAnimState == AnimState.Move)
        {
            anim.SetBool("isLanded", true);
            // 방향에 따른 이동애니메이션 블렌드
            float speedForward = Vector3.Dot(moveVector, playerCharacter.transform.forward);
            float speedRight = Vector3.Dot(moveVector, playerCharacter.transform.right);
            anim.SetFloat("SpeedForward",speedForward);
            anim.SetFloat("SpeedRight",speedRight);
            TcpProtobufClient.Instance?.SendPlayerAnimation(curAnimState.ToString(), TCPManager.playerId,speedForward,speedRight);
        }
    }
    
    public void Punched(Vector3 dir,float power)
    {
        rigid.AddForce(Vector3.up, ForceMode.Impulse);
        rigid.AddForce(dir*power, ForceMode.Impulse);
        StartCoroutine(Ragdoll());
    }

    public void PlayFootstep()
    {
        SoundManager.Instance.PlaySfx(moveSounds["Run"], 0.5f);
    }

    private IEnumerator Ragdoll()
    {
        nextAnimState = AnimState.Ragdoll;
        isRagdoll = true;
        
        yield return new WaitWhile(()=>rigid.velocity.magnitude<=0.1f);
        isRagdoll = false;
    }

    public void Jump(float power)
    {
        rigid.velocity = new Vector3(moveVector.x * speed, 0, moveVector.z * speed);
        rigid.AddForce(Vector3.up * power, ForceMode.Impulse);
        isGrounded = false;
        isJumping = true;
        nextAnimState = AnimState.Jump;
    }
    
    private void OnStep(Collider other)
    {        
        //바닥 체크
        if (isGrounded == false && rigid.velocity.y <= 0)
        {
            isGrounded = true;
            isSliding = false;
            isJumping = false;
            
            SoundManager.Instance.PlaySfx(moveSounds["Land"], 0.5f);
        }
    }
    
    
    public void SetIdleState()
    {
        // 모든 움직임 멈추기
        rigid.velocity = Vector3.zero;
        moveVector = Vector3.zero;

        // 애니메이션 상태를 Idle로 변경
        nextAnimState = AnimState.Idle;
        curAnimState = AnimState.Idle;
    
        // Animator 파라미터 업데이트
        anim.SetFloat("SpeedForward", 0);
        anim.SetFloat("SpeedRight", 0);
        anim.SetBool("isLanded", true);
        
        // 서버에 Idle 상태 전송
        TcpProtobufClient.Instance.SendPlayerAnimation(curAnimState.ToString(), TCPManager.playerId, 0, 0);

        // 모든 입력 비활성화를 위한 플래그 설정
        isFinished = true;
        
        //다음 경기 로드
        SceneChanger.Instance.SelectRace(); 
    }
}