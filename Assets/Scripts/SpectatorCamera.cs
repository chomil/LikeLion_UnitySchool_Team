using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpectatorCamera : MonoBehaviour
{
    public static SpectatorCamera Instance { get; private set; }
    private Transform target;
    private Camera spectatorCamera;
    public Vector3 cameraOffset = new Vector3(0, 3, -6); // 조금 더 멀리서 관전
    public float smoothSpeed = 5f;
    
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
        gameObject.SetActive(false); // 시작 시 비활성화
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
            Vector3 desiredPosition = target.position + target.rotation * cameraOffset;
            transform.position = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed * Time.deltaTime);
            transform.LookAt(target.position + Vector3.up * 1.5f); // 약간 위를 바라보도록
            
            yield return null;
        }
    }
}
