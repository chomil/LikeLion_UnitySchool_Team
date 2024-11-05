using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStart : MonoBehaviour
{
    //1부터 시작, 맵에 직접 배치
    public int index;
    private GameObject player;

    public void InitPlayerPosToThis(GameObject _player)
    {
        if (player || !_player.CompareTag("Player"))
        {
            return;
        }

        player = _player;

        player.transform.position = transform.position;
        player.GetComponent<PlayerRespawn>().InitRespawnPos(transform.position);
    }
}
