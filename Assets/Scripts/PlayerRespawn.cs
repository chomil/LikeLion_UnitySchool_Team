using System.Collections;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using UnityEngine;

public class PlayerRespawn : MonoBehaviour
{
    public float minY = -10f; // Respawn the character if it falls below this Y coordinate
    public Vector3 defaultRespawnPosition; // Default respawn position
    public float groundCheckDistance = 2f; // Distance to check for ground
    public float respawnHeight = 2f; // Height above the ground to respawn
    public LayerMask groundLayer; // Layer(s) considered as ground

    private Vector3 lastCheckpointPosition;
    private bool isRespawning = false;
    
    
    [SerializedDictionary("Name","Audio List")]
    public SerializedDictionary<string, List<AudioClip>> respawnSounds;

    void Start()
    {
        // Set the current position as the default respawn position at start
        defaultRespawnPosition = transform.position;
        lastCheckpointPosition = transform.position;
        
        if (groundLayer.value == 0)
        {
            groundLayer = LayerMask.GetMask("Ground");
        }
    }

    void Update()
    {
        if (!isRespawning)
        {
            // Check if the character has fallen out of the map
            if (transform.position.y < minY)
            {
                StartCoroutine(RespawnCoroutine());
            }
        }
    }
    
    IEnumerator RespawnCoroutine()
    {
        isRespawning = true;

        // Find a safe respawn position
        Vector3 respawnPosition = FindSafeRespawnPosition();

        // Move the character to the respawn position
        transform.position = respawnPosition;

        SoundManager.Instance.PlaySfx(respawnSounds["Respawn"], 0.5f);
        
        // Wait briefly to allow the physics engine to stabilize
        yield return new WaitForSeconds(0.1f);
        isRespawning = false;
    }

    Vector3 FindSafeRespawnPosition()
    {
        RaycastHit hit;
        Vector3 startPos = lastCheckpointPosition + Vector3.up * 10f;
        float distance = 500f;
        

        if (Physics.Raycast(startPos, Vector3.down, out hit, distance, groundLayer))
        {
            return hit.point + Vector3.up * respawnHeight;
        }
        
        return defaultRespawnPosition;
    }

    // Call this method when the player reaches a new checkpoint
    public void UpdateCheckpoint(Vector3 newCheckpointPosition)
    {
        if (lastCheckpointPosition == newCheckpointPosition)
        {
            return;
        }
        
        lastCheckpointPosition = newCheckpointPosition;
        Debug.Log("Checkpoint updated to: " + lastCheckpointPosition);

        SoundManager.Instance.PlaySfx(respawnSounds["Checkpoint"], 0.2f);
    }
}
