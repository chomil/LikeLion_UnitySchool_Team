using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCostume : MonoBehaviour
{
    [SerializeField] private GameObject playerTop;
    [SerializeField] private GameObject playerBottom;
    private GameObject costumeTop = null;
    private GameObject costumeBottom = null;

    private SkinnedMeshRenderer targetSkin;
    [SerializeField] private Transform rootBone;
    private void Start()
    {
        GameData data = GameManager.Instance.gameData;
        if (gameObject.CompareTag("Player"))
        {
            ChangeCostume(data.GetItemByName(data.playerInfo.playerItems[ItemType.Upper], ItemType.Upper));
            ChangeCostume(data.GetItemByName(data.playerInfo.playerItems[ItemType.Lower], ItemType.Lower));
            TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Upper,data.playerInfo.playerItems[ItemType.Upper]);
            TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Lower,data.playerInfo.playerItems[ItemType.Lower]);
        }
    }

    public void ChangeCostume(ItemType itemType, string itemName)
    {
        ChangeCostume(GameManager.Instance.gameData.GetItemByName(itemName, itemType));
    }

    public void ChangeCostume(ItemData itemData)
    {
        if (itemData.itemType == ItemType.Upper)
        {
            GameObject newTop = itemData.itemObject;
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
        }
        else if (itemData.itemType == ItemType.Lower)
        {            
            GameObject newBottom = itemData.itemObject;
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
        }

        if (gameObject.CompareTag("Player"))
        {
            GameManager.Instance.gameData.playerInfo.playerItems[itemData.itemType] = itemData.itemName;
        }

        gameObject.GetComponent<Outline>()?.Refresh();
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
