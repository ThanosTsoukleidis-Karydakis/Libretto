# Libretto

Libretto is a Flutter Mobile Application that helps musicians plan their concerts/rehearsals, contact their bandmates and store their music scores. The application also includes:  
- Voice commands through the use of the phone's microphone
- OCR technology (Optical Character Recognition): The user can take a photo of the title of a musical piece and he will be redirected to its musical score (if he has it saved in his Songs archive).
- Gamification: A circular progress bar that gets fuller each time the user plans a new concert or rehearsal. The user earns "musical notes" every time he completes a progress cycle. A virtual character encourages him to work more and rewards him when he completes a cycle of the progress bar.  
- Haptics: The phone vibrates (as a warning) every time a user tries to delete something.
- Different orientations every time the user flips his device.
- Reorderable lists: All lists can be reordered by long tapping and dragging list tiles up and down.  

### Possible voice commands: 

- "Open ---Title of a song---" : Opens the music score of the specified song.
- "Songs" : Navigates the user to the Songs screen.
- "Add Event" : Navigates the user to the Add Event screen.
- "Contacts" : Navigates the user to the Contacts screen.
- "Show My Progress" : Navigates the user to the Achievements screen.
- "Delete Checked" : Deletes the checked events.
- "Sort" : Sorts the events by date.
- "Delete All" : Deletes all events.  

## Collaborators  
- [Athanasios Tsoukleidis-Karydakis](https://github.com/ThanosTsoukleidis-Karydakis)  (el19009)
- [Dimitrios-David Gerokonstantis](https://github.com/DimitrisDavidGerokonstantis)  (el19209)

## Final Result - All screens and actions of the mobile application  
The final application consists of the following pages. Each page is presented alongside its special features:  

- **Home Page:**

Main Page             |  Delete All Events |  Delete Checked Events |  Map Icon - GPS
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
The main page of the application. Also contains the microphone fot giving voice commands and the camera for using the OCR technology | Deletes all events in the list | Deletes only the events the user has ticked | It navigates the user to his phone's Google Maps GPS app and shows him a route to the specified location of the event
![Main page](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/cdc5c952-d2b1-421d-81bb-1c07645051a1)  |  ![Main page-delete all events](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/d084826d-8aa9-40f2-9b0e-53d0296f7cfd) | ![Main page-delete checked events](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/f3217154-79c9-4c33-8698-61c0dd6bbbe9) | ![Main Page-Map icon](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/d2bdc30a-b331-4c04-9c52-4b7bc37c96c0)

- **Contacts Page:**

Contacts Page             |  Phone Icon 
:-------------------------:|:-------------------------:
The contacts page of the application | By pressing the phone icon the user is navigated to his phone application with the musician's number pre-dialed for him
![Contacts](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/5c3ebf5d-5053-4098-a090-998f022d1ed8) | ![Contacts-phone icon](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/841a5000-90da-4a2b-a8af-5bb4fe502fea)

- **Songs Page:**

Songs Page             |  File Icon 
:-------------------------:|:-------------------------:
The songs page of the application | By pressing it, the music score of a particular song saved in pdf format is opened
![Songs](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/5aca8769-4585-4645-97d8-ce4dad84d296) | ![Songs-file icon](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/0a675c59-deab-4384-a1bf-7d885b4b0865)

- **My Progress Page:**

My Progress Page - Not full progress cycle             |  My Progress page - Completed one progress cycle
:-------------------------:|:-------------------------:
The user hasn't yet completed his first progress cycle - the virtual character is sad :( | The user has completed his first progress cycle - the virtual character rewards him with 1 note and smile :)
![Gamification-sad face](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/665c6138-af85-4e04-927d-27e3abb87034) | ![Gamification-happy face](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/7ed7a31a-0fc4-41f7-b763-93f644b981a6)

- **OCR technology - enabled by pressing the camera button in the home page:**

OCR Main page            |  OCR - Found a match
:-------------------------:|:-------------------------:
Prompts the user to take a photo of some text and tries to understand what is written in the photograph | Finds a match with a song in the Songs archive of the user and opens the corresponding music score
![OCR](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/667f8117-e708-4556-8da2-0fae2ab44815) | ![OCR- open file](https://github.com/ThanosTsoukleidis-Karydakis/Libretto-MobileApp/assets/106911775/a4e5bed0-62d6-4c1e-ae75-60bd78a46b06)
