using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BounceObstacle : MonoBehaviour
{    
    public enum ObstacleType
    {
        Trampoline,
        Movable
    }

    public ObstacleType obstacleType;
    public float bouncePower = 10f;

    private Vector3 prevPos;
    private Vector3 deltaPos;
    
    private void OnCollisionEnter(Collision other)
    {                  
        Rigidbody otherRigid = other.gameObject.GetComponent<Rigidbody>();
        if (otherRigid)
        {
            switch (obstacleType)
            {
                case ObstacleType.Trampoline:
                    otherRigid.velocity = new Vector3(otherRigid.velocity.x,0,otherRigid.velocity.z);
                    if (other.gameObject.CompareTag("Player"))
                    {
                        other.gameObject.GetComponent<PlayerMovement>().Jump(0);
                    }
                    otherRigid.AddForce(gameObject.transform.up * bouncePower, ForceMode.Impulse);
                    break;
                
                case ObstacleType.Movable:
                    Vector3 dir = (other.transform.position - transform.position).normalized;
                    Vector3 punchVec = deltaPos * Vector3.Dot(deltaPos.normalized, dir);
                    if (other.gameObject.CompareTag("Player"))
                    {
                        other.gameObject.GetComponent<PlayerMovement>().Punched(punchVec,bouncePower);
                    }
                    break;
            }
        }
    }

    private void LateUpdate()
    {
        deltaPos = transform.position - prevPos;
        prevPos = transform.position;
    }
}
