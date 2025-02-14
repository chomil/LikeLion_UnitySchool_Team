using UnityEngine;

public class StepTrigger : MonoBehaviour
{
    public delegate void StepEvent(Collider other);
    public event StepEvent OnStepEvent; 

    private void OnTriggerStay(Collider other)
    {
        OnStepEvent?.Invoke(other); // 이벤트 호출
    }
}