# Brazilian Jiu Jitsu Competitions Finder App

Dear reader, 
 thank you for visiting my project repository. This app is designed to display upcoming Jiu Jitsu tournaments.
Enjoy!

 ![](https://github.com/essentialdevelopercom/essential-feed-case-study/workflows/CI-iOS/badge.svg) ![](https://github.com/essentialdevelopercom/essential-feed-case-study/workflows/CI-macOS/badge.svg) ![](https://github.com/essentialdevelopercom/essential-feed-case-study/workflows/Deploy/badge.svg)
  
### Feature Specs
- Display a list of competitive events
- Persist (store) the list of competitive events



---
 
### Scenario 1: Display a list of competitive events
 
```
As a Jiu Jitsu enthusiast (practitioner or supporter)
I want the app to display a list of upcoming competitions
So I can easily explore competitive events
```

#### Acceptance criteria
```
Given the user has internet connectivity
 When the user requests to view upcoming competitions
  Then the app should fetch and display competitions from the server
   And update the cache with the latest competitions
```

### Scenario 2: Persist the list of competitive events
 
```
As an offline user
I want the app to display the most recently saved competitions
So I can explore competitive events
```

#### Acceptance criteria
```
Given the user doesn't have internet connectivity
 And there is a cached version of the feed
  When the user requests to see the list of competitions
   Then the app should display the most recently saved competitions

Given the user doesn't have internet connectivity
 And the cache is empty
  When the user requests to see the list of competitions
   Then the app should display an error message
```
