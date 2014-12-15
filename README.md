xgane
=====

腾讯信鸽推送ANE IOS版

信鸽SDK版本 : xg-ios-sdk-2.2.0

### API

保持与信鸽IOS API签名高度一致.

```
//用来测试是否与OC正常通信
XGPushHelper.getInstance().isSupported();

//初始化信鸽, 初始化信鸽会自动注册推送类型以及注册设备
XGPushHelper.getInstance().startApp(appId,appKey);

//设置设备别名
XGPushHelper.getInstance().setAccount(account:String);

//设置标签
XGPushHelper.getInstance().setTag(tag);

//删除标签
XGPushHelper.getInstance().delTag(tag);

//注销设备
XGPushHelper.getInstance().unRegisterDevice();

```

目前本地推送部分还不支持。

### 配置

Objective-C的工程是根据xcode ane templete创建的，如果希望自己编译打包ANE，使用xcode导入oc工程后，

选择 CarrierPigeon.ane的target，修改User-Defined中的 AIR_SDK_PATH以及NATIVEEXTENSION_SWC地址

重新build即可。

