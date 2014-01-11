package valueObjects
{
    
    [Bindable]
    public class AppInfoVO
    {
        public var appId:String;
        public var appVersion:String;
        public var appName:String;
        
        public function AppInfoVO(appId:String, appVersion:String, appName:String)
        {
            this.appId = appId;
            this.appVersion = appVersion;
            this.appName = appName;
        }
    }
}
