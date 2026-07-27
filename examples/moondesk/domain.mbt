///|
pub(all) enum Lane {
  Backlog
  InProgress
  Done
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Lane::label(self : Lane) -> String {
  match self {
    Backlog => "Backlog"
    InProgress => "In progress"
    Done => "Done"
  }
}

///|
fn Lane::next(self : Lane) -> Lane {
  match self {
    Backlog => InProgress
    InProgress => Done
    Done => Done
  }
}

///|
fn Lane::previous(self : Lane) -> Lane {
  match self {
    Backlog => Backlog
    InProgress => Backlog
    Done => InProgress
  }
}

///|
pub(all) enum Priority {
  Low
  Medium
  High
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Priority::label(self : Priority) -> String {
  match self {
    Low => "Low"
    Medium => "Medium"
    High => "High"
  }
}

///|
pub fn Priority::class_name(self : Priority) -> String {
  match self {
    Low => "low"
    Medium => "medium"
    High => "high"
  }
}

///|
pub(all) enum PriorityFilter {
  AllPriorities
  OnlyPriority(Priority)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PriorityFilter::label(self : PriorityFilter) -> String {
  match self {
    AllPriorities => "All"
    OnlyPriority(priority) => priority.label()
  }
}

///|
pub(all) struct Task {
  id : Int
  title : String
  lane : Lane
  priority : Priority
  points : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn Task::id(self : Task) -> Int {
  self.id
}

///|
pub fn Task::title(self : Task) -> String {
  self.title
}

///|
pub fn Task::lane(self : Task) -> Lane {
  self.lane
}

///|
pub fn Task::priority(self : Task) -> Priority {
  self.priority
}

///|
pub fn Task::points(self : Task) -> Int {
  self.points
}

///|
pub(all) enum Message {
  AddTask(String, Priority)
  Advance(Int)
  MoveBack(Int)
  Delete(Int)
  Select(Int)
  SetFilter(PriorityFilter)
  ClearCompleted
  ToggleCompact
  Undo
} derive(Debug, Eq, ToJson, FromJson)
