using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class Loading : MonoBehaviour
{
    public static string nextSceneName;

    [SerializeField] private Slider _progressBar;
    bool flag = false;
    private float timer = 0f;
    private float delay = 5;

    // Start is called before the first frame update
    void Start()
    {
        _progressBar.value = 0f;
        StartCoroutine(LoadScene());
    }


    public static void LoadScene(string sceneName)
    {
        nextSceneName = sceneName; 
        SceneManager.LoadScene("Loading");
    }

    IEnumerator LoadScene()
    {
        yield return null;
        
        AsyncOperation asyncOperation;
        asyncOperation = SceneManager.LoadSceneAsync(nextSceneName);
        asyncOperation.allowSceneActivation = false;

        float timer = 0f;

        while (!asyncOperation.isDone)
        {
            yield return null;
            timer += Time.deltaTime;

            if (asyncOperation.progress < 0.9f)
            {
                _progressBar.value = Mathf.Lerp(_progressBar.value, asyncOperation.progress, timer);
                if (_progressBar.value >= asyncOperation.progress)
                    timer = 0f;
            }
            else
            {
                _progressBar.value = Mathf.Lerp(_progressBar.value, 1f, timer);
                if (_progressBar.value == 1f)
                {
                    asyncOperation.allowSceneActivation = true;
                    yield break;
                }
            }
          
        }
        
    }
}
