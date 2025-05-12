from http import HTTPStatus


def lambda_handler(event, context):
    return {
        "statusCode": HTTPStatus.OK.value,
        "body": 'Hello, world!'
    }