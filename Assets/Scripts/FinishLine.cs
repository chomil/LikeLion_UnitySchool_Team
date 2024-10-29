using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FinishLine : MonoBehaviour
{ 
    private void OnTriggerEnter(Collider other)
    {
        PlayerTCP player = other.GetComponent<PlayerTCP>();
        if (player != null && !player.HasFinished())
        {
            GameManager.Instance.PlayerFinished(player.PlayerId);
            Debug.Log($"Player {player.PlayerId} crossed the finish line!");

            // 로컬 플레이어인 경우 관전 모드로 전환
            if (player.PlayerId == TCPManager.playerId)
            {
                StartCoroutine(EnterSpectatorModeAfterDelay(player.PlayerId));
            }
        }
    }

    private IEnumerator EnterSpectatorModeAfterDelay(string playerId)
    {
        yield return new WaitForSeconds(2f);
        SpectatorManager.Instance.EnterSpectatorMode(playerId);
    }
}
