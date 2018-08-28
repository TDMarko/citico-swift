# citico-swift

Demo Notes application written in Swift for C.T.Co

[![citico2.jpg](https://s8.postimg.cc/bq12gms8l/citico2.jpg)](https://postimg.cc/image/bd9oag9yp/)

TODO:
1) - [x] Remove unused cells from table
2) - [x] Add date to cell
3) - [x] Allow to edit note
4) - [x] Delete only one note
5) - [x] Add popups with messages "Note has been added" and "Note has been deleted"
6) - [x] Add check for non-empty input before note save
7) - [ ] Add sorting

BUGS:
1) - [x] Delete note deletes all notes in Core Data storage
2) - [ ] Sometimes in Table View wrong cell is greyed out
3) - [x] Table View needs an update after note delete (probably stays in operating memory)
4) - [ ] After update cell is not in right place, add sorting

TASK:
Note taking application

Application should give a user ability to create/edit/delete notes.

We leave in the world where people are concerned about their privacy, so notes have to have a “private” note function - “private note” requires some sort of unlocking (password, pattern, biometric and etc). Additionally different kind of notes (auxiliary features) can be created/used - taking pictures, importing reference files/links, scanning documents (how about OCR?), recording audio notes. What we are looking is approach to thought process when developing such an application and how it plays with respective platform. Application should also be forward and backward thinking to support both latest and one before version of OS it is running on.
