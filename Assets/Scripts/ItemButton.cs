using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ItemButton : MonoBehaviour
{
    public GameObject highLightSprite;
    public GameObject noneSprite;
    public Image itemIcon;

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
            itemIcon.enabled = false;
        }
        else
        {
            itemIcon.sprite = itemData.itemIcon;
            itemIcon.SetNativeSize();
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