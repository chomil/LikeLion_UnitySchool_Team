using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            PlayerRespawn respawnScript = other.GetComponent<PlayerRespawn>();
            if (respawnScript != null)
            {
                respawnScript.UpdateCheckpoint(transform.position);
            }
        }
    }
}
