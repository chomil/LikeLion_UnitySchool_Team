using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using AYellowpaper.SerializedCollections;
using TMPro;

public enum RaceType
{
    Race,
    Team,
    Final
}

[System.Serializable]
public class LoadingData
{
    public RaceType raceType;
    public Sprite loadingImage;
    public Sprite iconImage;
    public string mapTitle;
    public string description;
    public string goldMedalText;
    public string silverMedalText;
    public string bronzeMedalText;
}

public class Loading : MonoBehaviour
{
    public static string nextSceneName;
    public static Sprite iconImage;
    //씬을 로딩할 때 이미지와 설명을 출력하기 위한 딕셔너리 ,키값은 씬 이름
    public AYellowpaper.SerializedCollections.SerializedDictionary<string, LoadingData> LoadingSceneData = new();
    [Header("UI")]
    public Image RaceImage;
    public TextMeshProUGUI RaceTitleText;
    public TextMeshProUGUI DescriptText;
    public TextMeshProUGUI RaceTypeText;
    public TextMeshProUGUI GoldMedalText;
    public TextMeshProUGUI SilverMedalText;
    public TextMeshProUGUI BronzeMedalText;

    bool flag = false;
    private float timer = 0f;
    private float delay = 5;

    // Start is called before the first frame update
    void Start()
    {
        SetLoadingScene();
        StartCoroutine(LoadScene());
    }


    public static void LoadScene(string sceneName)
    {
        // 이전 코드
        // nextSceneName = sceneName; 
        // SceneManager.LoadScene("Loading");
        Debug.Log($"Starting load scene: {sceneName}");
        if (string.IsNullOrEmpty(sceneName))
        {
            Debug.LogError("Scene name is null or empty!");
            return;
        }

        nextSceneName = sceneName;
        SceneManager.LoadScene("Loading");
    }

    private void SetLoadingScene()
    {
        var temp = LoadingSceneData[nextSceneName];
        
        iconImage = temp.iconImage;
        RaceImage.sprite = temp.loadingImage;
        RaceTitleText.text = temp.mapTitle;
        DescriptText.text = temp.description;
        GoldMedalText.text = temp.goldMedalText;
        SilverMedalText.text = temp.silverMedalText;
        BronzeMedalText.text = temp.bronzeMedalText;

        switch (temp.raceType)
        {
            case RaceType.Race:
                RaceTypeText.text = "레이스";
                break;
            case RaceType.Team:
                RaceTypeText.text = "팀";
                break;
            case RaceType.Final:
                RaceTypeText.text = "최종";
                break;
        }
    }

    IEnumerator LoadScene()
    {
        yield return null;
        
        //게임 씬에 맞는 이미지와 텍스트 채워넣기
        
        AsyncOperation asyncOperation;
        asyncOperation = SceneManager.LoadSceneAsync(nextSceneName);
        asyncOperation.allowSceneActivation = false;

        float timer = 0f;
        float delayTimer = 0f;

        while (!asyncOperation.isDone)
        {
            yield return null;
            timer += Time.deltaTime;
            delayTimer += Time.deltaTime;
            if (asyncOperation.progress < 0.9f)
            {
                float progressRate = Mathf.Lerp(0, asyncOperation.progress, timer);
                if (progressRate >= asyncOperation.progress)
                    timer = 0f;
            }
            else
            {
                float progressRate = Mathf.Lerp(0, 1f, timer);
                if (progressRate >= 1f)
                {
                    yield return new WaitForSeconds(delay - delayTimer);
                    asyncOperation.allowSceneActivation = true;
                    SceneChanger.Instance.isRacing = true;
                    yield break;
                }
            }
          
        }
        
    }
}
