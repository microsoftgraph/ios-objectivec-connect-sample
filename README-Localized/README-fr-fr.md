# <a name="office-365-connect-sample-for-ios-using-the-microsoft-graph-sdk"></a>Exemple de connexion d’Office 365 pour iOS avec le kit de développement logiciel Microsoft Graph

Microsoft Graph est un point de terminaison unifié pour accéder aux données, aux relations et aux connaissances fournies à partir du cloud Microsoft. Cet exemple montre comment se connecter et s’authentifier, puis appeler les API de messagerie et utilisateur via le [kit de développement logiciel Microsoft Graph pour iOS](https://github.com/microsoftgraph/msgraph-sdk-ios).

> Remarque : Consultez la page relative au [portail d’inscription de l’application Microsoft Graph](https://apps.dev.microsoft.com) pour enregistrer plus facilement votre application et exécuter plus rapidement cet exemple.

## <a name="prerequisites"></a>Conditions préalables
* Téléchargement de [Xcode](https://developer.apple.com/xcode/downloads/) d’Apple.

* Installation de [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) comme gestionnaire de dépendances.
* Un compte de messagerie professionnel ou personnel Microsoft comme Office 365 ou outlook.com, hotmail.com, etc. Vous pouvez vous inscrire à [Office 365 Developer](https://aka.ms/devprogramsignup) pour accéder aux ressources dont vous avez besoin afin de commencer à créer des applications Office 365.

     > Remarque : Si vous avez déjà un abonnement, le lien précédent vous renvoie vers une page avec le message suivant : *Désolé, vous ne pouvez pas ajouter ceci à votre compte existant*. Dans ce cas, utilisez un compte lié à votre abonnement Office 365 existant.    
* Un ID client de l’application enregistrée auprès du [portail d’inscription de l’application Microsoft Graph](https://apps.dev.microsoft.com)
* Pour effectuer des requêtes, vous devez fournir un élément **MSAuthenticationProvider** capable d’authentifier les requêtes HTTPS avec un jeton de support OAuth 2.0 approprié. Nous allons utiliser [msgraph-sdk-ios-nxoauth2-adapter](https://github.com/microsoftgraph/msgraph-sdk-ios-nxoauth2-adapter) pour un exemple d’implémentation de MSAuthenticationProvider qui peut être utilisé pour commencer rapidement votre projet. Voir la section **Code d’intérêt** ci-dessous pour plus d’informations.


## <a name="running-this-sample-in-xcode"></a>Exécution de cet exemple dans Xcode

1. Cloner ce référentiel
2. S’il n’est pas déjà installé, exécutez les commandes suivantes à partir de l’application **Terminal** à installer et configurez le gestionnaire de dépendances CocoaPods.

        sudo gem install cocoapods
    
        pod setup

2. Utilisez CocoaPods pour importer les dépendances d’authentification et le kit de développement logiciel Microsoft Graph :

        pod 'MSGraphSDK'
        pod 'MSGraphSDK-NXOAuth2Adapter'


 Cet exemple d’application contient déjà un podfile qui recevra les pods dans le projet. Accédez à la racine du projet où se trouve le podfile et, à partir de **Terminal**, exécutez la commande suivante :

        pod install

   Pour plus d’informations, consultez la ressource **Utilisation de CocoaPods** dans [Ressources supplémentaires](#AdditionalResources).

3. Ouverture de **ios-objectivec-sample.xcworkspace**
4. Ouvrez **AuthenticationConstants.m**. Vous verrez que l’**ID client** du processus d’inscription peut être ajouté à la partie supérieure du fichier :

   ```objectivec
        // You will set your application's clientId
        NSString * const kClientId    = @"ENTER_YOUR_CLIENT_ID";
   ```


    Notez que les étendues d’autorisation suivantes ont été configurées pour ce projet : 

```@"https://graph.microsoft.com/User.Read, https://graph.microsoft.com/Mail.ReadWrite, https://graph.microsoft.com/Mail.Send, https://graph.microsoft.com/Files.ReadWrite"```
    

    
>Remarque : les appels de service utilisés dans ce projet, l’envoi d’un courrier électronique à votre compte de messagerie, le chargement d’une image vers OneDrive et la récupération des informations de profil (nom d’affichage, adresse e-mail, photo de profil) ont besoin de ces autorisations pour que l’application s’exécute correctement.

5. Exécutez l’exemple. Vous êtes invité à vous connecter/authentifier à un compte de messagerie personnel ou professionnel, puis vous pouvez envoyer un message à ce compte ou à un autre compte de messagerie sélectionné.


## <a name="code-of-interest"></a>Code d’intérêt

Tout le code d’authentification peut être affiché dans le fichier **AuthenticationProvider.m**. Nous utilisons un exemple d’implémentation de MSAuthenticationProvider étendu de [NXOAuth2Client](https://github.com/nxtbgthng/OAuth2Client) pour prendre en charge la connexion des applications natives inscrites, l’actualisation automatique des jetons d’accès et la fonctionnalité de déconnexion :

```objectivec

        [[NXOAuth2AuthenticationProvider sharedAuthProvider] loginWithViewController:nil completion:^(NSError *error) {
            if (!error) {
            [MSGraphClient setAuthenticationProvider:[NXOAuth2AuthenticationProvider sharedAuthProvider]];
            self.client = [MSGraphClient client];
             }
        }];
```

Une fois le fournisseur d’authentification défini, nous pouvons créer et initialiser un objet client (MSGraphClient) qui sert à effectuer des appels auprès du point de terminaison du service Microsoft Graph (courrier et utilisateurs). Dans **SendMailViewcontroller.m**, nous pouvons obtenir la photo de profil de l’utilisateur, la charger vers OneDrive, assembler une demande de messagerie avec une image en pièce jointe et l’envoyer en utilisant le code suivant :

### <a name="get-the-users-profile-picture"></a>Obtention de l’image de profil de l’utilisateur

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
### <a name="upload-the-picture-to-onedrive"></a>Chargement de l’image vers OneDrive

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
### <a name="add-picture-attachment-to-a-new-email-message"></a>Ajout d’une image en pièce jointe à un nouveau message électronique

```objectivec
   MSGraphFileAttachment *fileAttachment= [[MSGraphFileAttachment alloc]init];
    fileAttachment.oDataType = @"#microsoft.graph.fileAttachment";
    fileAttachment.contentType = @"image/png";
    
    NSString *decodedString = [UIImagePNGRepresentation(self.userPicture) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    fileAttachment.contentBytes = decodedString;
    fileAttachment.name = @"me.png";
    message.attachments = [message.attachments arrayByAddingObject:(fileAttachment)];
```

### <a name="send-the-mail-message"></a>Envoi du message électronique

```objectivec
    MSGraphUserSendMailRequestBuilder *requestBuilder = [[self.client me]sendMailWithMessage:message saveToSentItems:true];    
    MSGraphUserSendMailRequest *mailRequest = [requestBuilder request];   
    [mailRequest executeWithCompletion:^(NSDictionary *response, NSError *error) {      
    }];
```

Pour plus d’informations, y compris le code d’appel à d’autres services, tels que OneDrive, reportez-vous à la section [Kit de développement logiciel Microsoft Graph pour iOS](https://github.com/microsoftgraph/msgraph-sdk-ios).

## <a name="questions-and-comments"></a>Questions et commentaires

Nous serions ravis de connaître votre opinion sur le projet de connexion d’iOS à Office 365 avec Microsoft Graph. Vous pouvez nous faire part de vos questions et suggestions dans la rubrique [Problèmes](https://github.com/microsoftgraph/iOS-objectivec-connect-sample/issues) de ce référentiel.

Si vous avez des questions sur le développement d’Office 365, envoyez-les sur [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Veillez à poser vos questions ou à rédiger vos commentaires avec les tags [MicrosoftGraph] et [Office 365].

## <a name="contributing"></a>Contribution
Vous devrez signer un [Contrat de licence de contributeur](https://cla.microsoft.com/) avant d’envoyer votre requête de tirage. Pour compléter le contrat de licence de contributeur (CLA), vous devez envoyer une requête en remplissant le formulaire, puis signer électroniquement le CLA quand vous recevrez le courrier électronique contenant le lien vers le document.

Ce projet a adopté le [code de conduite Microsoft Open Source](https://opensource.microsoft.com/codeofconduct/). Pour plus d’informations, reportez-vous à la [FAQ relative au code de conduite](https://opensource.microsoft.com/codeofconduct/faq/) ou contactez [opencode@microsoft.com](mailto:opencode@microsoft.com) pour toute question ou tout commentaire.

## <a name="additional-resources"></a>Ressources supplémentaires

* [Centre de développement Office](http://dev.office.com/)
* [Page de présentation de Microsoft Graph](https://graph.microsoft.io)
* [Utilisation de CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## <a name="copyright"></a>Copyright
Copyright (c) 2016 Microsoft. Tous droits réservés.
