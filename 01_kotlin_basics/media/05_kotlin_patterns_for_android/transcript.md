# Kotlin Patterns for Android — transcript

## Visual description

A BHCC opening introduces callbacks, extensions and focused scope functions. A diagram connects focused setup, reusable behavior and clear calls. A notes-app scenario supplies an editable draft title and optional selected title. The video then shows a real Workspace with only demo.kts in Explorer. The camera follows actual typing, then widens for the native Run Code button and its Output panel. The program prints two lines. Narration ends with a reminder-draft transfer prompt.

## Narration

Welcome to CSC-244. You’ll pass and invoke a callback, add an extension function, and use apply and let to keep Kotlin object work focused. A callback is an action supplied to another function. An extension gives a type a convenient new calling form without changing its class.

These patterns help separate what an app should do from the code that triggers it. They also keep object setup and optional-value handling close to the data involved, making short pieces of app logic easier to read.

Imagine you’re building a notes app. A draft has an editable text title. Our sample title is Lab ideas. We want to configure the draft, display a heading when a title is selected, and pass an action that prints a confirmation.

We’ll model that action with a function called simulateClick. It invokes the supplied callback immediately. This is a synchronous language example, not an Android screen or event loop. The confirmation is printed text; the script does not save data to storage.

Let’s open demo.kts. The standard Run Code button will execute our script with the installed Kotlin compiler.

First, give the draft a title we can configure. The constructor property uses var because this draft’s title can be assigned a new value.

The title starts as empty text when no argument is supplied. To reuse our heading format, we’ll define a String extension called asNoteHeading.

String before the function name identifies the receiver type: the kind of value we call it on. Inside the extension, this is that string. The function returns new text with the Note prefix; it does not change String’s class. For example, calling it on Trip plan returns Note: Trip plan.

Now separate triggering an action from choosing what that action does. SimulateClick will accept a function value, then invoke it.

The onClick parameter’s function type takes no arguments and returns Unit, meaning no useful result value. Writing the lambda supplies an action; calling onClick actually runs it. Our function makes that call once, immediately, before simulateClick returns. A real event system could retain an action for later, but this model does not.

The pieces are ready, so create the draft and configure its title with apply. This scope function groups work around one object and returns that same object afterward.

Inside apply, the draft is the receiver, available as this. We can therefore assign title without repeating the object’s name. Draft receives the configured object, not a new copy. SelectedTitle is declared nullable even though this assignment gives it the draft’s actual text.

We only want a heading when a selection exists. A safe call to let skips its lambda when selectedTitle is null. Otherwise, let passes the title as it. We’ll print its formatted heading, then supply a separate confirmation callback.

Inside let, it names the selected string, so the extension produces the heading. Let returns its lambda’s result; here println returns Unit, which we do not use. Apply returned the draft itself. The last line passes a lambda to simulateClick, whose body invokes it. That action reads draft’s title and prints the confirmation.

Trace a different title before our run. Configure a draft as Trip plan and select its title. Let prints Note: Trip plan, then the callback prints Saved: Trip plan. If the selection were null instead, the heading step would be skipped. The separate callback call would still run because it is outside let.

Now predict the two lines for our actual Lab ideas draft. Which object does apply return? What does let receive, and which statement invokes the confirmation action? Pause and trace the calls in order.

Run the script and compare the actual output with your prediction.

Note: Lab ideas comes from the selected title and our extension. Saved: Lab ideas comes from the callback invoked inside simulateClick. The order follows the two calls in the script. Both messages use the configured draft title, and no persistent save has occurred.

Apply kept configuration together, the extension reused a heading rule, and the safe call with let handled an optional selection. The callback separated an action from the function that invokes it. These are small, distinct roles you can recognize in app code.

Try this pattern with a reminder draft. Configure its title with apply, show a heading only when selected, and pass a callback that prints a confirmation. Test both a present and a null selection. Which output should change, and what proves that passing an action and invoking it are different steps?

## Demonstrated code

```kotlin
class NoteDraft(var title: String = "")
fun String.asNoteHeading(): String = "Note: $this"
fun simulateClick(onClick: () -> Unit) {
    onClick()
}
val draft = NoteDraft().apply { title = "Lab ideas" }
val selectedTitle: String? = draft.title
selectedTitle?.let { println(it.asNoteHeading()) }
simulateClick { println("Saved: ${draft.title}") }
```

## Actual output

```text
Note: Lab ideas
Saved: Lab ideas
```
