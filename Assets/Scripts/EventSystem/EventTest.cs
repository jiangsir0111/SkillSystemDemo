using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Jundian.EventSystem;

public class EventTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Register();
        PostEvent();
    }

    void Register()
    {
        EventSystem.Instance.RegisterEvent<string, int>(EEvent.TestEvent, OnRecvEvent);
    }


    void PostEvent()
    {
        EventSystem.Instance.PostEvent(EEvent.TestEvent, "TestChar", 2);
    }

    void OnRecvEvent(string a, int b)
    {
        Debug.Log(a + b);
    }
}
