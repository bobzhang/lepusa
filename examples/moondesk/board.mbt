///|
pub struct Model {
  tasks : Array[Task]
  next_id : Int
  filter : PriorityFilter
  selected_id : Int?
  compact : Bool
  history : Array[(Array[Task], Int)]
  activity : Array[String]
} derive(Debug, Eq)

///|
pub fn Model::initial() -> Model {
  {
    tasks: [
      {
        id: 1,
        title: "Design the IPC schema",
        lane: Done,
        priority: High,
        points: 5,
      },
      {
        id: 2,
        title: "Implement native command registry",
        lane: InProgress,
        priority: High,
        points: 8,
      },
      {
        id: 3,
        title: "Polish board interactions",
        lane: InProgress,
        priority: Medium,
        points: 3,
      },
      {
        id: 4,
        title: "Package the macOS release",
        lane: Backlog,
        priority: High,
        points: 5,
      },
      {
        id: 5,
        title: "Add Linux smoke tests",
        lane: Backlog,
        priority: Medium,
        points: 3,
      },
      {
        id: 6,
        title: "Write the migration guide",
        lane: Backlog,
        priority: Low,
        points: 2,
      },
    ],
    next_id: 7,
    filter: AllPriorities,
    selected_id: Some(2),
    compact: false,
    history: [],
    activity: [
      "Native MoonBit backend is ready", "IPC capability calculator.dispatch was replaced by moondesk.dispatch",
    ],
  }
}

///|
pub fn Model::total(self : Model) -> Int {
  self.tasks.length()
}

///|
pub fn Model::count(self : Model, lane : Lane) -> Int {
  self.tasks.filter(task => task.lane == lane).length()
}

///|
pub fn Model::total_points(self : Model) -> Int {
  self.tasks.fold(init=0, (total, task) => total + task.points)
}

///|
pub fn Model::done_points(self : Model) -> Int {
  self.tasks.fold(init=0, (total, task) => {
    if task.lane == Done {
      total + task.points
    } else {
      total
    }
  })
}

///|
pub fn Model::progress_percent(self : Model) -> Int {
  let total = self.total_points()
  if total == 0 {
    0
  } else {
    self.done_points() * 100 / total
  }
}

///|
pub fn Model::filter(self : Model) -> PriorityFilter {
  self.filter
}

///|
pub fn Model::compact(self : Model) -> Bool {
  self.compact
}

///|
pub fn Model::can_undo(self : Model) -> Bool {
  !self.history.is_empty()
}

///|
pub fn Model::selected_id(self : Model) -> Int? {
  self.selected_id
}

///|
pub fn Model::activity(self : Model) -> Array[String] {
  self.activity.copy()
}

///|
pub fn Model::tasks_in(self : Model, lane : Lane) -> Array[Task] {
  self.tasks.filter(task => {
    if task.lane != lane {
      false
    } else {
      match self.filter {
        AllPriorities => true
        OnlyPriority(priority) => task.priority == priority
      }
    }
  })
}

///|
pub fn Model::selected_task(self : Model) -> Task? {
  match self.selected_id {
    None => None
    Some(id) => self.task_by_id(id)
  }
}

///|
fn Model::task_by_id(self : Model, id : Int) -> Task? {
  for task in self.tasks {
    if task.id == id {
      return Some(task)
    }
  }
  None
}

///|
fn Model::remember(self : Model) -> Array[(Array[Task], Int)] {
  let history = self.history.copy()
  history.push((self.tasks.copy(), self.next_id))
  history
}

///|
fn Model::prepend_activity(self : Model, entry : String) -> Array[String] {
  let activity = [entry]
  for old_entry in self.activity {
    if activity.length() < 6 {
      activity.push(old_entry)
    }
  }
  activity
}

///|
fn Model::move_task(self : Model, id : Int, lane : Lane) -> Array[Task] {
  self.tasks.map(task => if task.id == id { { ..task, lane, } } else { task })
}

///|
pub fn update(message : Message, model : Model) -> Model {
  match message {
    AddTask(title, priority) => {
      let normalized = title.trim().to_owned()
      if normalized == "" {
        model
      } else {
        let tasks = model.tasks.copy()
        tasks.push({
          id: model.next_id,
          title: normalized,
          lane: Backlog,
          priority,
          points: 3,
        })
        {
          ..model,
          tasks,
          next_id: model.next_id + 1,
          selected_id: Some(model.next_id),
          history: model.remember(),
          activity: model.prepend_activity("Added “\{normalized}”"),
        }
      }
    }
    Advance(id) =>
      match model.task_by_id(id) {
        None => model
        Some(task) => {
          let next = task.lane.next()
          if next == task.lane {
            model
          } else {
            {
              ..model,
              tasks: model.move_task(id, next),
              selected_id: Some(id),
              history: model.remember(),
              activity: model.prepend_activity(
                "Moved “\{task.title}” to \{next.label()}",
              ),
            }
          }
        }
      }
    MoveBack(id) =>
      match model.task_by_id(id) {
        None => model
        Some(task) => {
          let previous = task.lane.previous()
          if previous == task.lane {
            model
          } else {
            {
              ..model,
              tasks: model.move_task(id, previous),
              selected_id: Some(id),
              history: model.remember(),
              activity: model.prepend_activity(
                "Moved “\{task.title}” back to \{previous.label()}",
              ),
            }
          }
        }
      }
    Delete(id) =>
      match model.task_by_id(id) {
        None => model
        Some(task) =>
          {
            ..model,
            tasks: model.tasks.filter(item => item.id != id),
            selected_id: if model.selected_id == Some(id) {
              None
            } else {
              model.selected_id
            },
            history: model.remember(),
            activity: model.prepend_activity("Deleted “\{task.title}”"),
          }
      }
    Select(id) =>
      if model.task_by_id(id) is Some(_) {
        { ..model, selected_id: Some(id) }
      } else {
        model
      }
    SetFilter(filter) => { ..model, filter, }
    ClearCompleted => {
      let completed = model.count(Done)
      if completed == 0 {
        model
      } else {
        {
          ..model,
          tasks: model.tasks.filter(task => task.lane != Done),
          selected_id: None,
          history: model.remember(),
          activity: model.prepend_activity(
            "Cleared \{completed} completed task\{if completed == 1 { "" } else { "s" }}",
          ),
        }
      }
    }
    ToggleCompact => { ..model, compact: !model.compact }
    Undo => {
      let history = model.history.copy()
      match history.pop() {
        None => model
        Some((tasks, next_id)) =>
          {
            ..model,
            tasks: tasks.copy(),
            next_id,
            selected_id: None,
            history,
            activity: model.prepend_activity("Undid the last board change"),
          }
      }
    }
  }
}
