# devspace-curity-quickstart

This deploys a mysql database with the required schema as well as Curity <https://curity.io>

## Start

```console
devspace dev --namespace curity
```
1. Wait for port to become available.
2. Open a browser to <https://localhost:6749/admin/>
3. Use the passord `Passw0rd`
4. Configure and enjoy.

## Cleanup

```console
devspace purge
```

## Testing

### Admin UI

Admin Connection Details

| Field     | value                                                                                      |
| --------- | ------------------------------------------------------------------------------------------ |
| Admin URL | [https://admin.curity.7f000001.nip.io/admin/](https://admin.curity.7f000001.nip.io/admin/) |
| Username  | `admin`                                                                                    |
| Password  | `Passw0rd`                                                                                 |

### Run the Hypermedia Web Example

| Field     | value                                                                                                          |
| --------- | -------------------------------------------------------------------------------------------------------------- |
| Admin URL | [https://login.curity.7f000001.nip.io/demo-client.html](https://login.curity.7f000001.nip.io/demo-client.html) |
| Username  | `john.doe`                                                                                                     |
| Password  | `Password1`                                                                                                    |

### SCIM

```console
ACCESS_TOKEN=$(curl -s -X POST https://login.curity.7f000001.nip.io/oauth/v2/oauth-token \
-H 'content-type: application/x-www-form-urlencoded' \
-d 'grant_type=client_credentials' \
-d 'client_id=scim-client' \
-d 'client_secret=Passw0rd' \
-d 'scope=read' \
| jq -r '.access_token')
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://login.curity.7f000001.nip.io/user-management/admin/Users | jq
```
