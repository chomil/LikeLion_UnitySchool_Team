using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public GameObject playerCharacter;
    
    public Camera playerCamera;

    private Rigidbody rigid;
    private Animator anim;
    private float speed = 3f;
    private float jumpPower = 6f;
    private float slidePower = 6f;
    private bool isGrounded = false;
    private bool isJumping = false;
    private bool isSliding = false;
    
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
        isGrounded = Physics.Raycast(transform.position, Vector3.down, 0.3f);

        if (isGrounded)
        {
            isSliding = false;
            isJumping = false;
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
        if (mouseX != 0)
        {
            playerCamera.transform.RotateAround(transform.position, Vector3.up, mouseX * 180f * Time.deltaTime);
        }

        if (mouseY != 0)
        {
            playerCamera.transform.RotateAround(transform.position, playerCamera.transform.right,
                -mouseY * 60f * Time.deltaTime);
        }

        // 카메라의 방향에 따라 이동 방향 결정
        Vector3 forward = playerCamera.transform.forward;
        forward.y = 0;
        Vector3 right = playerCamera.transform.right;
        right.y = 0;
        forward.Normalize();
        right.Normalize();
        Vector3 move = (right * moveX + forward * moveZ).normalized;

        if (isGrounded)
        {
            rigid.velocity = new Vector3(move.x * speed, rigid.velocity.y, move.z * speed);
            isSliding = false;
            anim.SetFloat("SpeedForward",moveZ);
            anim.SetFloat("SpeedRight",moveX);
        }

        // 회전 처리
        if (move != Vector3.zero)
        {
            // 각도 계산
            float angle = Vector3.SignedAngle(playerCharacter.transform.forward, move, Vector3.up);

            // 회전 적용
            Quaternion targetRotation = Quaternion.Euler(0, angle, 0);
            playerCharacter.transform.rotation = Quaternion.RotateTowards(playerCharacter.transform.rotation,
                playerCharacter.transform.rotation * targetRotation, 360f * Time.deltaTime);
        }
    }
}