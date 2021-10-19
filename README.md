
<p align="center"><strong>Soul iOS App逆向实战 </strong></p>

# **SoulHook 工作繁忙 不再更新**

## 功能：  
- [x] 聊天强制送礼物解除  
- [x] 自定义显示匹配值    
- [x] 去除消息撤回2min限制  
- [x] 防止消息撤回  
- [x] 已读回执取消 即绿点消除  
- [x] 输入状态禁止  
- [x] 多媒体消息链接复制  
- [x] 跳转指定UserID主页  
- [x] 机器人回复消息（[莉莉机器人](http://www.itpk.cn/)）  
- [ ] ~~自动回复/消息轰炸~~ 待修复
- [ ]  ~~捏脸道具免费~~ 已失效
- [ ] ~~猜拳&骰子作弊~~ 已失效
- [ ] ~~修改旧版本头像~~ 已失效

等等...

## 快速开始
1. 自备签名和证书，主工程SoulHook和SoulHookDylib中的证书、签名均需要更改
2. 把破壳后的Soul.ipa放在工程目录TargetApp文件夹下

> 注: 
> 1. 编译报错可先删除 **.LatestBuild** 文件夹和 **TargetApp** 文件夹下的 **Soul.app** 。
> 2. Soul破壳包v4.3.0[下载](https://pan.baidu.com/s/18GV02ALjfytaHEaEq-UTvQ)（访问码：qtwn）

---


**不再支持自定义头像 更新至3.53.0**  
后台有验证，即使上传图片成功也无法修改头像  
例子：  
[头像1](https://img.soulapp.cn/heads/avatar-1579662689148-04005.png)  
[头像2](https://img.soulapp.cn/heads/avatar-1579662689106-04588.png)  

## 二次开发注意
- 更改请求header中的device-id和sdi可能导致请求失败，报错如下，擅自更改**可能**导致封号。

```
code = 9000006,
message = "服务器有些小异常，可以通过意见反馈或关注官博Soul社交反馈哦~",
data = <null>,
success = 0
```

## 免责声明
本项目遵循MIT license，方便交流与学习，包括但不限于本项目的衍生品都禁止在损害Soul官方利益情况下进行盈利。如果您发现本项目有侵犯您的知识产权，请与我取得联系，我会及时修改或删除。
