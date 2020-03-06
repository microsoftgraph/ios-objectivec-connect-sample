# <a name="office-365-connect-sample-for-ios-using-the-microsoft-graph-sdk"></a>Office 365 Connect-Beispiel für iOS unter Verwendung des Microsoft Graph-SDKs

Microsoft Graph ist ein einheitlicher Endpunkt für den Zugriff auf Daten, Beziehungen und Erkenntnisse, die von der Microsoft-Cloud stammen. In diesem Beispiel wird gezeigt, wie Sie eine Verbindung damit herstellen und die Authentifizierung ausführen, und dann E-Mails und Benutzer-APIs über das [Microsoft Graph-SDK für iOS](https://github.com/microsoftgraph/msgraph-sdk-ios) aufrufen.

> Hinweis: Testen Sie die Seite des [App-Registrierungsportals von Microsoft Graph](https://apps.dev.microsoft.com), durch das die Registrierung erleichtert wird, sodass Sie schneller mit diesem Beispiel loslegen können.

## <a name="prerequisites"></a>Voraussetzungen
* Herunterladen von [Xcode](https://developer.apple.com/xcode/downloads/) von Apple.

* Installation von [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) als ein Abhängigkeits-Manager.
* Ein geschäftliches oder persönliches Microsoft-E-Mail-Konto, z. B. Office 365 oder outlook.com, hotmail.com usw. Sie können sich für ein [Office 365-Entwicklerabonnement](https://aka.ms/devprogramsignup) registrieren. Dieses umfasst die Ressourcen, die Sie zum Erstellen von Office 365-Apps benötigen.

     > Hinweis: Wenn Sie bereits über ein Abonnement verfügen, gelangen Sie über den vorherigen Link zu einer Seite mit der Meldung *Leider können Sie Ihrem aktuellen Konto diesen Inhalt nicht hinzufügen*. Verwenden Sie in diesem Fall ein Konto aus Ihrem aktuellen Office 365-Abonnement.    
* Eine Client-ID aus der registrierten App unter dem [App-Registrierungsportal von Microsoft Graph](https://apps.dev.microsoft.com)
* Um Anforderungen auszuführen, muss ein **MSAuthenticationProvider** bereitgestellt werden, der HTTPS-Anforderungen mit einem entsprechenden OAuth 2.0-Bearertoken authentifizieren kann. Wir verwenden [msgraph-sdk-ios-nxoauth2-adapter](https://github.com/microsoftgraph/msgraph-sdk-ios-nxoauth2-adapter) für eine Beispielimplementierung von MSAuthenticationProvider, die Sie für einen Schnelleinstieg in Ihr Projekt verwenden können. Weitere Informationen finden Sie im folgenden Abschnitt **Interessanter Code**.


## <a name="running-this-sample-in-xcode"></a>Ausführen dieses Beispiels in Xcode

1. Klonen dieses Repositorys
2. Wenn nicht bereits installiert, führen Sie die folgenden Befehle aus der **Terminal**-App aus, um den CocoaPods-Abhängigkeits-Manager zu installieren und einzurichten.

        sudo gem install cocoapods
    
        pod setup

2. Verwenden Sie CocoaPods, um das Microsoft Graph-SDK und Authentifizierungsabhängigkeiten zu importieren:

        pod 'MSGraphSDK'
        pod 'MSGraphSDK-NXOAuth2Adapter'


 Diese Beispiel-App enthält bereits eine POD-Datei, die die Pods in das Projekt überträgt. Navigieren Sie einfach zum Stammordner des Projekts, in dem sich die Podfile befindet, und führen Sie von **Terminal** Folgendes aus:

        pod install

   Weitere Informationen finden Sie im Thema über das **Verwenden von CocoaPods** in [Zusätzliche Ressourcen](#AdditionalResources).

3. Öffnen Sie **Ios-Objectivec-sample.xcworkspace**.
4. Öffnen Sie **AuthenticationConstants.m**. Sie werden sehen, dass die **ClientID** aus dem Registrierungsprozess am Anfang der Datei hinzugefügt werden kann:

   ```objectivec
        // You will set your application's clientId
        NSString * const kClientId    = @"ENTER_YOUR_CLIENT_ID";
   ```


    Sie stellen fest, dass die folgenden Berechtigungsumfänge für dieses Projekt konfiguriert wurden: 

```@"https://graph.microsoft.com/User.Read, https://graph.microsoft.com/Mail.ReadWrite, https://graph.microsoft.com/Mail.Send, https://graph.microsoft.com/Files.ReadWrite"```
    

    
>Die in diesem Projekt verwendeten Dienstaufrufe, also das Senden einer E-Mail an Ihr E-Mail-Konto, das Hochladen eines Bilds in OneDrive und das Abrufen einiger Profilinformationen (Anzeigename, E-Mail-Adresse. Profilbild), benötigen diese Berechtigungen, damit die App ordnungsgemäß ausgeführt wird.

5. Führen Sie das Beispiel aus. Sie werden aufgefordert, eine Verbindung zu einem geschäftlichen oder persönlichen E-Mail-Konto herzustellen oder zu authentifizieren. Dann können Sie eine E-Mail an dieses Konto oder an ein anderes ausgewähltes E-Mail-Konto senden.


## <a name="code-of-interest"></a>Interessanter Code

Der gesamte Authentifizierungscode kann in der Datei **AuthenticationProvider.m** angezeigt werden. Wir verwenden eine Beispielimplementierung von MSAuthenticationProvider, die über [NXOAuth2Client](https://github.com/nxtbgthng/OAuth2Client) hinaus erweitert wurde, um Anmeldeinformationen für registrierte systemeigene Apps, eine automatische Aktualisierung von Zugriffstoken sowie eine Abmeldefunktion bereitzustellen:

```objectivec

        [[NXOAuth2AuthenticationProvider sharedAuthProvider] loginWithViewController:nil completion:^(NSError *error) {
            if (!error) {
            [MSGraphClient setAuthenticationProvider:[NXOAuth2AuthenticationProvider sharedAuthProvider]];
            self.client = [MSGraphClient client];
             }
        }];
```

Nachdem der Authentifizierungsanbieter festgelegt wurde, können wir ein Clientobjekt (MSGraphClient) erstellen und initialisieren, das für Aufrufe des Microsoft Graph-Dienstendpunkts (E-Mail und Benutzer) verwendet wird. In **SendMailViewcontroller.swift** können wir das Benutzerprofilbild abrufen, dieses in OneDrive hochladen, eine E-Mail-Anforderung mit Bildanhang erstellen und diese mit dem folgenden Code senden:

### <a name="get-the-users-profile-picture"></a>Die URL des Profilbilds des Benutzers abrufen

```objectivec
[[[self.graphClient me] photoValue] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        //code
        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:location];
            UIImage *img = [[UIImage alloc] initWithData:data];
                            completionBlock(img, error);
        } 
    }];
```
### <a name="upload-the-picture-to-onedrive"></a>Hochladen des Bilds in OneDrive

```objectivec
    NSData *data = UIImagePNGRepresentation(image);
    [[[[[[[self.graphClient me]
          drive]
         root]
        children]
       driveItem:(@"me.png")]
      contentRequest]
     uploadFromData:(data) completion:^(MSGraphDriveItem *response, NSError *error) {
         
         if (!error) {
             NSString *webUrl = response.webUrl;
             completionBlock(webUrl, error);
         } 
    }];

```
### <a name="add-picture-attachment-to-a-new-email-message"></a>Hinzufügen einer Bildanhang zu einer neuen E-Mail-Nachricht

```objectivec
   MSGraphFileAttachment *fileAttachment= [[MSGraphFileAttachment alloc]init];
    fileAttachment.oDataType = @"#microsoft.graph.fileAttachment";
    fileAttachment.contentType = @"image/png";
    
    NSString *decodedString = [UIImagePNGRepresentation(self.userPicture) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    fileAttachment.contentBytes = decodedString;
    fileAttachment.name = @"me.png";
    message.attachments = [message.attachments arrayByAddingObject:(fileAttachment)];
```

### <a name="send-the-mail-message"></a>Senden der E-Mail-Nachricht

```objectivec
    MSGraphUserSendMailRequestBuilder *requestBuilder = [[self.client me]sendMailWithMessage:message saveToSentItems:true];    
    MSGraphUserSendMailRequest *mailRequest = [requestBuilder request];   
    [mailRequest executeWithCompletion:^(NSDictionary *response, NSError *error) {      
    }];
```

Weitere Informationen, einschließlich des Codes zum Aufrufen anderer Dienste wie OneDrive, finden Sie im [Microsoft Graph-SDK für iOS](https://github.com/microsoftgraph/msgraph-sdk-ios).

## <a name="questions-and-comments"></a>Fragen und Kommentare

Wir schätzen Ihr Feedback hinsichtlich des Office 365 iOS Microsoft Graph Connect-Projekts. Sie können uns Ihre Fragen und Vorschläge über den Abschnitt [Probleme](https://github.com/microsoftgraph/iOS-objectivec-connect-sample/issues) dieses Repositorys senden.

Allgemeine Fragen zur Office 365-Entwicklung sollten in [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API) gestellt werden. Stellen Sie sicher, dass Ihre Fragen oder Kommentare mit [Office365] und [MicrosoftGraph] markiert sind.

## <a name="contributing"></a>Mitwirkung
Vor dem Senden Ihrer Pull Request müssen Sie eine [Lizenzvereinbarung für Teilnehmer](https://cla.microsoft.com/) unterschreiben. Zum Vervollständigen der Lizenzvereinbarung für Teilnehmer (Contributor License Agreement, CLA) müssen Sie eine Anforderung über das Formular senden. Nachdem Sie die E-Mail mit dem Link zum Dokument empfangen haben, müssen Sie die CLA anschließend elektronisch signieren.

In diesem Projekt wurden die [Microsoft Open Source-Verhaltensregeln](https://opensource.microsoft.com/codeofconduct/) übernommen. Weitere Informationen finden Sie unter [Häufig gestellte Fragen zu Verhaltensregeln](https://opensource.microsoft.com/codeofconduct/faq/), oder richten Sie Ihre Fragen oder Kommentare an [opencode@microsoft.com](mailto:opencode@microsoft.com).

## <a name="additional-resources"></a>Zusätzliche Ressourcen

* [Office Dev Center](http://dev.office.com/)
* [Microsoft Graph-Übersichtsseite](https://graph.microsoft.io)
* [Verwenden von CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## <a name="copyright"></a>Copyright
Copyright (c) 2016 Microsoft. Alle Rechte vorbehalten.
