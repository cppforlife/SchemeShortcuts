SchemeShortcuts is an Xcode 4 plugin that lets you define custom shortcuts
to quickly switch between Xcode schemes. After Xcode switches to specified
scheme, `Product > Run` menu action is automatically run.

* Install by building this project

* Make a text file named `SchemeShortcuts` inside `YourProjectName.xcodeproj`

* Define shortcuts - separate scheme name and destination name with `>`:

  ```text
  u: SchemeShortcuts > My Mac 64-bit
  e: SchemeShortcuts > My Mac 32-bit
  U: SchemeShortcuts > My Mac 32-bit
  ```

* Restart Xcode

* Use `Cmd+KEY` to switch between schemes
  - `u` becomes `Cmd+u`
  - `U` becomes `Cmd+Shift+u`
