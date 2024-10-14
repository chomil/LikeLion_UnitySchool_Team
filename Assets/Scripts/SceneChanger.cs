using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Random = UnityEngine.Random;

public class SceneChanger : MonoBehaviour
{
    public static SceneChanger Instance { get; private set; }
    
    public Button StartButton;
    
    private List<string> RaceList = new List<string> {"Race01","Race02"};
    private List<string> TeamList; //팀전
    private List<string> finalList; //결승전
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void OnEnable()
    {
        StartButton.onClick.AddListener(() => { SelectRace(); });
    }

    public void MatchingGame()
    {
        //서버에서 매칭시켜주기
    }

    public void SelectRace()
    {
        //null 방지
        if (RaceList.Count == 0) return;
        
        int randIdx = Random.Range(0, RaceList.Count);
        string nextRace = RaceList[randIdx];

        //사용된 레이스는 삭제
        RaceList.RemoveAt(randIdx);
        //씬 로딩
        Loading.LoadScene(nextRace);
    }

    public string GetCurrentScene()
    {
        return SceneManager.GetActiveScene().name;
    }
    
}
