# Functions and Null Safety — transcript

## Visual description

A BHCC opening introduces functions, caller arguments, and missing-text behavior. A diagram connects one function to many callers and consistent feedback. A notes-app header supplies the scenario. The video then shows a real Workspace with only demo.kts in Explorer. The camera follows actual typing, then widens for the native Run Code button and its Output panel. The program prints three lines. Narration ends with a note-title formatter transfer prompt.

## Narration

Welcome to CSC-244. In this lesson, you’ll write reusable Kotlin functions, supply default and named arguments, and handle missing text with nullable types, safe calls, and a fallback. A function gives a useful operation a name. Null safety makes the possibility of missing data explicit.

These skills let you centralize app rules instead of repeating them in every screen. They also help you decide what users should see when information is unavailable, before a missing value becomes a runtime error.

Imagine you’re building the header for an Android notes app. The header needs a display name and a note-count label. A supplied name should appear in uppercase. A missing name needs a readable fallback. Our sample calls use the name Sam, a missing name with a caller-selected fallback, and a count of three notes.

We’ll put each formatting rule in a small function and print the returned text to check it. Present text, missing text, and empty text are different cases. We’ll work through those differences before predicting the result of our sample calls.

Let’s open demo.kts and build these formatting functions. The standard Run Code button will execute the script with the installed Kotlin compiler.

First, several parts of the app could need the same display-name rule. We’ll give that rule one function, called displayName, so callers provide data instead of copying the decision.

The fun keyword introduces the function. Its name parameter has a nullable String type, so it can hold text or null. Null means no value is present. The fallback parameter is ordinary non-null text, with Guest as its default. The return type promises that callers receive a non-null String. A default is used when the caller omits that argument; it does not replace every null argument automatically.

Inside the function, we need to uppercase a name only when it exists, and still return text when it does not. A safe call lets us ask for the uppercase form without trying to call a method on null.

When name contains text, the safe call runs uppercase and produces the converted text. When name is null, it skips that call and produces null. The Elvis operator then chooses fallback only if the value on its left is null. The return keyword sends the chosen text back to the caller.

Work through a separate name, Riley. The safe call produces uppercase RILEY, so the fallback is unused. If the name is missing and the caller omits fallback, the safe call produces null and Guest is returned. An empty string is still a String, so its uppercase form stays empty and the fallback is not selected. Missing text and empty text need different rules.

We could force a nullable value with a non-null assertion, often called double bang, but that would throw an error for a missing name. Our safe call and fallback express the behavior we want instead. We can reuse this function without asking every caller to repeat the same null handling.

The header also needs a note-count label. That rule only builds one string, so we can write an expression-bodied function: its single expression supplies the returned value.

The count parameter is an Int. Kotlin infers that the string-template expression returns a String, so this short form needs no explicit return keyword. With a separate count of four, the result would be four notes. This simple rule always uses the word notes; it does not handle singular grammar.

Both functions are ready. Let’s add the three sample calls and print the values they return. Named arguments identify which parameter each value belongs to, making the missing-name test and its chosen fallback clear.

The first call supplies Sam and leaves fallback at its default. The second explicitly supplies null for name and Visitor for fallback. The last supplies the integer three to the count-label function. Before we run, predict the second printed line. Trace the safe call first, then decide whether the Elvis operator uses its right-hand value. Why should that line match your prediction? Pause and explain your reasoning.

Now run the script and compare the three actual lines with your trace.

The first line is SAM in uppercase because its name exists. The second is Visitor: the safe call was skipped for null, and the explicitly supplied fallback became the result. The default Guest did not replace the caller’s choice. The final line is three notes, built by the count function’s string template.

We’ve separated the header’s formatting rules from the places that call them. Function parameters carry the inputs, return values carry the results, and safe calls with a fallback handle absent names. The actual output confirms the present-name and missing-name paths in this small example.

Now write a similar function for an optional note title with a caller-chosen fallback. Test a present title, null, and an empty string. Explain why the empty case differs from null, and decide whether your app should treat it differently. What returned values would convince you that each rule works?

## Demonstrated code

```kotlin
fun displayName(name: String?, fallback: String = "Guest"): String {
    return name?.uppercase() ?: fallback
}
fun noteCountLabel(count: Int) = "$count notes"
println(displayName(name = "Sam"))
println(displayName(name = null, fallback = "Visitor"))
println(noteCountLabel(3))
```

## Actual output

```text
SAM
Visitor
3 notes
```
