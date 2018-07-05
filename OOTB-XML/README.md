首先我们需要知道 COS 服务的整体架构如下图所示：

![](http://mc.qcloudimg.com/static/img/b1e187a9ec129ffc766c07a733ef4dd6/image.jpg)

其中 CAM 权限系统和 COS 对象存储是腾讯云提供给开发者的两大服务模块，而用户服务端和用户客户端需要用户自己去搭建，下面本文即介绍如何快速搭建一个基于 COS 的应用传输服务。

这里将依次介绍用户服务端和用户客户端两个部分：

## 搭建用户服务端

在本示例中，用户服务端仅仅提供临时密钥的功能。cos\_signer\_lite 是一个基于 flask 服务框架的临时秘钥服务，该项目采用 python3 编写，您可以在自己的机器或者虚拟机上运行该 python 项目，为您的 COS 终端（Android/iOS）SDK 提供临时密钥服务。
> 注意：该项目只是用于示例，不可直接用于生产环境，生产环境中您可以使用 COS 服务端 SDK 的临时秘钥接口。


### 配置环境

cos\_signer\_lite 采用 python3 编写，你首先需要安装 python3 环境，并在 python3 环境下安装 flask 模块。

```
pip3 install flask
```

### 配置密钥信息

cos\_signer\_lite 需要你在 [../cos_signer_lite/cam/config.py](https://github.com/tencentyun/qcloud-sdk-android-samples/blob/master/QCloudCosSimpleSample/cos_signer_lite/cam/config.py) 中配置密钥信息，然后 cos\_signer\_lite 会在您每次请求时向 CAM 服务请求临时密钥。

```
    # 用户的secret id
    SECRET_ID = 'xxx'
    # 用户的secret key
    SECRET_KEY = 'xxx'
```

> 密钥信息可以在 [这里查询](https://console.cloud.tencent.com/cam/capi)


### 启动服务

您可以通过如下代码启动服务：

```
python3 main.py
```

### 测试服务

你可以通过浏览器访问 `http://0.0.0.0:5000/sign` 链接，如果浏览器返回如下信息，则说明服务已经成功运行。

```
{
 "code":0,
 "message":"",
 "codeDesc":"Success",
 "data":{
  "credentials":{
   "sessionToken":"634aa09dccc3274045ba413ec081c1df64007f0a30001",
   "tmpSecretId":"AKIDwxHZGTUvXAfcbLaOedJUQuwBXWUXG4m3",
   "tmpSecretKey":"kriDdZsOuuF9zrZPlSAVVG0Sg4RXZu6M"},
  "expiredTime":1530515889}
 }
```

### 出错自救指南
搭建临时密钥的过程中可能会出错，如果出现了对应的错误，可以参考以下的信息：
1. 问题：运行安装命令 pip3 install flask 提示 comment not found pip3    
解决方案：这是因为没有安装 python3，或者 path 没有设置对（如果安装了 Python 3 ），可根据系统对应寻找安装
方式

2. 运行起来以后，获取临时密钥时提示 URLError: urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed 字样的错误    
该问题常见于 MAC OS X 系统，安装 certifi 模块即可，具体操作方式可参考 [安装命令](https://stackoverflow.com/questions/27835619/urllib-and-ssl-certificate-verify-failed-error/42334357#42334357) 。





## 搭建用户客户端

### 配置客户端

修改 QCloudCOSXMLDemo/QCloudCOSXMLDemo/TestCommonDefine.h 文件，填入 APPID 以及 前面部署好的可以获取临时密钥的地址，然后运行

```
pod install
```
以后，打开 QCloudCOSXMLDemo.xcworkspace 即可进入 demo 体验。
### 运行示例 Demo
#### 查询 bucket 列表并创建 bucket

启动示例 app 后，会展示目前所有可用的 Region 。


![选择 Region](https://ios-release-1253960454.cos.ap-shanghai.myqcloud.com/imagebed/iOS_OOTB_DEMO_select_region.png)


选择对应某个 Region 进入以后会显示当前账号在该 Region 下面的所有 Bucket 。

![选择 Bucket](https://ios-release-1253960454.cos.ap-shanghai.myqcloud.com/imagebed/iOS_OOTB_Demo_select_bucket.png)

也可以在该界面点击右上角的创建 Bucket 按钮来在当前 Region 下面创建一个 Bucket 。
![创建 Bucket](https://ios-release-1253960454.cos.ap-shanghai.myqcloud.com/imagebed/iOS_OOTB_Demo_create_bucket.png)
#### 上传文件

您可以点击最下面的按钮依次【相册】->【上传】->【暂停】->【续传】-> 【取消】来进行上传测试：

![上传界面](https://ios-release-1253960454.cos.ap-shanghai.myqcloud.com/imagebed/iOS_OOTB_DEMO_upload.png)



#### 下载文件

进入下载界面后，会显示当前 bucket 内的所有文件，可以点击进行下载。

![下载页面](https://ios-release-1253960454.cos.ap-shanghai.myqcloud.com/imagebed/iOS_OOTB_DEMO_download.png)
