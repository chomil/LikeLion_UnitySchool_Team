using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Item/ColorPreset")]
[System.Serializable]
public class ColorPreset : ScriptableObject
{
    public Color color1;
    public Color color2;
}
