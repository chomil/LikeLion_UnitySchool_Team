using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ManageToTitleScene : MonoBehaviour
{
    public void GoToMain()
    {
        SoundManager.Instance.PlaySfx("UISelect");
        SceneManager.LoadScene("Main");
    }
}
