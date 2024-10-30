using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;

public class ItemButton : MonoBehaviour
{
    public GameObject highLightSprite;
    public GameObject noneSprite;
    public Image costumeIcon;
    public Image patternIcon;

    private bool isSelected = false;
    public ItemData itemData;

    void Start()
    {
        gameObject.GetComponent<Button>().onClick.AddListener(() => ClickItem());
    }

    public void SetItemData(ItemData data)
    {
        itemData = data;
        if (itemData.itemName == "없음")
        {
            noneSprite.SetActive(true);
            costumeIcon.enabled = false;
            patternIcon.enabled = false;
        }
        else
        {
            if (data.itemType == ItemType.Upper || data.itemType == ItemType.Lower)
            {
                costumeIcon.enabled = true;
                patternIcon.enabled = false;
                costumeIcon.sprite = itemData.itemIcon;
                costumeIcon.SetNativeSize();
            }
            else
            {
                costumeIcon.enabled = false;
                patternIcon.enabled = true;
                patternIcon.sprite = itemData.itemIcon;
                patternIcon.material = new Material(patternIcon.material);
                
                GameData gameData = GameManager.Instance.gameData;
                if (data.itemType == ItemType.Pattern)
                {
                    ColorPreset myColor = gameData.GetItemByName(gameData.playerInfo.playerItems[ItemType.Color], ItemType.Color).itemObject as ColorPreset;
                    if (myColor != null)
                    {
                        patternIcon.material.SetColor("_Color1", myColor.color1);
                        patternIcon.material.SetColor("_Color2", myColor.color2);
                    }
                }
                else
                {
                    if (data.itemType == ItemType.Face)
                    {
                        patternIcon.SetNativeSize();
                    }

                    patternIcon.material.SetColor("_Color1",((ColorPreset)data.itemObject).color1);
                    patternIcon.material.SetColor("_Color2",((ColorPreset)data.itemObject).color2);
                }
            }
        }
    }

    public void SetSelect(bool select)
    {
        if (isSelected == select)
        {
            return;
        }
        isSelected = select;
        highLightSprite.SetActive(select);
    }


    private void ClickItem()
    {
        SetSelect(true);
    }
}