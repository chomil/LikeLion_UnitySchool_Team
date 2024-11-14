using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FinishLine : MonoBehaviour
{ 
    //삭제예정
    //이미 플레이어TCP에서 충돌처리 중
    private void OnTriggerEnter(Collider other)
    {
        // PlayerTCP player = other.GetComponent<PlayerTCP>();
        // if (player != null && !player.HasFinished())
        // {
        //     Debug.Log($"[FinishLine] Player entered finish line: {player.PlayerId}");
        //     
        //     GameManager.Instance.PlayerFinished(player.PlayerId, true);
        //     Debug.Log($"[FinishLine] Player {player.PlayerId} crossed the finish line!");
        //
        //     // 로컬 플레이어인 경우 관전 모드로 전환
        //     if (player.PlayerId == TCPManager.playerId)
        //     {
        //         Debug.Log($"[FinishLine] Starting spectator mode transition for local player");
        //         // StartCoroutine(EnterSpectatorModeAfterDelay(player.PlayerId));
        //     }
        // }
    }

    // private IEnumerator EnterSpectatorModeAfterDelay(string playerId)
    // {
    //     Debug.Log("[FinishLine] Waiting before spectator mode...");
    //     yield return new WaitForSeconds(2f);
    //     Debug.Log("[FinishLine] Attempting to enter spectator mode...");
    //     
    //     if (SpectatorManager.Instance != null)
    //     {
    //         SpectatorManager.Instance.EnterSpectatorMode(playerId);
    //         Debug.Log("[FinishLine] SpectatorManager.EnterSpectatorMode called");
    //     }
    //     else
    //     {
    //         Debug.LogError("[FinishLine] SpectatorManager.Instance is null!");
    //     }
    // }
}
