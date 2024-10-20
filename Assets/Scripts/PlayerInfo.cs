using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct PlayerInfo
{
    public string playerName;
    public Dictionary<ItemType, string> playerItems;
}
