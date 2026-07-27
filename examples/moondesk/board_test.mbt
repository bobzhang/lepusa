///|
test "initial board exposes sprint metrics" {
  let model = @lepusa_moondesk.Model::initial()
  assert_eq(model.total(), 6)
  assert_eq(model.count(Backlog), 3)
  assert_eq(model.count(InProgress), 2)
  assert_eq(model.count(Done), 1)
  assert_eq(model.total_points(), 26)
  assert_eq(model.done_points(), 5)
  assert_eq(model.progress_percent(), 19)
}

///|
test "tasks can be added and filtered by priority" {
  let model = @lepusa_moondesk.update(
    AddTask("  Investigate crash report  ", High),
    @lepusa_moondesk.Model::initial(),
  )
  assert_eq(model.total(), 7)
  assert_eq(model.count(Backlog), 4)
  let filtered = @lepusa_moondesk.update(SetFilter(OnlyPriority(High)), model)
  assert_eq(filtered.tasks_in(Backlog).length(), 2)
  assert_eq(filtered.tasks_in(InProgress).length(), 1)
}

///|
test "task flow is reversible" {
  let initial = @lepusa_moondesk.Model::initial()
  let doing = @lepusa_moondesk.update(Advance(4), initial)
  assert_eq(doing.count(Backlog), 2)
  assert_eq(doing.count(InProgress), 3)
  let done = @lepusa_moondesk.update(Advance(4), doing)
  assert_eq(done.count(InProgress), 2)
  assert_eq(done.count(Done), 2)
  let undone = @lepusa_moondesk.update(Undo, done)
  assert_eq(undone.count(InProgress), 3)
  assert_eq(undone.count(Done), 1)
}

///|
test "completed work can be cleared and restored" {
  let initial = @lepusa_moondesk.Model::initial()
  let cleared = @lepusa_moondesk.update(ClearCompleted, initial)
  assert_eq(cleared.total(), 5)
  assert_eq(cleared.count(Done), 0)
  let restored = @lepusa_moondesk.update(Undo, cleared)
  assert_eq(restored.total(), 6)
  assert_eq(restored.count(Done), 1)
}

///|
test "derived JSON codec round-trips dynamic messages" {
  let message = @lepusa_moondesk.Message::AddTask("Ship native build", High)
  let encoded = message.to_json()
  inspect(
    encoded.stringify(),
    content=(
      #|["AddTask","Ship native build","High"]
    ),
  )
  let decoded : @lepusa_moondesk.Message = @json.from_json(encoded)
  assert_eq(decoded, message)
}
