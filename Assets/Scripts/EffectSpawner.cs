using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectSpawner : MonoBehaviour
{
    public GameObject effectPrefab;
    private GameObject spawnedEffect;

    public void SpawnUIEffect(float deleteTime)
    {
        spawnedEffect = Instantiate(effectPrefab);
        StartCoroutine(DestroyCoroutine(deleteTime));
    }

    private IEnumerator DestroyCoroutine(float deleteTime)
    {
        yield return new WaitForSeconds(deleteTime);
        Destroy(spawnedEffect);
    }
}
