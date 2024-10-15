using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCostume : MonoBehaviour
{
    [SerializeField] private GameObject playerTop;
    [SerializeField] private GameObject playerBottom;
    [SerializeField] private GameObject costumeTop;
    [SerializeField] private GameObject costumeBottom;

    private SkinnedMeshRenderer targetSkin;
    [SerializeField] private Transform rootBone;
    private void Awake()
    {
        if (costumeTop)
        {
            GameObject top = Instantiate(costumeTop, playerTop.transform);
            targetSkin = top.GetComponentInChildren<SkinnedMeshRenderer>();
            TransferBones();
        }
        if (costumeBottom)
        {
            GameObject bottom = Instantiate(costumeBottom, playerTop.transform);
            targetSkin = bottom.GetComponentInChildren<SkinnedMeshRenderer>();
            TransferBones();
        }
    }

    public void ChangeCostume()
    {
        
    }
    
    public void TransferBones()
    {
        if (targetSkin == null)
        {
            return;
        }
        
        Dictionary<string, Transform> boneDictionary = new Dictionary<string, Transform>();
        Transform[] rootBoneChildren = rootBone.GetComponentsInChildren<Transform>();
        foreach (Transform child in rootBoneChildren)
        {
            boneDictionary[child.name] = child;
        }


        Transform[] newBones = new Transform[targetSkin.bones.Length];
        for (int i = 0; i < targetSkin.bones.Length; i++)
        {
            if (boneDictionary.TryGetValue(targetSkin.bones[i].name, out Transform newBone))
            {
                newBones[i] = newBone;
            }
        }
        targetSkin.bones = newBones;
    }
}
