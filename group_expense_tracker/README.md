# Group Expense Tracker

A Flutter application for tracking group expenses, designed to work fully offline and locally. This app allows users to manage and split expenses among a group of people efficiently.

## Features

- **User-Friendly Interface**: Intuitive screens for adding expenses and viewing results.
- **Offline Functionality**: Works without an internet connection, storing data locally.
- **Expense Management**: Add, view, and manage expenses easily.
- **Group Tracking**: Keep track of who owes what within a group.
- **Service Charges**: Option to include service charges in expense calculations.

## Project Structure

```
group_expense_tracker
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── models
│   │   └── expense.dart         # Defines the Expense model
│   ├── screens
│   │   ├── home_screen.dart     # Home screen for inputting expenses
│   │   ├── add_expense_screen.dart # Screen for adding new expenses
│   │   └── group_screen.dart     # Displays results of expense calculations
│   ├── widgets
│   │   ├── expense_list.dart     # Widget for displaying a list of expenses
│   │   └── expense_form.dart     # Widget for entering expenses
│   └── services
│       └── local_storage_service.dart # Handles local storage functionalities
├── pubspec.yaml                  # Project configuration and dependencies
├── analysis_options.yaml         # Dart analysis configuration
└── README.md                     # Project documentation
```

## Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd group_expense_tracker
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Usage Guidelines

- Launch the app and navigate to the home screen to input the number of participants and their expenses.
- Use the add expense screen to enter new expenses and select how they should be split.
- View the group screen to see a summary of who owes whom and the total amounts.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.