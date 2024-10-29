using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpectatorCamera : MonoBehaviour
{
    private Camera spectatorCamera;
    public Vector3 cameraOffset = new Vector3(0, 2, -5); // 카메라 위치 오프셋
    public float smoothSpeed = 5f;
    
    private void Start()
    {
        spectatorCamera = GetComponentInChildren<Camera>();
        if(spectatorCamera != null)
        {
            spectatorCamera.enabled = false; // 시작 시 비활성화
        }
    }

    public void SetCamera()
    {
        if(spectatorCamera != null)
        {
            spectatorCamera.enabled = true;
            StartCoroutine(SmoothFollow());
        }
    }

    public void ClearCamera()
    {
        if(spectatorCamera != null)
        {
            spectatorCamera.enabled = false;
            StopAllCoroutines();
        }
    }

    private IEnumerator SmoothFollow()
    {
        while(true)
        {
            // 타겟(플레이어) 뒤쪽에서 살짝 위에 위치하도록
            Vector3 desiredPosition = transform.position + transform.TransformDirection(cameraOffset);
            Vector3 smoothedPosition = Vector3.Lerp(spectatorCamera.transform.position, desiredPosition, smoothSpeed * Time.deltaTime);
            
            spectatorCamera.transform.position = smoothedPosition;
            spectatorCamera.transform.LookAt(transform.position);
            
            yield return null;
        }
    }
}
