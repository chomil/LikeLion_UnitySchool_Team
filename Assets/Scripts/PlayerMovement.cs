using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public GameObject playerCharacter;
    public Camera playerCamera;
    
    private CharacterController controller;
    private float speed = 2.5f;   
    private float jumpPower = 1.5f;
    private float gravity = -19.6f;
    private Vector3 velocity;
    private bool isGrounded;
    
    void Awake()
    {
        controller = GetComponent<CharacterController>();
    }

    void Update()
    {        
        // 바닥에 있는지 확인
        isGrounded = controller.isGrounded;

        if (isGrounded && velocity.y < 0)
        {
            velocity.y = 0f;
        }
        
        // 입력 받기
        float moveX = Input.GetAxis("Horizontal");
        float moveZ = Input.GetAxis("Vertical");
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");


        //마우스 이동에 따른 카메라 공전
        if (mouseX!=0)
        {
            playerCamera.transform.RotateAround(transform.position,Vector3.up, mouseX*90f*Time.deltaTime);
        }        
        if (mouseY!=0)
        {
            playerCamera.transform.RotateAround(transform.position,playerCamera.transform.right, -mouseY*60f*Time.deltaTime);
        }
        
        // 카메라의 방향에 따라 이동 방향 결정
        Vector3 forward = playerCamera.transform.forward;
        forward.y = 0;
        Vector3 right = playerCamera.transform.right;
        right.y = 0;
        forward.Normalize();
        right.Normalize();
        Vector3 move = (right * moveX + forward * moveZ).normalized;
        
        controller.Move(move * (speed * Time.deltaTime));
        
        // 회전 처리
        if (move != Vector3.zero)
        {
            // 각도 계산
            float angle = Vector3.SignedAngle(playerCharacter.transform.forward, move, Vector3.up);

            // 회전 적용
            Quaternion targetRotation = Quaternion.Euler(0, angle, 0);
            playerCharacter.transform.rotation = Quaternion.RotateTowards(playerCharacter.transform.rotation, playerCharacter.transform.rotation * targetRotation, 360f * Time.deltaTime);
        }
        
        
        // 점프
        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y += Mathf.Sqrt(jumpPower * -2f * gravity);
        }
        
        // 중력 적용
        velocity.y += gravity * Time.deltaTime;
        // 캐릭터 낙하
        controller.Move(velocity * Time.deltaTime);
        
    }
}
