using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BounceObstacle : MonoBehaviour
{    
    public enum ObstacleType
    {
        Trampoline,
        Hammer,
        Punch
    }

    public ObstacleType obstacleType;
    public float bouncePower = 10f;
    private void OnCollisionEnter(Collision other)
    {                  
        Rigidbody otherRigid = other.gameObject.GetComponent<Rigidbody>();
        if (otherRigid)
        {
            switch (obstacleType)
            {
                case ObstacleType.Trampoline:
                    otherRigid.velocity = new Vector3(otherRigid.velocity.x,0,otherRigid.velocity.z);
                    otherRigid.AddForce(gameObject.transform.up * bouncePower, ForceMode.Impulse);
                    if (other.gameObject.CompareTag("Player"))
                    {
                        other.gameObject.GetComponent<PlayerMovement>().Jump(0);
                    }
                    break;
                
                case ObstacleType.Hammer:
                    break;
                
                case ObstacleType.Punch:
                    break;
            }
        }
    }
}
