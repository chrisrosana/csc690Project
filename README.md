# csc690Project

# JamSesh

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Build Progress](#Build-Progress)
1. [Wireframes](#Wireframes)
1. [Schema](#Schema)

## Overview
### Description
JamSesh is a music app where you can create music sessions from your playlists. These music sessions can be a a space for you to listen music with friends or meet new people with similar music interests. 

### App Evaluation
- **Category:** Social Networking / Music
- **Mobile:** This app would be developed for mobile, but it could potentially work as effectively on computers.
- **Story:** This app would allow people to listen to music as well as connect and socialize with other people who have similar music interests through music sessions. The user can create music session or join other music session and chat with fellow users within that session.
- **Market:** Anyone who loves music can enjoy this app. Ability to follow other users allow a user to discover new songs and interact with other users by joining their session.
- **Habit:** Users can listen to music anytime they want. The feature “Music Sessions” could also encourage users to use this app more often as it allows them to chat with their friends and listen to the same music at the same time.
- **Scope:** At the moment, JamSesh is simply for listening to music and chatting with the people the user is following. Perhaps, it could eventually allow users to view popular music sessions based on location. 

## Product Spec
### 1. User Stories (Required and Optional)

**Required Must-have Stories**
- [x] User can sign up 
- [x] User can log in
- [x] User sees app icon in home screen and styled launch screen.
- [x] User stays logged in across restarts
- [x] User can view their profile
- [x] User can edit their account information
- [x] User can follow/unfollow another user
- [x] User can search songs and add to their playlist
- [x] User can remove songs from their playlist
- [x] User can create a private/public music session
- [x] User can join a private/public music session 
- [x] User can chat with other users in a music session
- [x] User can search an account or music session
- [x] User can play a song
- [x] User can create a playlist
- [x] User can delete a playlist


**Optional Nice-to-have Stories**
- [ ] User can view the lyrics of a song
- [ ] User can customize their app user interface
- [ ] User can use automated voice controls (Houndify)
- [ ] User can be notified when the people they follow creates a music session
- [ ] User can be notified if they have been invited to another user’s music session
- [ ] User can share through social media 

### 2. Screen Archetypes
* Login 
   * User can login
* Register - User signs up or logs into their account
   * User can create a new account
* Messaging Screen 
   * Upon joining a music session, message section becomes available
* Profile Screen 
   * User can view their identity and stats
* Song Selection Screen.
   * Allows user to be able to choose a playlist to be played in the music session.
* Search Screen
   * User can search for other users
   * User can search a song
* Sessions List Screen (Stream)
   * User can view a list of music sessions
* Create Music Session Screen (Creation)
   * User can create a music session
* Detail
   * User can view the lyrics of a song
* Media Player
   * Allowing the control of media playback
* Settings Screen
   * Lets people change chat user interface, and app notification settings.

### 3. Navigation

**Tab Navigation** (Tab to Screen)
* Sessions List
* Search User & Song
* Profile & Library
* Settings

**Flow Navigation** (Screen to Screen)
* Log-in Screen -> Sessions List Screen
* Registration Screen -> Sessions List Screen
* Create Music Session Screen -> Music Session
* Sessions List Screen -> Music Session
* Settings -> Toggle settings

## Wireframes
<img src='https://user-images.githubusercontent.com/47466831/57339262-c7989c80-70e5-11e9-9e5e-227cb187c3a1.JPG' title='Wireframes' width='' alt='Wireframes' />


### Digital Wireframes & Mockups
<img src='https://user-images.githubusercontent.com/47466831/57339413-5a393b80-70e6-11e9-9fa3-a88c21a9d94c.JPG' title='Digital Wireframes' width='' alt='Digital Wireframes' />

## Schema 
### Models

#### User
| Property      | Type     | Description |
| ------------- | -------- | ------------|
| objectId      | String   | unique id for the user (default field) |
| username      | String   | username for the user |
| password      | String   | password for the user |
| image         | File     | image for the user |
| playlists     | Array of pointers to playlists  | all the playlists the user created |
| followers     | Array of pointers to users | other users that follow the user |
| following     | Array of pointers to users  | other users that the user follows |
| followersCount     | Number | number of other users that follow the user |
| followingCount     | Number  | number of other users that the user follows |



#### MusicSession
| Property      | Type     | Description |
| ------------- | -------- | ------------|
| objectId      | String   | unique id for the user's music session (default field) |
| author        | Pointer to user | user that created the music session |
| users         | Array of pointers to users    | other users that joined the music sessions
| playlist      | Pointer to playlist    | the playslist that contains the songs used a session |
| messages      | Pointer to messages   | conversations in the music session |
| createdAt     | DateTime | date when Music Session is created (default field) |

#### Messages
| Property      | Type     | Description |
| ------------- | -------- | ------------|
| objectId      | String   | unique id for the user's message (default field) |
| musicSession  | pointer to music session | the session where the message was created in |
| message       | String   | message a user created within a music session |
| author          | Pointer to user | user that wrote the message in the music session |

#### Playlists
| Property      | Type     | Description |
| ------------- | -------- | ------------|
| objectId      | String   | unique id for the user's album (default field) |
| author        | Pointer to user   | user that created the playlist |
| songs         | Array of pointers to songs  | list of songs in the album  |
| playlistName     | String   | name of the playlist |

#### Songs
| Property      | Type     | Description |
| ------------- | -------- | ------------|
| objectId      | String   | unique id for a song (default field) |
| song          | File     | song file       |
| songName      | String   | name of the song |
| timeLength    | Number   | time length of the song |



### Networking
#### List of network requests by screen
- Sessions List Screen
- (Read/GET) Query all music sessions
```swift
let query = PFQuery(className:"MusicSession")
query.includeKey("author")
query.order(byDescending: "createdAt")
query.findObjectsInBackground { (sessions: [PFObject]?, error: Error?) in
if let error = error { 
print(error.localizedDescription)
} else if let sessions = sessions {
print("Successfully retrieved \(sessions.count) sessions.")
// TODO: Do something with sessions...
}
}
```

- Create Music Session Screen <br>
      - (Create/POST) Create a new music session object <br>
- Search Screen <br>
      - (Read/Get) Search to get song/session object <br>
- Profile Screen <br>
      - (Read/GET) Query logged in user object <br>
      - (Update/PUT) Update user profile image <br>
      - (Read/GET) Get Query in music session object <br>
- Music Session Screen <br>
      - (Read/GET) Query chosen music session object <br>
      - (Read/GET) Get Playlist in music session object <br>
      - (Create/POST) Create a new message object <br>
      - (Read/Get) Get message object <br>
- Settings Screen <br>
      - (Read/GET) Query logged in user object <br>
      - (Update/PUT) Update user object <br>
