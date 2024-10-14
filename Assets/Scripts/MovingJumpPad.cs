using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingJumpPad : MonoBehaviour
{
    public float moveSpeed = 1f;
    public float moveDistance = 5f;
    public bool moveInXAxis = true; // X축 이동 여부
    public bool moveInZAxis = false; // Z축 이동 여부

    private Vector3 startPosition;
    private Vector3 endPositionPositive;
    private Vector3 endPositionNegative;

    void Start()
    {
        startPosition = transform.position;
        Vector3 moveVector = Vector3.zero;

        if (moveInXAxis)
            moveVector += Vector3.right * moveDistance;
        if (moveInZAxis)
            moveVector += Vector3.forward * moveDistance;

        endPositionPositive = startPosition + moveVector;
        endPositionNegative = startPosition - moveVector;

        StartCoroutine(MoveJumpPad());
    }

    IEnumerator MoveJumpPad()
    {
        float elapsedTime = 0f;

        while (true)
        {
            elapsedTime += Time.deltaTime * moveSpeed;
            float t = Mathf.PingPong(elapsedTime, 2f) - 1f; // -1에서 1 사이의 값
            transform.position = Vector3.Lerp(endPositionNegative, endPositionPositive, (t + 1f) / 2f);
            yield return null;
        }
    }
}
