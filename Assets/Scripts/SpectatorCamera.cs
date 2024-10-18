using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpectatorCamera : MonoBehaviour
{
    public void SetCamera()
    {
        GetComponentInChildren<Camera>().enabled = true;
    }

    public void ClearCamera()
    {
        GetComponentInChildren<Camera>().enabled = false;
    }
}
