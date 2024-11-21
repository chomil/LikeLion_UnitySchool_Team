using UnityEngine;

public class MaintainAspect : MonoBehaviour
{
    private const float TargetAspect = 16f / 9f; // 목표 비율 (16:9)
    private int lastScreenWidth;
    private int lastScreenHeight;

    private bool isResizing = false; 

    void Start()
    {
        AdjustWindowSize();
    }

    void Update()
    {
        // 창 크기가 변경되었는지 확인
        if (Screen.width != lastScreenWidth || Screen.height != lastScreenHeight)
        {
            isResizing = true;
            lastScreenWidth = Screen.width;
            lastScreenHeight = Screen.height;
        }
        else if (isResizing) 
        {
            AdjustWindowSize();
            isResizing = false;
        }
    }

    void AdjustWindowSize()
    {
        int width = Screen.width;
        int height = Screen.height;

        int adjustedHeight = Mathf.RoundToInt(width / TargetAspect);

        if (adjustedHeight > height)
        {
            width = Mathf.RoundToInt(height * TargetAspect);
        }
        else
        {
            height = adjustedHeight;
        }

        Screen.SetResolution(width, height, false);
        
        lastScreenWidth = Screen.width;
        lastScreenHeight = Screen.height;
    }
}