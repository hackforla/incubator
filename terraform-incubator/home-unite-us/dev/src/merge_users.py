import json
import boto3

knownProviderNames = {
    'google': 'Google'
}

userClient = boto3.client('cognito-idp', region_name='us-west-2')

def getProviderName(userPoolId, providerName):
    print(userPoolId)
    if knownProviderNames[providerName]:
        return knownProviderNames[providerName]
    
    providers = userClient.list_identity_providers(
        UserPoolId=userPoolId
    )
    
    for provider in providers:
        if provider.ProviderName.lower() == providerName.lower():
            return provider.ProviderName

def lambda_handler(event, context):
    # define variables
    clientId = event['callerContext']['clientId']
    userPoolId = event['userPoolId']
    email = event['request']['userAttributes']['email']
    providerValues = event['userName'].split('_')
    print('providerValues', providerValues)
    
    # check if user is from a provider
    if len(providerValues) > 1:
        # list all existing users with email
        users = userClient.list_users(
            UserPoolId=userPoolId,
            AttributesToGet=['email'],
            Filter=f'email= "{email}"'
        )

        # get name from list of accepted providers
        providerName = getProviderName(userPoolId, providerValues[0])
        print('providerName', providerName)
        
        # if cognito user exists and it is an accepted provider merge users
        if len(users) > 0 and providerName:
            for user in users['Users']:
                userClient.admin_link_provider_for_user(
                    UserPoolId=userPoolId,
                    DestinationUser={
                        'ProviderName': 'Cognito',
                        'ProviderAttributeValue': user['Username']
                    },
                    SourceUser={
                        'ProviderName': providerName,
                        'ProviderAttributeName': 'Cognito_Subject',
                        'ProviderAttributeValue': providerValues[1]
                    }
                )

            return event
                
    else:
        return event
        