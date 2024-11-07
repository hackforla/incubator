module.exports.handler = async (event) => {
    if (event.triggerSource === 'CustomMessage_SignUp' || event.triggerSource === 'CustomMessage_ResendCode') {
        const codeParameter = event.request.codeParameter;
        const username = event.userName;
        const region = event.region;
        const email = event.request.userAttributes.email;
        const url = `${event.request.clientMetadata.url}/api/auth/signup/confirm`;
        const body = `
            <div>
                <h1 style="margin: 0;  font-size: 24px;">Please verify your account.</h1>
                <div style="height: 24px;" />
                <p style="margin: 0;">
                    Thank you for signing up for an account. We’re excited to have you get started!
                    Click on the link below to verify your account.
                </p>
                <div style="height: 24px;" />
                <div style="display: flex; justify-content: center; align-items: center; width: 100%">
                    <a style="text-decoration: none; display: block; font-size: 16px; color: #fff; background-color: #0057A1; padding: 12px 24px; border-radius: 8px;"
                    href="${url}?code=${codeParameter}&email=${email}"
                    target="_blank">
                    Verify Account
                    </a>
                </div>
                <div style="height: 24px;" />
                <p style="margin: 0; ">
                    If you did not sign up for this account please ignore this email.
                </p>
            </div>`;

        event.response.emailSubject = "Your verification link";
        event.response.emailMessage = body;
        return event;
    }
    
    if(event.triggerSource === "CustomMessage_AdminCreateUser") {
        const codeParameter = event.request.codeParameter;
        const username = event.request.usernameParameter;

        const url = `${event.request.clientMetadata.url}/api/auth/confirm-invite`;

        const body = `
            <div>
                <h1 style="margin: 0;  font-size: 24px;">You're invited!</h1>
                <div style="height: 24px;" />
                <p style="margin: 0;">
                    Thank you for signing up for Home Unite Us. We’re excited to have you get started!
                    Click the link below to 
                </p>
                <div style="height: 24px;" />
                <div style="display: flex; justify-content: center; align-items: center; width: 100%">
                    <a style="text-decoration: none; display: block; font-size: 16px; color: #fff; background-color: #0057A1; padding: 12px 24px; border-radius: 8px;"
                    href="${url}?password=${codeParameter}&email=${username}"
                    target="_blank">
                    Accept Invite
                    </a>
                </div>
                <div style="height: 24px;" />
                <p style="margin: 0; ">
                    If you did not sign up for this account please ignore this email.
                </p>
            </div>`;

        event.response.emailSubject = "Your HUU invite";
        event.response.emailMessage = body;
        console.log(event.response);
        return event;
    }

    return event;
};

