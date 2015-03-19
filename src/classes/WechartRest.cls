@RestResource(urlMapping='/WeChatRest/*')
global with sharing class WechartRest
{

    @HttpGet
    global static void verifyAccount()
    {
        System.debug('run');
        RestRequest request = RestContext.request;
        String echo = request.params.get('echostr');
        Boolean isValid = isValidate(request);
        System.debug('isValidate'+isValid);
        if(isValid)
        {
            RestContext.response.responseBody = Blob.valueOf(echo);
        }
    }

      global static Boolean isValidate(RestRequest request)
    {
        Boolean isValid = false;
            String token = 'token';
            String timestamp = request.params.get('timestamp');
            String nonce = request.params.get('nonce');
            String signature = request.params.get('signature');
            List<String> strArr = new List<String>{token,timestamp,nonce};
            strArr.sort();
            Blob signing = Crypto.generateDigest('SHA1',Blob.valueOf(strArr[0]+strArr[1]+strArr[2]));
            String result = EncodingUtil.convertToHex(signing);
            isValid = signature == null ? false : signature.equals(result);
            return isValid;
    }
    @HttpPost
    global static void doPost(){
        //存储XML各节点数据变量
        String toUserName = '';
        String fromUserName = '';
        String msgType = '';
        String content = '';
        //获取XML数据包
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string strMsg = req.requestBody.toString();  
        XmlStreamReader reader = new XmlStreamReader(strMsg);

        //解析XML数据包，Force.com这块的处理能力并不强，简单的结构也需要较多代码来解析
         while(reader.hasNext()){
            if(reader.getLocalName() == 'ToUserName'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    toUserName = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'FromUserName'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    fromUserName = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'MsgType'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    msgType = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'Content'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    content = reader.getText();
                }
            }
            reader.next();
        }
        
         Datetime dt = System.now();
    String returnDT = dt.format('EEEE, MMMM d, yyyy');
    String rtnMsg = 'WOWOWOWOW!GZZTZ!';
    String replyMSG = '<xml><ToUserName><![CDATA[{0}]]></ToUserName><FromUserName><![CDATA[{1}]]></FromUserName><CreateTime>12345678</CreateTime><MsgType><![CDATA[text]]></MsgType><Content><![CDATA[{2}]]></Content></xml>';
    String[] arguments = new String[]{fromUserName, toUserName, rtnMsg};
    String formattedReplyMSG = String.format(replyMSG, arguments);
    RestContext.response.addHeader('Content-Type', 'text/plain');
    RestContext.response.responseBody = Blob.valueOf(rtnMsg);
    }
    
   
    
    
}