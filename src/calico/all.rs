use anyhow::Result;
use kube::api::{ApiResource, DeleteParams, DynamicObject, GroupVersionKind, ListParams, PostParams};
use kube::{Api, Client, ResourceExt};

pub(crate) async fn ban(ip: &String) -> Result<()> {

    let client =  Client::try_default().await?;

    let gvk = GroupVersionKind::gvk("crd.projectcalico.org", "v1", "GlobalNetworkSet");
    let api_resource = ApiResource::from_gvk(&gvk);
    let dynapi: Api<DynamicObject> = Api::all_with(client.clone(), &api_resource);

    let mut data = DynamicObject::new(&format!("jail-{}", ip.replace(".", "-")), &api_resource).data(serde_json::json!({
        "spec": {
            "nets": vec![ip],
        }
    }));
    data.labels_mut().insert(String::from("fail2ban"), String::from("jail"));
    data.labels_mut().insert(String::from("ip"), String::from(ip));
    let val = dynapi.create(&PostParams::default(), &data).await?.data;
    println!("{:?}", val["spec"]);

    Ok(())
}

pub(crate) async fn unban(ip: &String) -> Result<()> {

    let client =  Client::try_default().await?;

    let gvk = GroupVersionKind::gvk("crd.projectcalico.org", "v1", "GlobalNetworkSet");
    let api_resource = ApiResource::from_gvk(&gvk);
    let dynapi: Api<DynamicObject> = Api::all_with(client.clone(), &api_resource);

    let lp = ListParams::default().labels(&format!("ip={}", ip));
    dynapi.delete_collection(&DeleteParams::default(), &lp).await?;

    Ok(())
}