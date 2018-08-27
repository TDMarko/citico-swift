# citico-swift

Demo Notes application written in Swift for C.T.Co

[![citico2.jpg](https://s8.postimg.cc/bq12gms8l/citico2.jpg)](https://postimg.cc/image/bd9oag9yp/)

TODO:
1) Remove unused cells from table
2) Add date to cell and allow to change sorting
3) Allow to edit note
4) Delete only one note
5) Add popups with messages "Note has been added" and "Note has been deleted"
6) Add check for non-empty input before note save

BUGS:
1) Delete note deletes all notes in Core Data storage
2) Sometimes in Table View wrong cell is greyed out
3) Table View needs an update after note delete (probably stays in operating memory)
