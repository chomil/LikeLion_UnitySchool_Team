using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class GrabTrigger : MonoBehaviour
{
    public delegate void GrabEvent(Collider other);
    public event GrabEvent OnGrabEvent;
    public event GrabEvent ExitGrabEvent;

    private void OnTriggerStay(Collider other)
    {
        OnGrabEvent?.Invoke(other);
    }

    private void OnTriggerExit(Collider other)
    {
        ExitGrabEvent?.Invoke(other);
    }
}
