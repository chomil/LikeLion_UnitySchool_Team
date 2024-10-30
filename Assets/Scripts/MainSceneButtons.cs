using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

//Main Scene 전담 버튼 관리자
public class MainSceneButtons : MonoBehaviour
{
    public Button StartButton;
    public Button CustomizeButton;
    // Start is called before the first frame update
    void Start()
    {
        //씬 전환 시에 리스너 재등록
        SceneChanger.Instance.RegisterButton(StartButton, PlayRace);
        SceneChanger.Instance.RegisterButton(CustomizeButton, GoCustomizeScene);
    }

    private void PlayRace()
    {
        SceneChanger.Instance.MatchingGame();
        //SceneChanger.Instance.PlayRace();
    }

    private void GoCustomizeScene()
    {
        SceneChanger.Instance.GoCustomizeScene();
    }
}
