using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class SpectatorUI : MonoBehaviour
{
    public static SpectatorUI Instance { get; private set; }
    
    [Header("Spectator UI")]
    [SerializeField] private TextMeshProUGUI spectatingPlayerText;
    [SerializeField] private Image pageUpImage;    // Page Up 이미지
    [SerializeField] private Image pageDownImage;  // Page Down 이미지
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
        
        // 초기에 UI 숨기기
        HideSpectatorUI();
        // 초기에 이미지 투명도 설정
        if (pageUpImage != null) SetImageAlpha(pageUpImage, 0.5f);
        if (pageDownImage != null) SetImageAlpha(pageDownImage, 0.5f);
    }

    private void Update()
    {
        // 키 입력 처리
        if (Input.GetKeyDown(KeyCode.PageUp))
        {
            SpectatorManager.Instance.SwitchToNextSpectator();
            StartCoroutine(PressEffect(pageUpImage));
        }
        else if (Input.GetKeyDown(KeyCode.PageDown))
        {
            SpectatorManager.Instance.SwitchToPreviousSpectator();
            StartCoroutine(PressEffect(pageDownImage));
        }
    }
    
    public void HideSpectatorUI()
    {
        if (pageUpImage != null) pageUpImage.gameObject.SetActive(false);
        if (pageDownImage != null) pageDownImage.gameObject.SetActive(false);
        if (spectatingPlayerText != null) spectatingPlayerText.gameObject.SetActive(false);
    }
    
    private void SetImageAlpha(Image image, float alpha)
    {
        Color color = image.color;
        color.a = alpha;
        image.color = color;
    }

    // 키 입력 시 눌림 효과
    private IEnumerator PressEffect(Image image)
    {
        SetImageAlpha(image, 1f);  // 완전 불투명
        yield return new WaitForSeconds(0.1f);
        SetImageAlpha(image, 0.5f);  // 다시 반투명
    }

    public void ShowSpectatorUI()
    {
        if (pageUpImage != null) pageUpImage.gameObject.SetActive(true);
        if (pageDownImage != null) pageDownImage.gameObject.SetActive(true);
        if (spectatingPlayerText != null) spectatingPlayerText.gameObject.SetActive(true);
    }

    public void UpdateSpectatingPlayerInfo(string playerId)
    {
        if (spectatingPlayerText != null)
        {
            spectatingPlayerText.text = $"현재 관전 중: Player {playerId}";
        }
    }
    
}

