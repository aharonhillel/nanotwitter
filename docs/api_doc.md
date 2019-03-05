# nanoTwitter
NanoTwitter for Brandeis University's Scalability taught by Pito Salas


## Version: 1.0.0

### Terms of service
http://swagger.io/terms/

**Contact information:**  
apiteam@swagger.io  

**License:** [Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)

[Find out more about Swagger](http://swagger.io)
### Security
**petstore_auth**  

|oauth2|*OAuth 2.0*|
|---|---|
|Authorization URL|http://petstore.swagger.io/oauth/dialog|
|Flow|implicit|
|**Scopes**||
|write:pets|modify pets in your account|
|read:pets|read your pets|

**api_key**  

|apiKey|*API Key*|
|---|---|
|Name|api_key|
|In|header|

### /users/new

#### POST
##### Summary:

Add a new user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| User | body | New user to add | No | [User](#user) |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |
| 403 | Failed to create user |

### /users/{username}

#### GET
##### Summary:

Finds user by username

##### Description:

Finds user by username

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| username | path | username of the user to be found | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [User](#user) |
| 400 | Invalid username value |  |

#### PUT
##### Summary:

Update an existing user information

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| username | path | username of the user to be found | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |
| 404 | User not found |
| 405 | Validation exception |

### /{username}/tweets

#### GET
##### Summary:

Display current user's tweets

##### Description:

Returns a list of a user's tweets

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| username | path | username of a user for their tweets | Yes | string (int64) |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [ [Tweet](#tweet) ] |
| 400 | Invalid user supplied |  |
| 404 | user not found |  |

##### Security

| Security Schema | Scopes |
| --- | --- |
| api_key | |

### /tweets/recent

#### GET
##### Summary:

Returns the most recent 50 tweets

##### Description:

Returns a list of most recent updated tweets

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [ [Tweet](#tweet) ] |

### /tweets/following

#### GET
##### Summary:

Returns tweets from users followed by current user

##### Description:

Returns a list of  tweets from users followed by current user

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | successful operation |

### /tweets/new

#### POST
##### Summary:

Create a new tweet

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| Tweet | body | New user to add | No | [Tweet](#tweet) |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | successful operation |
| 400 | Invalid Tweet |

### /tweets/{tweetId}

#### GET
##### Summary:

Find tweets by ID

##### Description:

For valid response try integer IDs. Non-existent ID will generate exceptions.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweetId | path | ID of tweet that needs to be fetched | Yes | long |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [Tweet](#tweet) |
| 400 | Invalid ID supplied |  |
| 404 | Tweet not found |  |

#### DELETE
##### Summary:

Delete tweet by ID

##### Description:

delete tweet

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweetId | path | ID of the tweet that needs to be deleted | Yes | long |

##### Responses

| Code | Description |
| ---- | ----------- |
| 400 | Invalid ID supplied |
| 404 | Tweet not found |

### /tweets/trending/{hash_tag}

#### GET
##### Summary:

Find tweets by hash_tag

##### Description:

For valid response try integer hash_tag ID.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| hash_tag | path | ID of hash_tag on tweets that needs to be fetched | Yes | long |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [ [Tweet](#tweet) ] |
| 400 | Invalid ID supplied |  |
| 404 | Tweet not found |  |

### /comments/{tweet_id}/new

#### POST
##### Summary:

Create a new comment for a tweet

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweet_id | path | ID of tweet to be commented | Yes | long |
| Comment | body | New comment to add | No | [Comment](#comment) |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | successful operation |
| 400 | Invalid tweet_id |

### /comments/{tweet_id}

#### GET
##### Summary:

All comments for a specific tweet

##### Description:

Return a list of all comments for a specific tweet

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweet_id | path | id for a specific tweet | Yes | long |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [ [Comment](#comment) ] |
| 400 | Invalid tweet_id supplied |  |
| 404 | tweet_id not found |  |

### /mentions/{tweet_id}/new

#### POST
##### Summary:

Create a tweet mentioning a/many users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweet_id | path | ID of tweet to be commented | Yes | long |
| Mention | body | New mention to add | No | [Mention](#mention) |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | successful operation |
| 400 | Invalid tweet_id |

### /signup

#### GET
##### Summary:

Show the user creation page

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

### /{tweet_id}/like

#### GET
##### Summary:

Number of likes for a specific tweet

##### Description:

Recieve an integer with the number of likes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweet_id | path | id for a specific tweet | Yes | long |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | successful operation |
| 400 | Invalid tweet_id supplied |
| 404 | tweet_id not found |

#### POST
##### Summary:

Add new like for specific tweet by a specific user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweet_id | path | User id and tweet id | Yes | long |
| Like | body | New like to add | No | [Like](#like) |

##### Responses

| Code | Description |
| ---- | ----------- |
| default | successful operation |

#### DELETE
##### Summary:

Delete like for a tweet by a user

##### Description:

Unlike a tweet that a user liked

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tweet_id | path | Delete like by a user on a tweet | Yes | long |

##### Responses

| Code | Description |
| ---- | ----------- |
| 400 | Invalid User supplied or invalid tweet ID |
| 404 | Like was not found |

### /follows/{user_id}/{followed_id}

#### POST
##### Summary:

Add new follow relationship between two users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_id | path | User id who follows | Yes | long |
| followed_id | path | User id who is followed | Yes | long |
| Follow | body | New follow relationship to add | No | [Follow](#follow) |

##### Responses

| Code | Description |
| ---- | ----------- |
| default | successful operation |

#### DELETE
##### Summary:

Delete follow relationship between two users

##### Description:

Unfollow a user who was followed

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_id | path | User id who follows | Yes | long |
| followed_id | path | User id who is followed | Yes | long |

##### Responses

| Code | Description |
| ---- | ----------- |
| 400 | Invalid User supplied |
| 404 | Follow was not found |

### /{user_id}/following/users

#### GET
##### Summary:

User being followed by current user

##### Description:

Return a list of users followed by current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_id | path | id for current user | Yes | long |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [ [User](#user) ] |
| 400 | Invalid user_id supplied |  |
| 404 | user_id not found |  |

### /{user_id}/followed/users

#### GET
##### Summary:

Users who are following current user

##### Description:

Return a list of users follow current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_id | path | id for current user | Yes | long |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | successful operation | [ [User](#user) ] |
| 400 | Invalid user_id supplied |  |
| 404 | user_id not found |  |

### /notifications/{username}

#### GET
##### Summary:

Show all notifications

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| username | path | username of the user | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | OK | [AllNotifications](#allnotifications) |
| 404 | User not found | [NoUserNotifications](#nousernotifications) |

### /hash_tags/new

#### POST
##### Summary:

Create a new hash_tags

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| HashTag | body | New hashtag to add | No | [HashTag](#hashtag) |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | successful operation |

### /search/{keyword}

#### GET
##### Summary:

Show all search result of keyword

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| keyword | path | keyword to be searched | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | OK | [Search](#search) |
| 404 | no result of such keyword |  |

### Models


#### User

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | number |  | No |
| name | string |  | No |
| email | string |  | No |
| password | string |  | No |

#### Tweet

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| tweet_id | number |  | No |
| user_id | number |  | No |
| content | string |  | No |

#### Comment

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| comment_id | integer |  | No |
| tweet_id | integer |  | No |
| user_id | integer |  | No |
| content | string |  | No |

#### Follow

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | number |  | No |
| follower_id | number |  | No |
| followed_id | number |  | No |

#### NoUserNotifications

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| username | string |  | No |
| success | boolean |  | No |

#### AllNotifications

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| username | string |  | No |
| total | long |  | No |
| success | boolean |  | No |
| notifications | [ object ] |  | No |

#### Search

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| keyword | string |  | No |
| total | long |  | No |
| success | boolean |  | No |
| results | [ object ] |  | No |

#### HashTag

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | number |  | No |
| content | string |  | No |

#### Like

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | number |  | No |
| tweet_id | number |  | No |
| user_id | number |  | No |

#### Mention

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | number |  | No |
| tweet_id | number |  | No |
| user_id | number |  | No |