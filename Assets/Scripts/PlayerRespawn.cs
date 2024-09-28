using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerRespawn : MonoBehaviour
{
    public float minY = -10f; // Respawn the character if it falls below this Y coordinate
    public Vector3 defaultRespawnPosition; // Default respawn position
    public float groundCheckDistance = 2f; // Distance to check for ground
    public float respawnHeight = 2f; // Height above the ground to respawn
    public LayerMask groundLayer; // Layer(s) considered as ground

    private Vector3 lastSafePosition;
    private bool isRespawning = false;

    void Start()
    {
        // Set the current position as the default respawn position at start
        defaultRespawnPosition = transform.position;
        lastSafePosition = transform.position;
    }

    void Update()
    {
        if (!isRespawning)
        {
            // Check if the current position is safe
            if (IsPositionSafe(transform.position))
            {
                lastSafePosition = transform.position;
            }

            // Check if the character has fallen out of the map
            if (transform.position.y < minY)
            {
                StartCoroutine(RespawnCoroutine());
            }
        }
    }

    bool IsPositionSafe(Vector3 position)
    {
        // Use a raycast to check if there's ground below
        return Physics.Raycast(position, Vector3.down, groundCheckDistance, groundLayer);
    }

    IEnumerator RespawnCoroutine()
    {
        isRespawning = true;

        // Find a safe respawn position
        Vector3 respawnPosition = FindSafeRespawnPosition();

        // Move the character to the respawn position
        transform.position = respawnPosition;

        // Wait briefly to allow the physics engine to stabilize
        yield return new WaitForSeconds(0.1f);

        isRespawning = false;
    }

    Vector3 FindSafeRespawnPosition()
    {
        RaycastHit hit;

        // Try to find safe ground from the last safe position
        if (Physics.Raycast(lastSafePosition, Vector3.down, out hit, 100f, groundLayer))
        {
            return hit.point + Vector3.up * respawnHeight;
        }
        
        // If not found, try to find safe ground from the default respawn position
        if (Physics.Raycast(defaultRespawnPosition, Vector3.down, out hit, 100f, groundLayer))
        {
            return hit.point + Vector3.up * respawnHeight;
        }

        // If no safe position is found, use the default respawn position
        return defaultRespawnPosition;
    }
}
