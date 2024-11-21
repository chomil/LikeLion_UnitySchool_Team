using System;
using System.Collections;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
using DG.Tweening;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class CustomizeWindow : MonoBehaviour
{
    private ItemType curMenu = ItemType.None;
    public SerializedDictionary<ItemType, GameObject> menuButtons;
    public SerializedDictionary<bool,Sprite> menuSprite1;
    public SerializedDictionary<bool,Sprite> menuSprite2;

    public TextMeshProUGUI selectedItemText;
    public GameObject itemGrid;
    public ItemButton itemButtonPrefab;
    
    private ItemButton selectedItemButton;
    
    private void Start()
    {
        foreach (var menu in menuButtons)
        {
            menu.Value.GetComponent<Button>().onClick.AddListener(()=>ClickMenu(menu.Key));
        }

        ClickMenu(ItemType.Color);
    }

    public void ClickMenu(ItemType clickedMenu)
    {
        if (curMenu == clickedMenu)
        {
            return;
        }
        
        
        SoundManager.Instance.PlaySfx("UIPop");

        if (curMenu != ItemType.None)
        {
            menuButtons[curMenu].GetComponent<Image>().sprite = 
                (int)curMenu % 2 == 0 ? menuSprite1[false] : menuSprite2[false];
            menuButtons[curMenu].transform.DOScale(1.0f, 0.1f);
        }

        menuButtons[clickedMenu].GetComponent<Image>().sprite = 
            (int)clickedMenu % 2 == 0 ? menuSprite1[true] : menuSprite2[true];
        menuButtons[clickedMenu].transform.DOScale(1.2f, 0.1f);
        
        curMenu = clickedMenu;
        
        LoadItems(clickedMenu);
    }

    public void LoadItems(ItemType clickedMenu)
    {
        GameData data = GameManager.Instance.gameData;
        selectedItemButton = null;
        
        //기존 창의 버튼들 삭제
        foreach (Transform child in itemGrid.transform)
        {
            child.GetComponent<Button>().onClick.RemoveAllListeners();
            Destroy(child.gameObject);
        }

        //카테고리에 맞는 버튼들 생성
        itemGrid.GetComponent<RectTransform>().sizeDelta =
            new Vector2(800, 200 * (int)((data.allItemDatas[clickedMenu].Count-1) / 4 + 1));
        if (data.allItemDatas[clickedMenu].Count == 0)
        {
            selectedItemText.text = "없음";
        }
        foreach (ItemData iData in data.allItemDatas[clickedMenu])
        {
            ItemButton curButton = Instantiate(itemButtonPrefab, itemGrid.transform);
            curButton.SetItemData(iData);
            if (iData.itemName == data.playerInfo.playerItems[iData.itemType])
            {
                selectedItemButton?.SetSelect(false);
                curButton.SetSelect(true);
                selectedItemButton = curButton;
                selectedItemText.text = selectedItemButton.itemData.itemName;
            }
            curButton.GetComponent<Button>().onClick.AddListener(()=>ClickItem(curButton));
        }
    }
    private void ClickItem(ItemButton clickButton)
    {
        if (selectedItemButton == clickButton)
        {
            return;
        }
        
        
        SoundManager.Instance.PlaySfx("UISelect");
        
        selectedItemButton.SetSelect(false);
        selectedItemText.text = clickButton.itemData.itemName;
        GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerCostume>().ChangeCostume(clickButton.itemData);
        selectedItemButton = clickButton;
    }
}
