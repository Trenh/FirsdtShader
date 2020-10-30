using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeMatWhenClicked : MonoBehaviour
{
    Shader outlineShader;
    // Start is called before the first frame update
    void Start()
    {
        outlineShader= Shader.Find("Custom/Outline");
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {

            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            
            if(Physics.Raycast(ray,out hit, 100.0f))
            {
                Transform parent = hit.collider.gameObject.transform.parent;
                for(int i=0;i<parent.childCount;i++)
                {
                    GameObject childObj = parent.GetChild(i).gameObject;
                    childObj.GetComponent<Renderer>().sharedMaterial.shader = Shader.Find("Standard");
                }
                GameObject gameObj= hit.collider.gameObject;
                Material mat= gameObj.GetComponent<Renderer>().material;
                mat.shader = outlineShader;
                mat.SetFloat("_Outline",0.1f);

            }
        }
    }
}
