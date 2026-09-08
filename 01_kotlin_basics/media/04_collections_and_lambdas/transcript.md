# Collections and Lambdas — transcript

## Visual description

A BHCC opening introduces collection operations, selection, transformation and safe searches. A diagram connects source records, clear rules and display values. A notes-app sample names three notes and their archive states. The video then shows a real Workspace with only demo.kts in Explorer. The camera follows actual typing, then widens for the native Run Code button and its Output panel. The program prints three lines. Narration ends with a reminder-list transfer prompt.

## Narration

Welcome to CSC-244. In this lesson, you’ll choose the operations a Kotlin collection allows, use lambdas to select and transform its elements, and handle a missing search result safely. A lambda is a small function we can pass to another operation. A collection holds several related values.

These skills turn a group of app records into information a screen can display. Separating selection from transformation makes each rule easier to read and test. Keeping the source available also lets different parts of an app build different views from the same records.

Imagine you’re developing an Android notes app. Each note has a text title and a Boolean archived flag. Our source has three notes: Lab ideas, Old list, and App sketch. Old list is archived; the other notes use the default active state. We also want to search for a title supplied by the app.

Our script will select the active notes, turn those notes into titles, and print each title. It will also search the original list and show a helpful message when there is no match. We’ll keep selection, transformation, display, and search as separate steps so their different jobs are clear.

Let’s build this in demo.kts. The standard Run Code button will execute our script with the installed Kotlin compiler.

First, describe each note and group the sample notes into an ordered list. A list fits because we want to keep the source order and process every note in that order.

The familiar Note data class stores a title and an archived flag that defaults to false. List of creates a list with read-only operations for our sample values. Those operations let us read the elements, but do not include add or remove. A mutable list provides those changing operations when a task needs them.

Read-only access is not a promise that every object reachable from a collection is immutable. Another reference could expose mutable data. Also, val prevents reassigning a variable; it does not by itself prevent a mutable collection from changing. Here, our filtering and mapping steps produce separate result lists and leave the source list intact.

We need a rule that decides which notes belong in the active view. Filter applies a Boolean test to each source element and keeps the elements whose test is true. We’ll pass that test as a lambda, a small function written inside braces.

Inside this lambda, it means the one note currently being tested. The exclamation mark negates its archived flag, so the test is true for an unarchived note. Each note is tested in turn. The braces follow filter because Kotlin allows a final lambda argument outside the parentheses. This is trailing-lambda syntax. ActiveNotes holds the selected Note objects in source order; filtering has not deleted anything from notes.

Work through a different small list. Suppose Draft is active and Old plan is archived. Filtering for active notes tests Draft as true and Old plan as false, so the result contains Draft only. The original list still contains both notes. Selection decides which elements to keep; it does not turn a note into display text.

The screen needs titles rather than whole Note objects. Map solves that different problem: it applies a transformation to each selected element and collects the returned values into a new list.

In this lambda, it refers to one element of activeNotes. The lambda returns that note’s title, so titles is a list of strings. With our separate Draft example, mapping the one selected note would produce the text Draft. Filter chose a note; map extracted a value from it. Neither operation changes the original list.

Now make those title strings visible. ForEach performs an action for each element. We’ll give it a lambda that prints the current title. Printing is a side effect: it changes what appears in Output instead of producing a transformed list for us to use.

ForEach visits the strings in titles in order, and println displays each one on its own line. Here, it names a string, whereas the earlier lambdas received Note objects. The collection used for each call determines what that lambda receives.

Finally, a search must allow for an absent title. Find checks elements until it finds the first match, or returns null when none match. We’ll search notes, the complete source list, for the title Missing. Then we’ll reuse the safe call and Elvis fallback from Lesson Two to choose display text safely.

The search lambda compares each note’s title with the requested text. Match is nullable because a search can fail. The safe call reads the title only when a note was found, and the Elvis expression supplies fallback text otherwise. For a separate example, search a list containing Draft for Budget. No title matches, so find returns null. A fallback such as Not found becomes the text to display.

Before running, predict every printed line for our actual three-note list. Trace which notes pass the archive test, what map returns for them, and what the search returns. Then decide whether the final line uses a found title or the fallback. Pause and write your prediction.

Now run the script and compare the real output with your prediction.

Lab ideas and App sketch appear in source order because both notes are active. Old list does not appear in that title display because its archive flag is true. The last line is No matching note: no source title equals Missing, so the search returns null and the fallback is used.

We’ve built a display from the source records without removing archived notes from that source. Filter selects Note objects, map transforms them into strings, and forEach prints those strings. Find answers a different question about the original list, with a nullable result that we handle safely. These distinct jobs make the data flow easier to follow.

Now try a reminder list with a completion flag. Select the unfinished reminders, transform them into display text, and search for a title that is absent. Print the source before and after filtering to check that its entries remain intact. What evidence would show that your selection, transformation, and missing-result handling each did the intended job?

## Demonstrated code

```kotlin
data class Note(val title: String, val archived: Boolean = false)
val notes = listOf(Note("Lab ideas"), Note("Old list", true), Note("App sketch"))
val activeNotes = notes.filter { !it.archived }
val titles = activeNotes.map { it.title }
titles.forEach { println(it) }
val match = notes.find { it.title == "Missing" }
println(match?.title ?: "No matching note")
```

## Actual output

```text
Lab ideas
App sketch
No matching note
```
