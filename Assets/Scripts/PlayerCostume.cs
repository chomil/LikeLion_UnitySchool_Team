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

    private Material mat;
    
    private void Start()
    {
        if (mat == null)
        {
            InitMat();
        }
        GameData data = GameManager.Instance.gameData;
        if (gameObject.CompareTag("Player"))
        {
            ChangeCostume(data.GetItemByName(data.playerInfo.playerItems[ItemType.Upper], ItemType.Upper));
            ChangeCostume(data.GetItemByName(data.playerInfo.playerItems[ItemType.Lower], ItemType.Lower));
            ChangeCostume(data.GetItemByName(data.playerInfo.playerItems[ItemType.Pattern], ItemType.Pattern));
            ChangeCostume(data.GetItemByName(data.playerInfo.playerItems[ItemType.Color], ItemType.Color));
            ChangeCostume(data.GetItemByName(data.playerInfo.playerItems[ItemType.Face], ItemType.Face));
            SendPlayerAllCostumes();
        }
        else
        {
            SendPlayerAllCostumes(gameObject.GetComponent<OtherPlayerTCP>()?.PlayerId);
        }
    }

    private void InitMat()
    {
        mat = GetComponentInChildren<SkinnedMeshRenderer>().material;
        SkinnedMeshRenderer[] meshRenderers= GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (SkinnedMeshRenderer meshRenderer in meshRenderers)
        {
            meshRenderer.material = mat;
        }
    }

    public void SendPlayerAllCostumes(string otherName="")
    {
        GameData data = GameManager.Instance.gameData;
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Upper,data.playerInfo.playerItems[ItemType.Upper],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Lower,data.playerInfo.playerItems[ItemType.Lower],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Pattern,data.playerInfo.playerItems[ItemType.Pattern],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Color,data.playerInfo.playerItems[ItemType.Color],otherName);
        TcpProtobufClient.Instance?.SendPlayerCostume(TCPManager.playerId, (int)ItemType.Face,data.playerInfo.playerItems[ItemType.Face],otherName);
    }

    public void ChangeCostume(ItemType itemType, string itemName)
    {
        ChangeCostume(GameManager.Instance.gameData.GetItemByName(itemName, itemType));
    }

    public void ChangeCostume(ItemData itemData)
    {
        if (mat == null)
        {
            InitMat();
        }
        
        if (itemData.itemType == ItemType.Upper)
        {
            GameObject newTop = itemData.itemObject as GameObject;
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
            GameObject newBottom = itemData.itemObject as GameObject;
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
        else if (itemData.itemType == ItemType.Pattern)
        {
            Texture2D newTex = itemData.itemObject as Texture2D;
            if (newTex)
            {
                mat.SetTexture("_Pattern", newTex);
            }
        }
        else if (itemData.itemType == ItemType.Color)
        {
            ColorPreset newColorPreset = itemData.itemObject as ColorPreset;
            if (newColorPreset)
            {
                mat.SetColor("_BodyColor1", newColorPreset.color1);
                mat.SetColor("_BodyColor2", newColorPreset.color2);
            }
        }
        else if (itemData.itemType == ItemType.Face)
        {
            ColorPreset newColorPreset = itemData.itemObject as ColorPreset;
            if (newColorPreset)
            {
                mat.SetColor("_EyeColor", newColorPreset.color1);
                mat.SetColor("_FaceColor", newColorPreset.color2);
            }
        }

        if (gameObject.CompareTag("Player"))
        {
            GameManager.Instance.gameData.playerInfo.playerItems[itemData.itemType] = itemData.itemName;
        }

        if (itemData.itemType == ItemType.Upper || itemData.itemType == ItemType.Lower)
        {
            gameObject.GetComponent<Outline>()?.Refresh();
        }
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
