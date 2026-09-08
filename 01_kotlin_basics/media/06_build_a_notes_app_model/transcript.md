# Build a Notes App Model — transcript

## Visual description

A BHCC opening introduces the cumulative notes model. A diagram connects note data, store operations and independent tests. A notes-app scenario supplies ID one and the title Lab ideas, with a unique-ID caller rule and in-memory storage limit. The video then shows a real Workspace with only demo.kts in Explorer. The camera follows actual typing, then widens for the native Run Code button and its Output panel. The program prints two lines. Narration ends with a reminder-store transfer prompt.

## Narration

Welcome to CSC-244. You’ll combine the Kotlin you already know into a small notes app model. We’ll add, find, update, and remove notes, then trace the complete sequence. This cumulative example introduces no new Kotlin syntax.

Keeping data rules in one small class makes them easier to test before building Android screens. A screen can request an operation without managing the collection itself. We’ll focus on how familiar pieces work together.

Imagine you’re building the data-handling part of a notes app. Each note has an integer ID and a text title. Our sample begins with ID one and the title Lab ideas. The caller must supply unique IDs; this small store does not check for duplicates.

The store should find a note or report that it is missing. Updating or removing a missing ID should do nothing. Updating keeps the ID while changing the title. All data lives in memory during this run; there is no database or persistent storage.

Let’s open demo.kts. The standard Run Code button will execute the complete script with the installed Kotlin compiler.

Start with the data class and a store that owns an empty mutable list of notes. The note properties use val, so changing a title will mean creating a replacement note.

Private keeps the list inside NoteStore. Its val binding stays attached to the same list, while the mutable list permits adding and removing elements. The explicit Note element type tells Kotlin what this initially empty list will contain.

Now provide the two simplest operations. Add appends a supplied note. Find searches for the requested ID and returns a nullable Note, because that ID might not exist.

Inside the search lambda, it is the current note. Comparing its ID with the parameter selects the first match. No match produces null. Add does not enforce unique IDs, so callers must honor that precondition for ID-based operations to be unambiguous.

Removal can reuse that search instead of repeating it. Find the note, check the nullable result, and remove the actual object only when it exists.

The null check makes note safe to use inside the branch. When the ID is absent, the branch is skipped and the list stays unchanged. Other records remain because we remove the one note found for this ID.

Updating follows the same find-and-check structure. For an existing note, remove the old object and append a copy with the requested title. Let’s add that operation and close the store class.

Copy creates the replacement while retaining the omitted ID property. The original note’s val title is not reassigned. If the ID is missing, neither removal nor addition happens. Because the replacement is appended, updating can move a note to the end of the list; this version does not preserve its position.

Work through a separate case. Add ID seven with Trip plan and ID eight with Shopping. Update seven to Weekend trip. Searching seven now returns Weekend trip, while eight still returns Shopping. Removing seven makes its next search return null. Updating or removing an absent ID nine leaves the other record unchanged.

Now connect the operations in our actual script. Create the store, add Lab ideas under ID one, update its title, print a search result, remove the note, and print another search result.

Both print expressions use the same safe call and Elvis fallback. If find returns a note, the safe call reads its title. If find returns null, the expression uses Missing. In the separate Trip plan case, that would print Weekend trip before removal and Missing afterward.

Predict the two lines for our actual ID one. Follow which note exists after each operation, and decide whether each search returns a note or null. Pause and trace the sequence before running it.

Run the script and compare the real output with your prediction.

Android lab ideas is the replacement note’s title after the update. Missing appears after removal because the second search returns null. The ID stayed one during the update, so both searches targeted the same logical note.

The store combines data objects, collection operations, nullable results, and controlled changes behind a small set of functions. This run checks the main sequence. It does not by itself prove every edge case, and none of the notes survive as saved data after the script ends.

Build a reminder store with the same four operations. Supply unique IDs, test present and missing IDs, and keep a second reminder while changing the first. What evidence shows that the other reminder survives, and that a missing update or removal leaves the store unchanged?

## Demonstrated code

```kotlin
data class Note(val id: Int, val title: String)
class NoteStore {
    private val notes = mutableListOf<Note>()
    fun add(note: Note) { notes.add(note) }
    fun find(id: Int): Note? = notes.find { it.id == id }
    fun remove(id: Int) {
        val note = find(id)
        if (note != null) { notes.remove(note) }
    }
    fun update(id: Int, title: String) {
        val note = find(id)
        if (note != null) {
            notes.remove(note)
            notes.add(note.copy(title = title))
        }
    }
}
val store = NoteStore()
store.add(Note(1, "Lab ideas"))
store.update(1, "Android lab ideas")
println(store.find(1)?.title ?: "Missing")
store.remove(1)
println(store.find(1)?.title ?: "Missing")
```

## Actual output

```text
Android lab ideas
Missing
```
