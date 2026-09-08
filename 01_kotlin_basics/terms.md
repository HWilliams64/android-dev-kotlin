**Binding** - A name associated with a value. `val title = "Lab"` binds `title` to text. A fixed binding does not automatically make an object deeply immutable.

**`val` keyword** - Declares a read-only binding or property that cannot be reassigned through that name. `val count = 2` cannot later become `count = 3`. The object referenced by a `val` may still support changes to its contents.

**`var` keyword** - Declares a binding or property that can be reassigned. `var count = 2` permits `count += 1`; its type remains checked.

**Type inference** - The compiler determines a type from the code when a type annotation is omitted. In `val count = 2`, the type is `Int`. Inference does not mean that Kotlin has stopped checking types.

**String template** - Text that inserts a value using `$name` or evaluates an expression inside `${...}`. For example, `"Count: $count"` creates a string containing the count. Strings themselves are immutable.

**Structural equality** - A comparison of values using `==`. For strings, `title == "Lab"` compares their contents. This differs from Java's reference comparison with `==` on objects.

**Expression** - Code that supplies a value. Kotlin's `if` and `when` can supply a result directly to a binding or return statement.

**`if` and `else` keywords** - Choose between paths based on a Boolean condition. When used to supply a value, both outcomes must be covered: `if (count == 0) "Empty" else "Ready"`.

**`when` keyword** - Selects the first matching branch. A `when` expression must cover the possible input cases; an `else` branch can supply the remaining result. It does not fall through to later branches.

**Range** - A sequence described by endpoints. `1..3` includes 1, 2, and 3. Both endpoints are included in this form.

**`for` and `in` keywords** - Visit the values in a range or collection. In `for (number in 1..3)`, `number` receives each value in turn; it is not a C++-style counter update clause.

**`while` keyword** - Repeats its body while a condition is true. The condition is tested before each iteration, so the body may run zero times. The loop must eventually change something that permits it to stop.

**Function and `fun` keyword** - A function is a named operation declared with `fun`. It receives arguments through parameters and may return a result. Returning a string and printing a string are separate actions.

**Parameter** - A named input in a function declaration, such as `title: String`. Its type defines what the caller may supply.

**Argument** - A value supplied in a function call, such as `"Lab"` in `heading("Lab")`. Parameter names belong to the declaration; arguments belong to the call.

**Return type and `return` keyword** - The return type states what a function gives its caller. `return` sends the result from a block body. A function that returns `String` must supply non-null text on every normal return path.

**Default argument** - A value used when a caller omits an argument. In `fallback: String = "Guest"`, omitting `fallback` selects `Guest`. It does not silently replace an explicitly supplied null for another parameter.

**Named argument** - An argument written with its parameter name, such as `fallback = "Visitor"`. It clarifies the role of a value and must match the declared name.

**Expression-bodied function** - A function using `=` followed by the expression it returns. `fun label(count: Int) = "$count notes"` can infer its `String` return type. A block body uses different return-type rules.

**Nullable type** - A type that permits null, marked with `?`, such as `String?`. Null means no value is present. Empty text, `""`, is an existing string; the text `"null"` is also a string.

**Smart cast** - The compiler narrows a value's type after a check proves what is possible on that path. A stable local nullable `val` can be used as non-null inside a successful null check. The same guarantee may not hold for a changing property.

**Safe call** - The `?.` operator accesses a method or property only when its receiver is non-null. For null it skips the access and supplies null. It does not choose a display message by itself.

**Elvis operator** - The `?:` operator uses its right-hand value only when the left-hand result is null. `name?.uppercase() ?: "Guest"` supplies `Guest` for missing text. It does not treat an empty string as null.

**Non-null assertion** - The `!!` operator demands a non-null value and throws an exception if that demand is false. It does not provide recovery. Expected missing data should normally be handled explicitly.

**Model** - A representation of the data and behavior an app needs. A note model stores a title and related rules; it is separate from the screen that displays them.

**Class and object** - A class, declared with the `class` keyword, defines a structure and its behavior; an object is one instance made from it. Kotlin creates an object with a constructor call such as `NoteDraft("Travel")`, without Java's `new` keyword.

**Primary constructor** - The main construction parameter list after a Kotlin class name. It receives the starting values and may define properties with `val` or `var`. A plain parameter is not automatically a public property.

**Property** - A named value belonging to an object. Constructor properties can be read through the object, such as `draft.title`, subject to their visibility. A `var` property may change even when the binding to the object is a `val`.

**Method** - A function declared inside a class. It can use the object's state, such as a counter method that updates a private count and returns the new value.

**Visibility and `private`** - Visibility controls where a declaration can be accessed. Kotlin declarations are normally public; a private class member is accessed within its class. This is a language access rule, not encryption.

**Initializer block and `init`** - A block of statements that runs during construction. It can perform setup such as replacing an empty initial title. Reading a property afterward does not run the block again.

**Data class** - A class marked with `data` that receives generated value operations, including equality, readable text, and `copy`. These operations use primary-constructor properties; body-only properties are not part of the generated record comparison or copy parameters.

**Copy operation** - A data class's `copy()` creates another instance, replacing named constructor-property values and retaining the source values for omitted arguments. An omitted value does not reset to the class declaration's original default.

**Shallow copy** - A copy that does not recursively duplicate nested objects. A data class copy can still share a nested mutable object with its source. Copying a record does not guarantee deep immutability.

**Interface** - A contract for behavior, declared with the `interface` keyword, that implementing classes provide. A variable typed as an interface can call its declared operations while a concrete object supplies the implementation. An interface has no constructor call.

**`override` keyword** - Explicitly marks a method that implements or replaces an inherited declaration. Its parameter and return types must fulfill the declared contract; simply removing `override` does not repair an invalid implementation.

**Inheritance and `open`** - Inheritance defines a class using a superclass's structure and behavior. Kotlin's `open` permits a class to have subclasses or a method to be overridden. Opening the class alone does not open each method.

**Collection** - A group of values processed through a common set of operations. Kotlin collection types state what kinds of elements they contain; `List<String>` describes a list of strings. The type's operations determine how the collection may be used.

**List** - An ordered collection that permits duplicates. `listOf("Home", "Home")` contains two entries. Selecting entries with `filter` preserves their source order.

**Set** - A collection of unique elements. `setOf("study", "study")` has size one. Use membership tests such as `"study" in tags`; do not assume every set implementation promises the same iteration order.

**Map collection** - An association from unique keys to values. `mapOf("theme" to "dark")` pairs a setting name with its value. A missing key lookup returns null; this collection type is distinct from the `map` transformation operation.

**API** - An application programming interface: the operations made available for other code to use. A collection type's API determines which operations a reference can call. An API does not have to be a web service.

**Read-only collection API** - A set of operations that permits reading a collection through a reference but does not expose changes such as adding or removing entries. `List<String>` is read-only. Another mutable reference may still change the underlying collection, so read-only is not a guarantee of a frozen snapshot.

**Mutable collection API** - Operations that permit changes to collection contents. `mutableListOf("Home")` supports `add` and `remove`. A `val` binding may refer to a mutable list because changing the object is different from reassigning the binding. `mutableListOf<String>()` supplies an explicit element type for an initially empty mutable list.

**Key-value pair and `to`** - A pair associates two values, such as a map key and its stored value. In `"theme" to "dark"`, `to` is a library function used in a compact call form. It is not a language keyword.

**Lambda expression** - A function written as a value, often inside braces. In `{ title: String -> title.uppercase() }`, the parameter comes before the arrow and the final expression supplies the result. Creating a lambda does not run its body.

**Filter operation** - An operation that returns a list containing the elements that pass a test. `titles.filter { it != "" }` omits empty titles from its result. The operation does not remove elements from the source or deeply copy retained objects.

**Predicate** - A function that answers true or false for an input. A filter predicate's true result means keep that element. A predicate selects data; it does not itself define a display transformation.

**Trailing-lambda syntax** - Kotlin's call form that places a final lambda argument after the parentheses. With no other arguments, the empty parentheses can be omitted: `titles.filter { it != "" }`. This is a different spelling of the same function call.

**Implicit parameter `it`** - The automatic parameter name available when a lambda has one inferred parameter and omits its explicit declaration. In `titles.map { it.uppercase() }`, `it` is the current string. It is not a keyword or a name that exists outside that lambda.

**Map transformation** - An operation that produces one transformed result for each source element. `notes.map { it.title }` turns note objects into title strings. It returns a result list; it does not overwrite the source collection.

**Find operation** - A search that returns the first element passing a predicate, or null if none passes. `notes.find { it.title == "Travel" }` returns one note, not a list of matches. Handle absence before accessing its properties.

**forEach operation** - An operation that invokes an action for each element. `titles.forEach { println(it) }` prints each title. It does not return a list of the action's results; use `map` when the goal is a transformed list.

**Side effect** - An action that affects something beyond producing a return value, such as printing or modifying an object. A `forEach` action may have side effects. Whether data changes depends on what that action does.

**Function type** - A type that describes a function value's parameters and result. `() -> Unit` describes an action with no parameters and no meaningful result. A variable or parameter with this type can hold a compatible lambda.

**Unit** - Kotlin's type for a function result with no meaningful value to use. It serves a similar purpose to `void` in Java or C++. It does not mean null or an uninitialized property.

**Callback** - A function value passed to other code for that code to invoke. Defining or passing the value does not automatically run it. Our `simulateClick` helper invokes its callback immediately inside the ordinary call.

**Asynchronous work** - Work that can finish separately from the current sequence. A callback is not automatically asynchronous. This module does not schedule a delayed event or background task.

**Extension function** - A function called with member-style syntax on a receiver type without changing that type's class. `fun String.asBadge(): String = "[$this]"` formats a string receiver. It does not gain access to the class's private members.

**Receiver and `this`** - The receiver is the object on which an operation is called. Inside a String extension, `this` refers to that string. Inside an `apply` block, `this` refers to the object being configured.

**Scope function** - A library function that runs a block with an object available in a convenient form. `let` and `apply` differ in both how the block refers to the object and what the call returns. They are functions, not language keywords.

**let** - A scope function that passes its receiver as an argument, often named `it`, and returns the block's final expression. `title?.let { it.length }` skips the block for null. An empty string still enters the block.

**apply** - A scope function that exposes its receiver as `this` and returns that same object. It is useful for configuration, such as setting a draft's properties. It does not create a copy or a new object by itself.

**Object declaration and `object`** - A declaration of a named shared object. Members of `object AppLabels` are accessed through `AppLabels`, without a constructor call. This named object is different from creating a separate class instance for each use.

**Companion object** - An object declared inside a class with `companion object`. Its members can be accessed through the class name, such as `DraftFactory.blank()`. It is not separately created for every class instance.

**Factory function** - A function that creates and returns an object. A companion factory can give a clear name to a construction choice. In this module, `blank()` creates a draft with a default title.

**lateinit modifier** - Allows an eligible non-null mutable property to be initialized after construction. The property must be assigned before its first read or it throws `UninitializedPropertyAccessException`. It is not allowed for `val`, nullable properties, or primitive types such as `Int`.

**Record ID** - A stable value that identifies one record independently of its editable title. Two notes may share a title while having different IDs. This module requires the caller to supply unique IDs; the example store does not enforce uniqueness.

**In-memory storage** - Data held by the running program. This module's store loses its data when that program state is discarded; it does not save notes to a device or database.
