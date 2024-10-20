using UnityEngine;

public enum ItemType
{
    Color,Pattern,Face,Upper,Lower,None
}

[System.Serializable]
public struct ItemData 
{
    public string itemName;
    public ItemType itemType;
    public GameObject itemObject;
    public Sprite itemIcon;
}
