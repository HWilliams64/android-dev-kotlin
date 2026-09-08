# Classes, Properties, and App Data — transcript

## Visual description

A BHCC opening introduces object construction, related properties, copying and interface implementation. A diagram connects related data, a shared operation and clear caller behavior. A notes-app model supplies the scenario. The video then shows a real Workspace with only demo.kts in Explorer. The camera follows actual typing, then widens for the native Run Code button and its Output panel. The program prints three lines. Narration ends with a reminder-model transfer prompt.

## Narration

Welcome to CSC-244. In this lesson, you’ll create Kotlin objects with constructor properties, copy a data object, and implement an interface with an explicit override. Constructor properties give each object its starting data. An interface names an operation that an implementing class must provide.

These skills help separate an app’s information from the behavior that uses it. A clear data model keeps related values together. A shared interface lets different implementations offer the same operation, so callers do not need to know every implementation detail.

Imagine you’re developing an Android notes app. A note has a text title and an archived flag. The flag is Boolean: it records whether the note is archived. Our sample title is Lab ideas. We want an archived version of this note while keeping the original object available.

We’ll describe the note data, define a formatting operation, and create a formatter that returns a note’s title. Then we’ll make a changed copy and inspect the title and both archive flags. That comparison will show which object each value belongs to.

Let’s open demo.kts and build the note model. The standard Run Code button will execute this script with the installed Kotlin compiler.

The title and archived state belong to the same note, so we’ll keep them together in a Note data class. Its main job is to carry these related values. The data modifier also supplies useful operations, including copy.

The parameter list after Note is its primary constructor. Putting val before title and archived makes them properties of each new object. The constructor receives their starting values. Archived has false as its default when the caller omits that argument. These properties are public and readable through the object, but val provides no setter for assigning a different value to either property.

To represent a changed version, we can ask copy to create another Note. Copy starts with the existing constructor-property values, then replaces only the arguments we name. It does not rewrite the original object. This is a shallow copy: if a property held another mutable object, both copies could refer to that same nested object. Here the properties hold only text and a Boolean.

Work through a separate example before our archive test. Suppose a note has the title Draft and uses the default archive flag. Copy it with only the title changed to Study plan. The original still has Draft, and the new note has Study plan. Both keep the original archive flag because that property was not replaced. This separates creating a changed object from editing an existing one.

The app also needs a way to turn a note into display text. We’ll define a NoteFormatter interface that promises a format operation. The interface describes what a formatter accepts and returns, without choosing how it creates the text.

The format function accepts a Note and promises a String result. There is no function body here. An implementing class must supply that behavior, which lets a caller rely on the same operation even when formatters differ.

For this version of the app, the display text should be just the title. We’ll make TitleFormatter implement the interface and provide that specific behavior.

The colon names the interface being implemented. Override explicitly marks format as the implementation of the promised operation. Its expression body returns the note’s title property. That property access uses the dot after note. The caller gets text back; the formatter does not change the note. Kotlin requires the override marker, which makes this relationship visible to the reader and compiler.

The model and formatter are ready. Now create the sample original, request a copy with a different archive flag, and create a formatter object. Keep separate names for the two notes so we can inspect them independently.

The Note call supplies Lab ideas and leaves archived at its default. The copy call supplies true for the copy’s archived argument. TitleFormatter needs no input arguments. Remember our separate title-copy example: properties omitted from the copy call keep their existing values in the new object. We’ll use that rule to trace this archive change.

Let’s print the formatter’s result and label each note’s archive flag.

Before running, predict all three lines. Which title will the formatter return? Which object does each labeled flag come from? Pause and trace the constructor defaults and the one named copy argument.

Now run the script and compare the actual output with your prediction.

The first line is Lab ideas because copying the archive flag kept the title, and our formatter returns that title. Original archived is false. Copy archived is true. Those labels confirm that we created a changed object while the original kept its starting state. The formatter read the archived copy without modifying it.

We’ve connected a data model with a separate behavior contract. Constructor properties keep each note’s values together, copy creates a related version, and the interface with an explicit override defines how this formatter supplies text. The actual output connects each value back to the correct object.

Now model a reminder with a title and a completion flag. Make a copy with a changed completion value, and write a formatter through an interface. Print both objects’ values to check your work. What results would show that your copy changed the intended property while the original stayed available?

## Demonstrated code

```kotlin
data class Note(val title: String, val archived: Boolean = false)
interface NoteFormatter {
    fun format(note: Note): String
}
class TitleFormatter : NoteFormatter {
    override fun format(note: Note): String = note.title
}
val originalNote = Note("Lab ideas")
val archivedNote = originalNote.copy(archived = true)
val formatter = TitleFormatter()
println(formatter.format(archivedNote))
println("Original archived: ${originalNote.archived}")
println("Copy archived: ${archivedNote.archived}")
```

## Actual output

```text
Lab ideas
Original archived: false
Copy archived: true
```
