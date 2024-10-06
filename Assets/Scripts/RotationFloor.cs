using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotationFloor : MonoBehaviour
{
    public enum RotationAxis
    {
        X,
        Y,
        Z
    }

    public RotationAxis rotationAxis = RotationAxis.Y;
    public float rotationSpeed = 50.0f;
    
    private List<Collision> others = new List<Collision>();
    private Quaternion prevRotation;

    private void FixedUpdate()
    {
        prevRotation = transform.rotation;
        
        float rotationValue = rotationSpeed * Time.deltaTime;
        Vector3 axis = Vector3.zero;
        switch (rotationAxis)
        {
            case RotationAxis.X:
                axis = Vector3.right;
                break;
            case RotationAxis.Y:
                axis = Vector3.up;
                break;
            case RotationAxis.Z:
                axis = Vector3.forward;
                break;
        }
        transform.Rotate(axis, rotationValue);
        
        foreach (Collision other in others)
        {
            Rigidbody otherRigid = other.gameObject.GetComponent<Rigidbody>();
            if (otherRigid)
            {
                // 현재 발판의 회전과 이전 회전 간의 차이를 구함
                Quaternion deltaRotation = transform.rotation * Quaternion.Inverse(prevRotation);

                // 플레이어의 위치가 회전에 의해 이동하도록 설정
                Vector3 playerPositionRelativeToPlatform = otherRigid.position - transform.position;
                Vector3 rotatedPosition = deltaRotation * playerPositionRelativeToPlatform;

                // 플레이어 위치 업데이트
                otherRigid.MovePosition(transform.position + rotatedPosition);
            }
        }
    }
    
    
    
    private void OnCollisionEnter(Collision other)
    {      
        others.Add(other);
    }
    
    private void OnCollisionExit(Collision other)
    {            
        others.Remove(other);
    }
}
