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
    private void Start()
    {
        ChangeCostume();
    }

    public void ChangeCostume()
    {
        GameData data = GameManager.Instance.gameData;
        GameObject newTop = data.GetItemByName(data.playerInfo.playerItems[ItemType.Upper], ItemType.Upper).itemObject;
        GameObject newBottom = data.GetItemByName(data.playerInfo.playerItems[ItemType.Lower], ItemType.Lower).itemObject;
        if (costumeTop != newTop)
        {
            //기존 코스튬 삭제
            foreach (Transform child in playerTop.transform)
            {
                Destroy(child.gameObject);
            }
            //새 코스튬 장착
            if (newTop)
            {
                GameObject top = Instantiate(newTop, playerTop.transform);
                targetSkin = top.GetComponentInChildren<SkinnedMeshRenderer>();
                TransferBones();
            }
            costumeTop = newTop;
        }
        if (costumeBottom != newBottom)
        {            
            //기존 코스튬 삭제
            foreach (Transform child in playerBottom.transform)
            {
                Destroy(child.gameObject);
            }
            //새 코스튬 장착
            if (newBottom)
            {
                GameObject bottom = Instantiate(newBottom, playerBottom.transform);
                targetSkin = bottom.GetComponentInChildren<SkinnedMeshRenderer>();
                TransferBones();
            }
            costumeBottom = newBottom;
        }
        
        gameObject.GetComponent<Outline>().Refresh();
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
