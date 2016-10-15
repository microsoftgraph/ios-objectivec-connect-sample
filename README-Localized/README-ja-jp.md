# <a name="office-365-connect-sample-for-ios-using-the-microsoft-graph-sdk"></a>Microsoft Graph SDK を使用した iOS 用 Office 365 Connect サンプル

Microsoft Graph は、Microsoft Cloud からのデータ、リレーションシップおよびインサイトにアクセスするための統合エンドポイントです。このサンプルでは、これに接続して認証し、[Microsoft Graph SDK for iOS](https://github.com/microsoftgraph/msgraph-sdk-ios) 経由でメールとユーザーの API を呼び出す方法を示します。

> 注:このサンプルをより迅速に実行するため、登録手順が簡略化された「[Microsoft Graph アプリ登録ポータル](https://apps.dev.microsoft.com)」ページをお試しください。

## <a name="prerequisites"></a>前提条件
* Apple 社の [Xcode](https://developer.apple.com/xcode/downloads/) をダウンロードする。

* 依存関係マネージャーとしての [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) のインストール。
* Office 365、outlook.com、hotmail.com などの、Microsoft の職場または個人用のメール アカウント。Office 365 アプリのビルドを開始するために必要なリソースを含む、[Office 365 Developer サブスクリプション](https://aka.ms/devprogramsignup)にサインアップできます。

     > 注:サブスクリプションをすでにお持ちの場合、上記のリンクをクリックすると、「*申し訳ございません。現在のアカウントに追加できません*」というメッセージが表示されるページに移動します。その場合は、現在使用している Office 365 サブスクリプションのアカウントをご利用いただけます。    
* [Microsoft Graph アプリ登録ポータル](https://apps.dev.microsoft.com)で登録済みのアプリのクライアント ID
* 要求を実行するには、適切な OAuth 2.0 ベアラー トークンを使用して HTTPS 要求を認証できる **MSAuthenticationProvider** を指定する必要があります。プロジェクトのジャンプ スタート用に使用できる MSAuthenticationProvider をサンプル実装するために、[msgraph-sdk-ios-nxoauth2-adapter](https://github.com/microsoftgraph/msgraph-sdk-ios-nxoauth2-adapter) を使用します。詳細については、以下の「**目的のコード**」セクションをご覧ください。


## <a name="running-this-sample-in-xcode"></a>Xcode でこのサンプルを実行する

1. このリポジトリの複製を作成する
2. これが既にインストールされていない場合、**ターミナル** アプリから以下のコマンドを実行して、CocoaPods の依存関係のマネージャーをインストールして設定します。

        sudo gem install cocoapods
    
        pod setup

2. CocoaPods を使用して、Microsoft Graph SDK と認証の依存関係をインポートします:

        pod 'MSGraphSDK'
        pod 'MSGraphSDK-NXOAuth2Adapter'


 このサンプル アプリには、プロジェクトに pod を取り込む podfile が既に含まれています。ここで、profile のあるプロジェクト ルートに移動し、**ターミナル**から以下を実行します：

        pod install

   詳細については、[その他のリソース](#AdditionalResources)の「**CocoaPods を使う**」を参照してください

3. **O365-iOS-Microsoft-Graph-SDK.xcworkspace** を開きます
4. **AuthenticationConstants.m** を開きます。登録プロセスの **ClientID** がファイルの一番上に追加されていることが分かります。:

        // You will set your application's clientId
        NSString * const kClientId    = @"ENTER_YOUR_CLIENT_ID";

    > 注:次のアクセス許可の適用範囲がこのプロジェクトに対して構成されていることが分かります。: **"https://graph.microsoft.com/Mail.Send"、"https://graph.microsoft.com/User.Read"、"offline_access"**。このプロジェクトで使用されるサービス呼び出し、メール アカウントへのメールの送信、および一部のプロファイル情報 (表示名、メール アドレス) の取得には、アプリが適切に実行するためにこれらのアクセス許可が必要です。

5. サンプルを実行します。職場または個人用のメール アカウントに接続または認証するように求められ、そのアカウントか、別の選択したメール アカウントにメールを送信することができます。


##<a name="code-of-interest"></a>目的のコード

すべての認証コードは、**AuthenticationProvider.m** ファイルで確認することができます。[NXOAuth2Client](https://github.com/nxtbgthng/OAuth2Client) から拡張された MSAuthenticationProvider のサンプル実装を使用して、登録済みのネイティブ アプリのログインのサポート、アクセス トークンの自動更新、およびログアウト機能を提供します:

        [[NXOAuth2AuthenticationProvider sharedAuthProvider] loginWithViewController:nil completion:^(NSError *error) {
            if (!error) {
            [MSGraphClient setAuthenticationProvider:[NXOAuth2AuthenticationProvider sharedAuthProvider]];
            self.client = [MSGraphClient client];
             }
        }];


認証プロバイダーを設定すると、Microsoft Graph サービス エンドポイント (メールとユーザー) に対して呼び出しを実行するために使用されるクライアント オブジェクト (MSGraphClient) の作成と初期化が行えます。**SendMailViewcontroller.m** では、次のコードを使用して、メール要求をアセンブルし、送信できます:

    MSGraphUserSendMailRequestBuilder *requestBuilder = [[self.client me]sendMailWithMessage:message saveToSentItems:true];    
    MSGraphUserSendMailRequest *mailRequest = [requestBuilder request];   
    [mailRequest executeWithCompletion:^(NSDictionary *response, NSError *error) {      
    }];


OneDrive のような他のサービスへの呼び出しを行うコードなどの詳細については、「[Microsoft Graph SDK for iOS](https://github.com/microsoftgraph/msgraph-sdk-ios)」を参照してください

## <a name="questions-and-comments"></a>質問とコメント

Office 365 iOS Microsoft Graph Connect プロジェクトに関するフィードバックをお寄せください。質問や提案につきましては、このリポジトリの「[問題](https://github.com/microsoftgraph/iOS-objectivec-connect-sample/issues)」セクションで送信できます。

Office 365 開発全般の質問につきましては、「[Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API)」に投稿してください。質問またはコメントには、必ず [Office365] および [MicrosoftGraph] のタグを付けてください。

## <a name="contributing"></a>投稿
プル要求を送信する前に、[投稿者のライセンス契約](https://cla.microsoft.com/)に署名する必要があります。投稿者のライセンス契約 (CLA) を完了するには、ドキュメントへのリンクを含むメールを受信した際に、フォームから要求を送信し、CLA に電子的に署名する必要があります。

このプロジェクトでは、[Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/) が採用されています。詳細については、「[規範に関する FAQ](https://opensource.microsoft.com/codeofconduct/faq/)」を参照してください。または、その他の質問やコメントがあれば、[opencode@microsoft.com](mailto:opencode@microsoft.com) までにお問い合わせください。

## <a name="additional-resources"></a>追加リソース

* [Office デベロッパー センター](http://dev.office.com/)
* [Microsoft Graph の概要ページ](https://graph.microsoft.io)
* [CocoaPods を使う](https://guides.cocoapods.org/using/using-cocoapods.html)

## <a name="copyright"></a>著作権
Copyright (c) 2016 Microsoft.All rights reserved.
