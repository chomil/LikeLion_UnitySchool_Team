using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using UnityEngine;

[CreateAssetMenu(fileName = "GameDatabase", menuName = "Data/GameData")]
public class GameData : ScriptableObject
{
    [SerializedDictionary("ItemType", "ItemData List")]
    public SerializedDictionary<ItemType, List<ItemData>> allItemDatas =
        new SerializedDictionary<ItemType, List<ItemData>>();
    public PlayerInfo playerInfo;

    public ItemData GetItemByName(string itemName, ItemType itemType)
    {
        return allItemDatas[itemType].Find(item => item.itemName == itemName);
    }
}