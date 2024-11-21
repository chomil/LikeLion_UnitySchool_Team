using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpectatorCamera : MonoBehaviour
{
    public static SpectatorCamera Instance { get; private set; }
    private Transform target;
    private Camera spectatorCamera;
    public Vector3 cameraOffset = new Vector3(0, 3, -6); // 조금 더 멀리서 관전
    public float smoothSpeed = 6f;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }
    
    private void Start()
    {
        spectatorCamera = GetComponent<Camera>();
    }

    public void SetTarget(Transform newTarget)
    {
        target = newTarget;
        if(target != null)
        {
            gameObject.SetActive(true);
            StartCoroutine(SmoothFollow());
        }
    }

    public void ClearTarget()
    {
        target = null;
        gameObject.SetActive(false);
        StopAllCoroutines();
    }

    private IEnumerator SmoothFollow()
    {
        while(target != null)
        {
            // 목표 위치 계산에 target의 velocity도 고려
            Vector3 targetVelocity = target.GetComponent<Rigidbody>()?.velocity ?? Vector3.zero;
            Vector3 predictedPosition = target.position + (targetVelocity * Time.deltaTime);
        
            // 더 부드러운 카메라 움직임을 위한 Spring 수식 적용
            Vector3 desiredPosition = predictedPosition + target.rotation * cameraOffset;
            Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed * Time.deltaTime);
            transform.position = smoothedPosition;

            // 더 부드러운 회전
            Quaternion currentRotation = transform.rotation;
            Vector3 lookAtPosition = target.position + Vector3.up * 1.5f;
            Quaternion targetRotation = Quaternion.LookRotation(lookAtPosition - transform.position);
            transform.rotation = Quaternion.Slerp(currentRotation, targetRotation, smoothSpeed * Time.deltaTime);
        
            yield return null;
        }
    }
}
