// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Category {
    /// Add category
    internal static var addButton: String { return L10n.tr("Localizable", "category.add_button", fallback: "Add category") }
    /// Habits and events can be
    /// grouped by meaning
    internal static var emptyPlaceholder: String { return L10n.tr("Localizable", "category.empty_placeholder", fallback: "Habits and events can be\ngrouped by meaning") }
    /// Category
    internal static var title: String { return L10n.tr("Localizable", "category.title", fallback: "Category") }
    internal enum Alert {
      /// OK
      internal static var ok: String { return L10n.tr("Localizable", "category.alert.ok", fallback: "OK") }
    }
    internal enum Error {
      /// Failed to load categories
      internal static var load: String { return L10n.tr("Localizable", "category.error.load", fallback: "Failed to load categories") }
      /// Failed to save category
      internal static var save: String { return L10n.tr("Localizable", "category.error.save", fallback: "Failed to save category") }
    }
    internal enum New {
      /// Enter category name
      internal static var placeholder: String { return L10n.tr("Localizable", "category.new.placeholder", fallback: "Enter category name") }
      /// New category
      internal static var title: String { return L10n.tr("Localizable", "category.new.title", fallback: "New category") }
    }
  }
  internal enum Common {
    /// Done
    internal static var done: String { return L10n.tr("Localizable", "common.done", fallback: "Done") }
  }
  internal enum Filters {
    /// All trackers
    internal static var all: String { return L10n.tr("Localizable", "filters.all", fallback: "All trackers") }
    /// Filters
    internal static var button: String { return L10n.tr("Localizable", "filters.button", fallback: "Filters") }
    /// Completed
    internal static var completed: String { return L10n.tr("Localizable", "filters.completed", fallback: "Completed") }
    /// Incomplete
    internal static var incomplete: String { return L10n.tr("Localizable", "filters.incomplete", fallback: "Incomplete") }
    /// Filters
    internal static var title: String { return L10n.tr("Localizable", "filters.title", fallback: "Filters") }
    /// Trackers for today
    internal static var today: String { return L10n.tr("Localizable", "filters.today", fallback: "Trackers for today") }
  }
  internal enum Onboarding {
    /// That's technology!
    internal static var finishButton: String { return L10n.tr("Localizable", "onboarding.finish_button", fallback: "That's technology!") }
    internal enum First {
      /// Track only what you want
      internal static var title: String { return L10n.tr("Localizable", "onboarding.first.title", fallback: "Track only what you want") }
    }
    internal enum Second {
      /// Even if it is not water or yoga
      internal static var title: String { return L10n.tr("Localizable", "onboarding.second.title", fallback: "Even if it is not water or yoga") }
    }
  }
  internal enum Schedule {
    /// Schedule
    internal static var title: String { return L10n.tr("Localizable", "schedule.title", fallback: "Schedule") }
  }
  internal enum Statistics {
    /// Completed
    internal static var completed: String { return L10n.tr("Localizable", "statistics.completed", fallback: "Completed") }
    /// Nothing to analyze yet
    internal static var emptyPlaceholder: String { return L10n.tr("Localizable", "statistics.empty_placeholder", fallback: "Nothing to analyze yet") }
    /// Statistics
    internal static var title: String { return L10n.tr("Localizable", "statistics.title", fallback: "Statistics") }
  }
  internal enum Tab {
    /// Statistics
    internal static var statistics: String { return L10n.tr("Localizable", "tab.statistics", fallback: "Statistics") }
    /// Trackers
    internal static var trackers: String { return L10n.tr("Localizable", "tab.trackers", fallback: "Trackers") }
  }
  internal enum Tracker {
    internal enum Creation {
      /// Cancel
      internal static var cancel: String { return L10n.tr("Localizable", "tracker.creation.cancel", fallback: "Cancel") }
      /// Category
      internal static var category: String { return L10n.tr("Localizable", "tracker.creation.category", fallback: "Category") }
      /// Color
      internal static var color: String { return L10n.tr("Localizable", "tracker.creation.color", fallback: "Color") }
      /// Create
      internal static var create: String { return L10n.tr("Localizable", "tracker.creation.create", fallback: "Create") }
      /// Edit habit
      internal static var editTitle: String { return L10n.tr("Localizable", "tracker.creation.edit_title", fallback: "Edit habit") }
      /// Emoji
      internal static var emoji: String { return L10n.tr("Localizable", "tracker.creation.emoji", fallback: "Emoji") }
      /// Every day
      internal static var everyDay: String { return L10n.tr("Localizable", "tracker.creation.every_day", fallback: "Every day") }
      /// 38-character limit
      internal static var nameLimit: String { return L10n.tr("Localizable", "tracker.creation.name_limit", fallback: "38-character limit") }
      /// Enter tracker name
      internal static var namePlaceholder: String { return L10n.tr("Localizable", "tracker.creation.name_placeholder", fallback: "Enter tracker name") }
      /// Save
      internal static var save: String { return L10n.tr("Localizable", "tracker.creation.save", fallback: "Save") }
      /// Schedule
      internal static var schedule: String { return L10n.tr("Localizable", "tracker.creation.schedule", fallback: "Schedule") }
      /// New habit
      internal static var title: String { return L10n.tr("Localizable", "tracker.creation.title", fallback: "New habit") }
    }
    internal enum Days {
      /// Plural format key: "%#@days@"
      internal static func count(_ p1: Int) -> String {
        return L10n.tr("Localizable", "tracker.days.count", p1, fallback: "Plural format key: \"%#@days@\"")
      }
    }
  }
  internal enum Trackers {
    /// Add tracker
    internal static var addAccessibility: String { return L10n.tr("Localizable", "trackers.add_accessibility", fallback: "Add tracker") }
    /// What should we track?
    internal static var emptyPlaceholder: String { return L10n.tr("Localizable", "trackers.empty_placeholder", fallback: "What should we track?") }
    /// Nothing found
    internal static var searchEmptyPlaceholder: String { return L10n.tr("Localizable", "trackers.search_empty_placeholder", fallback: "Nothing found") }
    /// Search
    internal static var searchPlaceholder: String { return L10n.tr("Localizable", "trackers.search_placeholder", fallback: "Search") }
    /// Trackers
    internal static var title: String { return L10n.tr("Localizable", "trackers.title", fallback: "Trackers") }
    internal enum ContextMenu {
      /// Delete
      internal static var delete: String { return L10n.tr("Localizable", "trackers.context_menu.delete", fallback: "Delete") }
      /// Edit
      internal static var edit: String { return L10n.tr("Localizable", "trackers.context_menu.edit", fallback: "Edit") }
    }
    internal enum Delete {
      /// Cancel
      internal static var cancel: String { return L10n.tr("Localizable", "trackers.delete.cancel", fallback: "Cancel") }
      /// Delete
      internal static var confirm: String { return L10n.tr("Localizable", "trackers.delete.confirm", fallback: "Delete") }
      /// Are you sure you want to delete this tracker?
      internal static var message: String { return L10n.tr("Localizable", "trackers.delete.message", fallback: "Are you sure you want to delete this tracker?") }
    }
  }
  internal enum Weekday {
    /// Friday
    internal static var friday: String { return L10n.tr("Localizable", "weekday.friday", fallback: "Friday") }
    /// Monday
    internal static var monday: String { return L10n.tr("Localizable", "weekday.monday", fallback: "Monday") }
    /// Saturday
    internal static var saturday: String { return L10n.tr("Localizable", "weekday.saturday", fallback: "Saturday") }
    /// Sunday
    internal static var sunday: String { return L10n.tr("Localizable", "weekday.sunday", fallback: "Sunday") }
    /// Thursday
    internal static var thursday: String { return L10n.tr("Localizable", "weekday.thursday", fallback: "Thursday") }
    /// Tuesday
    internal static var tuesday: String { return L10n.tr("Localizable", "weekday.tuesday", fallback: "Tuesday") }
    /// Wednesday
    internal static var wednesday: String { return L10n.tr("Localizable", "weekday.wednesday", fallback: "Wednesday") }
    internal enum Short {
      /// Fri
      internal static var friday: String { return L10n.tr("Localizable", "weekday.short.friday", fallback: "Fri") }
      /// Mon
      internal static var monday: String { return L10n.tr("Localizable", "weekday.short.monday", fallback: "Mon") }
      /// Sat
      internal static var saturday: String { return L10n.tr("Localizable", "weekday.short.saturday", fallback: "Sat") }
      /// Sun
      internal static var sunday: String { return L10n.tr("Localizable", "weekday.short.sunday", fallback: "Sun") }
      /// Thu
      internal static var thursday: String { return L10n.tr("Localizable", "weekday.short.thursday", fallback: "Thu") }
      /// Tue
      internal static var tuesday: String { return L10n.tr("Localizable", "weekday.short.tuesday", fallback: "Tue") }
      /// Wed
      internal static var wednesday: String { return L10n.tr("Localizable", "weekday.short.wednesday", fallback: "Wed") }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Localization.localizedString(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
