package com.wityun.ane
{
    import flash.events.EventDispatcher;
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;

    public class XGPushHelper extends EventDispatcher
    {
        private static var _instance:XGPushHelper;
        private var extCtx:ExtensionContext;
        
        public function XGPushHelper()
        {
            if( _instance == null ){
                extCtx = ExtensionContext.createExtensionContext("com.wityun.CarrierPigeon",null);
                if( extCtx )
                {
                    extCtx.addEventListener( StatusEvent.STATUS,onStatus );
                }
                _instance = this;
            }else
            {
                throw Error("This is a singleton,use getInstance,do not call the constructor directly");	
            }
        }
        
        public static function getInstance():XGPushHelper{
            return _instance ? _instance : new XGPushHelper();
        }
        
        /**
         * 当前ANE是否可以通信 
         * @return 
         * 
         */        
        public function isSupported():Boolean{
            return extCtx.call("isSupported") as Boolean;
        }
        
        /**
         * 初始化信鸽
         * @param appId - 通过前台申请的应用ID
         * @param appKey - 通过前台申请的appKey
         * @return none
         */
        public function startApp(appId:uint,appKey:String):void{
            extCtx.call("startApp",appId,appKey);
        }
        
        /**
         * 设置设备的帐号 (在初始化信鸽后，注册设备之前调用。account本质上是registerDevice的一个参数)
         * @param account - 帐号名（长度为2个字节以上，不要使用"test","123456"这种过于简单的字符串）
         * @return none
         */
        public function setAccount(account:String):void{
            extCtx.call("setAccount",account);
        }
        
        /**
         * 设置tag
         * @param tag - 需要设置的tag
         * @return none
         */
        public function setTag(tag:String):void{
            extCtx.call("setTag",tag);
        }
        
        /**
         * 删除tag
         * @param tag - 需要删除的tag
         * @return none
         */
        public function delTag(tag:String):void{
            extCtx.call("delTag",tag);
        }
        
        /**
         * 注销设备 
         * 
         */        
        public function unRegisterDevice():void{
            extCtx.call("unRegisterDevice");
        }
         
        private function onStatus(e:StatusEvent):void 
        {
            var event : PushNotificationEvent;
            var data:String = e.level;
            switch (e.code)
            {
                case "TOKEN_SUCCESS":
                    event = new PushNotificationEvent( PushNotificationEvent.PERMISSION_GIVEN_WITH_TOKEN_EVENT );
                    event.token = e.level;
                    trace("TOKEN_SUCCESS",event.token);
                    break;
                case "TOKEN_FAIL":
                    event = new PushNotificationEvent( PushNotificationEvent.PERMISSION_REFUSED_EVENT );
                    event.errorCode = "NativeCodeError";
                    event.errorMessage = e.level;
                    trace("TOKEN_FAIL",event.errorMessage);
                    break;
                case "COMING_FROM_NOTIFICATION":
                    event = new PushNotificationEvent( PushNotificationEvent.COMING_FROM_NOTIFICATION_EVENT );
                    if (data != null)
                    {
                        try
                        {
                            event.parameters = JSON.parse(data);
                        } catch (error:Error)
                        {
                            trace("[PushNotification Error]", "cannot parse the params string", data);
                        }
                    }
                    break;
                case "APP_STARTING_FROM_NOTIFICATION":
                    event = new PushNotificationEvent( PushNotificationEvent.APP_STARTING_FROM_NOTIFICATION_EVENT );
                    if (data != null)
                    {
                        try
                        {
                            event.parameters = JSON.parse(data);
                        } catch (error:Error)
                        {
                            trace("[PushNotification Error]", "cannot parse the params string", data);
                        }
                    }
                    break;
                case "APP_BROUGHT_TO_FOREGROUND_FROM_NOTIFICATION":
                    event = new PushNotificationEvent( PushNotificationEvent.APP_BROUGHT_TO_FOREGROUND_FROM_NOTIFICATION_EVENT );
                    if (data != null)
                    {
                        try
                        {
                            event.parameters = JSON.parse(data);
                        } catch (error:Error)
                        {
                            trace("[PushNotification Error]", "cannot parse the params string", data);
                        }
                    }
                    break;
                case "APP_STARTED_IN_BACKGROUND_FROM_NOTIFICATION": //app start in background
                    event = new PushNotificationEvent( PushNotificationEvent.APP_STARTED_IN_BACKGROUND_FROM_NOTIFICATION_EVENT );
                    if (data != null)
                    {
                        try
                        {
                            event.parameters = JSON.parse(data);
                        } catch (error:Error)
                        {
                            trace("[PushNotification Error]", "cannot parse the params string", data);
                        }
                    }
                    break;
                case "NOTIFICATION_RECEIVED_WHEN_IN_FOREGROUND":
                    event = new PushNotificationEvent( PushNotificationEvent.NOTIFICATION_RECEIVED_WHEN_IN_FOREGROUND_EVENT );
                    if (data != null)
                    {
                        try
                        {
                            event.parameters = JSON.parse(data);
                        } catch (error:Error)
                        {
                            trace("[PushNotification Error]", "cannot parse the params string", data);
                        }
                    }
                    break;
                case "LOGGING":
                    trace(e, e.level);
                    break;
            }
            
            if (event != null)
            {
                this.dispatchEvent( event );
            }				
        }
    }
}