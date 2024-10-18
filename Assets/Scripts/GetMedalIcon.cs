using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GetMedalIcon : MonoBehaviour
{
    private Image myImage;
    // Start is called before the first frame update
    void Start()
    {
        myImage = GetComponent<Image>();
        myImage.sprite = Loading.iconImage;
    }

    
}
