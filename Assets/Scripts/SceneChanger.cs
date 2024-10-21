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

    /*public Button StartButton;
    public Button CustomizeButton;*/
    public List<string> RaceList = new(); //일반 레이스
    public List<string> TeamList; //팀전
    public List<string> finalList; //결승전
    

    private List<string> raceToPlay; //여기서 맵을 랜덤하게 뽑아서 경기
    private List<string> teamToPlay; 
    private List<string> finalToPlay;
    private bool isRacing = false; //플레이하는 중이 아니라면 플레이어의 입력을 못 받도록 하는 변수
    private Dictionary<Button, Action> buttonActions = new ();
    
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
        //플레이 할 맵 초기화
        raceToPlay = RaceList;
    }

    private void OnDisable()
    {
        //버튼 이벤트 해제
        ClearAllButtons();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape) && GetCurrentScene() != "Main" && !isRacing)
        {
            SceneManager.LoadScene("Main");
        }
    }

    public void MatchingGame()
    {
        //서버에서 매칭시켜주기
    }

    public string GetCurrentScene()
    {
        return SceneManager.GetActiveScene().name;
    }
    
    //버튼 이벤트 등록
    public void RegisterButton(Button button, Action onClickAction)
    {
        if (buttonActions.ContainsKey(button)) return;

        buttonActions.Add(button, onClickAction);
        button.onClick.AddListener(() => onClickAction?.Invoke());
    }

    // 모든 버튼의 리스너 제거
    public void ClearAllButtons()
    {
        foreach (var kvp in buttonActions)
        {
            kvp.Key.onClick.RemoveAllListeners();
        }
        buttonActions.Clear();
    }
    
    //Start Button Event
    public void PlayRace()
    {
        //null 방지
        if (raceToPlay.Count == 0) return;

        isRacing = true;
        
        int randIdx = Random.Range(0, raceToPlay.Count);
        string nextRace = raceToPlay[randIdx];

        //사용된 레이스는 삭제
        raceToPlay.RemoveAt(randIdx);
        //씬 로딩
        Loading.LoadScene(nextRace);
    }

    //Customize Button Event
    public void GoCustomizeScene()
    {
        SceneManager.LoadScene("Customize");
    }
}
