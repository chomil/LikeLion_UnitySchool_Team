using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using Random = UnityEngine.Random;

public class Cannon : MonoBehaviour
{
    public List<GameObject> bulletObject;
    public float bulletStartForward = 0f;
    public float bulletScale = 1f;
    public float bulletMass = 100f;
    public float bulletDestroyTime = 10f;
    public float cannonPower = 1f;
    public float repeatTime = 3f;
    public float randomDelay = 0f;
    
    private void Start()
    {
        if (bulletObject.Count == 0)
        {
            return;
        }
        StartCoroutine(FireCannon());
    }

    private IEnumerator FireCannon()
    {
        int cannonSeed = transform.position.GetHashCode();
        if (SceneChanger.Instance)
        {
            cannonSeed += SceneChanger.Instance.matchingSeed;
        }
        System.Random cannonRandom = new System.Random(cannonSeed);
        
        while (true)
        {
            float delayTime = repeatTime + (float)cannonRandom.NextDouble() * randomDelay;
            yield return new WaitForSeconds(delayTime);
            GameObject spawnedObject = Instantiate(bulletObject[Random.Range(0, bulletObject.Count)],transform.position+transform.forward * bulletStartForward, quaternion.identity);
            spawnedObject.transform.localScale = new Vector3(bulletScale, bulletScale, bulletScale);
            Rigidbody rigid = spawnedObject.GetComponent<Rigidbody>();
            if (rigid)
            {
                rigid.mass = bulletMass;
                rigid.AddForce(transform.forward * cannonPower, ForceMode.Impulse);
            }
            StartCoroutine(DestroyBullet(spawnedObject));
        }
    }

    private IEnumerator DestroyBullet(GameObject spawnedObject)
    {
        yield return new WaitForSeconds(bulletDestroyTime);
        Destroy(spawnedObject);
    }
}
