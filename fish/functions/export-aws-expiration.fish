function export-aws-expiration
    set saml2aws_cmd (which saml2aws)
    eval ($saml2aws_cmd script --shell=fish 2> /dev/null | grep EXPIRATION)
    set -gx AWS_SESSION_EXPIRATION $AWS_CREDENTIAL_EXPIRATION
end
