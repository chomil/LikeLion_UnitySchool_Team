using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public GameObject playerCharacter;
    
    public GameObject cameraArm;

    private Rigidbody rigid;
    private Animator anim;
    private float speed = 3f;
    private float jumpPower = 6f;
    private float slidePower = 6f;
    private bool isGrounded = false;
    private bool isJumping = false;
    private bool isSliding = false;

    private float camPitchAngle = 0f;
    private float camYawAngle = 0f;
    
    void Awake()
    {
        rigid = GetComponent<Rigidbody>();
        anim = GetComponent<Animator>();
    }

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Physics.gravity = new Vector3(0f,-12f,0f);
    }

    void Update()
    {        
        // 땅에 닿아 있는지 확인
        bool isGroundedTemp = Physics.Raycast(transform.position+new Vector3(0,0.2f,0), Vector3.down, 0.3f);

        if (isGroundedTemp == true && rigid.velocity.y<=0)
        {
            isGrounded = true;
            isSliding = false;
            isJumping = false;
        }
        else
        {
            isGrounded = false;
        }
        
        // 점프 입력 처리
        if (Input.GetButtonDown("Jump") && isGrounded==true && isJumping==false)
        {
            rigid.AddForce(Vector3.up * jumpPower, ForceMode.Impulse);
            isGrounded = false;
            isJumping = true;
            anim.SetTrigger("JumpTrigger");
        }
        
        // 슬라이드
        if (Input.GetButtonDown("Slide") && isGrounded==false && isSliding==false)
        {
            rigid.velocity = Vector3.zero;
            Vector3 slideVec = playerCharacter.transform.forward * 3f + Vector3.up;
            slideVec.Normalize();
            rigid.AddForce(slideVec * slidePower, ForceMode.Impulse);
            isSliding = true;
            anim.SetTrigger("SlideTrigger");
        }
        
        anim.SetBool("isLanded", isGrounded);
        
        
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
        Vector3 move = right * moveX + forward * moveZ;
        Vector3 moveDirection = move.normalized;

        if (isGrounded)
        {
            //이동
            rigid.velocity = new Vector3(moveDirection.x * speed, rigid.velocity.y, moveDirection.z * speed);
            if (move != Vector3.zero)
            {            
                // 이동방향에 따른 플레이어 회전 처리
                float angle = Vector3.SignedAngle(playerCharacter.transform.forward, moveDirection, Vector3.up);
                Quaternion targetRotation = Quaternion.Euler(0, angle, 0);                
                playerCharacter.transform.rotation = Quaternion.RotateTowards(playerCharacter.transform.rotation,
                    playerCharacter.transform.rotation * targetRotation, 360f * Time.deltaTime);

                // 방향에 따른 이동애니메이션 블렌드
                float speedForward = Vector3.Dot(move, playerCharacter.transform.forward);
                float speedRight = Vector3.Dot(move, playerCharacter.transform.right);
                anim.SetFloat("SpeedForward",speedForward);
                anim.SetFloat("SpeedRight",speedRight);
            }
            else
            {
                anim.SetFloat("SpeedForward",0);
                anim.SetFloat("SpeedRight",0);
            }
        }
    }
}