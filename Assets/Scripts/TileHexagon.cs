using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class TileHexagon : MonoBehaviour
{
    public float delayTime = 1f;
    private bool isCollision = false;


    private void OnCollisionEnter(Collision other)
    {
        if (isCollision == false)
        {
            if (other.gameObject.CompareTag("Player") || other.gameObject.CompareTag("OtherPlayer"))
            {
                isCollision = true;
                gameObject.transform.DOLocalMoveY(-0.1f, 0.1f).SetRelative();
                Material mat = gameObject.GetComponentInChildren<MeshRenderer>().material;
                mat.DOColor(mat.color+Color.white*0.3f, 0.1f);
                StartCoroutine(DestroyDelay());
            } 
        }
    }

    IEnumerator DestroyDelay()
    {
        yield return new WaitForSeconds(delayTime);
        Destroy(gameObject);
    }
}
