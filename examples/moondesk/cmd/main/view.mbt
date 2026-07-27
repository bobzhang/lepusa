///|
fn moondesk_view(
  emit : @ui.ViewEmit[@moondesk.Message],
  model : @moondesk.Model,
) -> @lepusa.Html {
  @ui.concat([
    moondesk_styles(),
    @ui.main_(
      [
        app_header(emit, model),
        metrics(model),
        quick_add(),
        @ui.div([board(emit, model), detail_sidebar(emit, model)], attrs=[
          @ui.class_name("workspace"),
        ]),
      ],
      attrs=[
        @ui.class_name(if model.compact() { "app compact" } else { "app" }),
      ],
    ),
  ])
}

///|
fn app_header(
  emit : @ui.ViewEmit[@moondesk.Message],
  model : @moondesk.Model,
) -> @lepusa.Html {
  @ui.element(
    "header",
    [
      @ui.div(
        [
          @ui.span([@ui.text("M")], attrs=[@ui.class_name("brand-mark")]),
          @ui.div(
            [
              @ui.h1([@ui.text("MoonDesk")]),
              @ui.p([@ui.text("Native sprint control center")]),
            ],
            attrs=[@ui.class_name("brand-copy")],
          ),
        ],
        attrs=[@ui.class_name("brand")],
      ),
      @ui.div(
        [
          @ui.span([@ui.text("Native backend")], attrs=[
            @ui.class_name("native-badge"),
          ]),
          @ui.button(if model.compact() { "Comfortable" } else { "Compact" }, attrs=[
            @ui.class_name("ghost-button"),
            emit(ToggleCompact),
          ]),
          @ui.button("Undo", attrs=[
            @ui.class_name(
              if model.can_undo() {
                "ghost-button"
              } else {
                "ghost-button disabled"
              },
            ),
            emit(Undo),
          ]),
        ],
        attrs=[@ui.class_name("header-actions")],
      ),
    ],
    attrs=[@ui.class_name("app-header")],
  )
}

///|
fn metrics(model : @moondesk.Model) -> @lepusa.Html {
  @ui.section(
    [
      metric(
        "Sprint progress",
        "\{model.progress_percent()}%",
        "of story points",
      ),
      metric("In progress", model.count(InProgress).to_string(), "active tasks"),
      metric("Completed", model.count(Done).to_string(), "ready to ship"),
      @ui.div(
        [
          @ui.div(
            [
              @ui.span([@ui.text("Velocity")]),
              @ui.element("strong", [
                @ui.text("\{model.done_points()}/\{model.total_points()}"),
              ]),
            ],
            attrs=[@ui.class_name("metric-line")],
          ),
          @ui.element("progress", [], attrs=[
            @ui.attr("value", model.done_points().to_string()),
            @ui.attr("max", model.total_points().to_string()),
          ]),
          @ui.span([@ui.text("points delivered")], attrs=[
            @ui.class_name("metric-note"),
          ]),
        ],
        attrs=[@ui.class_name("metric progress-card")],
      ),
    ],
    attrs=[@ui.class_name("metrics")],
  )
}

///|
fn metric(label : String, value : String, note : String) -> @lepusa.Html {
  @ui.div(
    [
      @ui.span([@ui.text(label)], attrs=[@ui.class_name("metric-label")]),
      @ui.element("strong", [@ui.text(value)], attrs=[
        @ui.class_name("metric-value"),
      ]),
      @ui.span([@ui.text(note)], attrs=[@ui.class_name("metric-note")]),
    ],
    attrs=[@ui.class_name("metric")],
  )
}

///|
fn quick_add() -> @lepusa.Html {
  @ui.section(
    [
      @ui.div(
        [
          @ui.span([@ui.text("+")], attrs=[@ui.class_name("add-icon")]),
          @ui.input(attrs=[
            @ui.id("new-task-title"),
            @ui.class_name("task-input"),
            @ui.attr("type", "text"),
            @ui.attr("placeholder", "Add a task to the backlog…"),
            @ui.attr("maxlength", "80"),
            @ui.attr(
              "onkeydown", "if(event.key==='Enter'){document.getElementById('add-task-button').click()}",
            ),
          ]),
        ],
        attrs=[@ui.class_name("add-field")],
      ),
      @ui.element(
        "select",
        [
          @ui.element("option", [@ui.text("Low priority")], attrs=[
            @ui.attr("value", "Low"),
          ]),
          @ui.element("option", [@ui.text("Medium priority")], attrs=[
            @ui.attr("value", "Medium"),
            @ui.attr("selected", "selected"),
          ]),
          @ui.element("option", [@ui.text("High priority")], attrs=[
            @ui.attr("value", "High"),
          ]),
        ],
        attrs=[@ui.id("new-task-priority"), @ui.class_name("priority-select")],
      ),
      @ui.button("Add task", attrs=[
        @ui.id("add-task-button"),
        @ui.class_name("primary-button"),
        @ui.attr("onclick", add_task_script()),
      ]),
    ],
    attrs=[@ui.class_name("quick-add")],
  )
}

///|
fn board(
  emit : @ui.ViewEmit[@moondesk.Message],
  model : @moondesk.Model,
) -> @lepusa.Html {
  @ui.section(
    [
      @ui.div(
        [
          @ui.div(
            [
              @ui.h2([@ui.text("Sprint board")]),
              @ui.p([@ui.text("State is owned by the MoonBit native process")]),
            ],
            attrs=[@ui.class_name("section-heading")],
          ),
          filter_bar(emit, model.filter()),
        ],
        attrs=[@ui.class_name("board-toolbar")],
      ),
      @ui.div(
        [
          lane_column(emit, model, Backlog),
          lane_column(emit, model, InProgress),
          lane_column(emit, model, Done),
        ],
        attrs=[@ui.class_name("board-grid")],
      ),
    ],
    attrs=[@ui.class_name("board-panel")],
  )
}

///|
fn filter_bar(
  emit : @ui.ViewEmit[@moondesk.Message],
  current : @moondesk.PriorityFilter,
) -> @lepusa.Html {
  @ui.div(
    [
      filter_button(emit, current, AllPriorities),
      filter_button(emit, current, OnlyPriority(High)),
      filter_button(emit, current, OnlyPriority(Medium)),
      filter_button(emit, current, OnlyPriority(Low)),
    ],
    attrs=[@ui.class_name("filters")],
  )
}

///|
fn filter_button(
  emit : @ui.ViewEmit[@moondesk.Message],
  current : @moondesk.PriorityFilter,
  filter : @moondesk.PriorityFilter,
) -> @lepusa.Html {
  @ui.button(filter.label(), attrs=[
    @ui.class_name(if current == filter { "filter active" } else { "filter" }),
    emit(SetFilter(filter)),
  ])
}

///|
fn lane_column(
  emit : @ui.ViewEmit[@moondesk.Message],
  model : @moondesk.Model,
  lane : @moondesk.Lane,
) -> @lepusa.Html {
  let tasks = model.tasks_in(lane)
  let cards : Array[@lepusa.Html] = []
  for task in tasks {
    cards.push(
      task_card(emit, task, selected=model.selected_id() == Some(task.id())),
    )
  }
  if cards.is_empty() {
    cards.push(
      @ui.div([@ui.text("No tasks match this filter")], attrs=[
        @ui.class_name("empty-column"),
      ]),
    )
  }
  @ui.div(
    [
      @ui.div(
        [
          @ui.div(
            [
              @ui.span([], attrs=[
                @ui.class_name("lane-dot lane-\{lane_class(lane)}"),
              ]),
              @ui.element("strong", [@ui.text(lane.label())]),
            ],
            attrs=[@ui.class_name("lane-title")],
          ),
          @ui.span([@ui.text(tasks.length().to_string())], attrs=[
            @ui.class_name("lane-count"),
          ]),
        ],
        attrs=[@ui.class_name("lane-header")],
      ),
      @ui.div(cards, attrs=[@ui.class_name("task-list")]),
    ],
    attrs=[@ui.class_name("lane")],
  )
}

///|
fn task_card(
  emit : @ui.ViewEmit[@moondesk.Message],
  task : @moondesk.Task,
  selected~ : Bool,
) -> @lepusa.Html {
  let actions : Array[@lepusa.Html] = []
  if task.lane() != Backlog {
    actions.push(
      @ui.button("←", attrs=[
        @ui.class_name("card-action"),
        emit(MoveBack(task.id())),
      ]),
    )
  }
  if task.lane() != Done {
    actions.push(
      @ui.button("→", attrs=[
        @ui.class_name("card-action accent"),
        emit(Advance(task.id())),
      ]),
    )
  }
  actions.push(
    @ui.button("×", attrs=[
      @ui.class_name("card-action danger"),
      emit(Delete(task.id())),
    ]),
  )
  @ui.element(
    "article",
    [
      @ui.div(
        [
          @ui.span([@ui.text(task.priority().label())], attrs=[
            @ui.class_name("priority priority-\{task.priority().class_name()}"),
          ]),
          @ui.span([@ui.text("\{task.points()} pts")], attrs=[
            @ui.class_name("points"),
          ]),
        ],
        attrs=[@ui.class_name("card-meta")],
      ),
      @ui.button(task.title(), attrs=[
        @ui.class_name("task-title"),
        emit(Select(task.id())),
      ]),
      @ui.div(actions, attrs=[@ui.class_name("card-actions")]),
    ],
    attrs=[
      @ui.class_name(if selected { "task-card selected" } else { "task-card" }),
      @ui.data("task-id", task.id().to_string()),
    ],
  )
}

///|
fn detail_sidebar(
  emit : @ui.ViewEmit[@moondesk.Message],
  model : @moondesk.Model,
) -> @lepusa.Html {
  @ui.element(
    "aside",
    [
      selected_task_panel(emit, model.selected_task()),
      @ui.div(
        [
          @ui.div(
            [
              @ui.h2([@ui.text("Activity")]),
              @ui.span([@ui.text("LIVE")], attrs=[@ui.class_name("live-pill")]),
            ],
            attrs=[@ui.class_name("aside-heading")],
          ),
          @ui.div(
            model
            .activity()
            .map(entry => {
              @ui.div(
                [
                  @ui.span([], attrs=[@ui.class_name("activity-dot")]),
                  @ui.span([@ui.text(entry)]),
                ],
                attrs=[@ui.class_name("activity-row")],
              )
            }),
            attrs=[@ui.class_name("activity-list")],
          ),
        ],
        attrs=[@ui.class_name("aside-card")],
      ),
      @ui.button("Clear completed", attrs=[
        @ui.class_name("clear-button"),
        emit(ClearCompleted),
      ]),
    ],
    attrs=[@ui.class_name("sidebar")],
  )
}

///|
fn selected_task_panel(
  emit : @ui.ViewEmit[@moondesk.Message],
  selected : @moondesk.Task?,
) -> @lepusa.Html {
  match selected {
    None =>
      @ui.div(
        [
          @ui.span([@ui.text("◎")], attrs=[@ui.class_name("detail-icon")]),
          @ui.h2([@ui.text("Select a task")]),
          @ui.p([@ui.text("Choose a card to inspect its native state.")]),
        ],
        attrs=[@ui.class_name("aside-card detail empty-detail")],
      )
    Some(task) => {
      let actions : Array[@lepusa.Html] = []
      if task.lane() != Backlog {
        actions.push(
          @ui.button("Move back", attrs=[
            @ui.class_name("ghost-button"),
            emit(MoveBack(task.id())),
          ]),
        )
      }
      if task.lane() != Done {
        actions.push(
          @ui.button("Advance", attrs=[
            @ui.class_name("primary-button"),
            emit(Advance(task.id())),
          ]),
        )
      }
      @ui.div(
        [
          @ui.span([@ui.text("Selected task")], attrs=[
            @ui.class_name("eyebrow"),
          ]),
          @ui.h2([@ui.text(task.title())]),
          @ui.div(
            [
              detail_row("Lane", task.lane().label()),
              detail_row("Priority", task.priority().label()),
              detail_row("Estimate", "\{task.points()} story points"),
              detail_row("Native ID", "#\{task.id()}"),
            ],
            attrs=[@ui.class_name("detail-grid")],
          ),
          @ui.div(actions, attrs=[@ui.class_name("detail-actions")]),
        ],
        attrs=[@ui.class_name("aside-card detail")],
      )
    }
  }
}

///|
fn detail_row(label : String, value : String) -> @lepusa.Html {
  @ui.div(
    [@ui.span([@ui.text(label)]), @ui.element("strong", [@ui.text(value)])],
    attrs=[@ui.class_name("detail-row")],
  )
}

///|
fn lane_class(lane : @moondesk.Lane) -> String {
  match lane {
    Backlog => "backlog"
    InProgress => "doing"
    Done => "done"
  }
}

///|
fn add_task_script() -> String {
  let source =
    #|(() => {
    #|  const title = document.getElementById('new-task-title');
    #|  const priority = document.getElementById('new-task-priority');
    #|  if (!title || !title.value.trim()) { if (title) title.focus(); return; }
    #|  const api = window.lepusa;
    #|  if (!api || typeof api.invoke !== 'function') return;
    #|  api.invoke('moondesk.dispatch', ['AddTask', title.value.trim(), priority ? priority.value : 'Medium'])
    #|    .then((payload) => {
    #|      const root = document.getElementById('lepusa-root');
    #|      if (root && payload && typeof payload.html === 'string') root.innerHTML = payload.html;
    #|    });
    #|})()
  source
}

///|
fn moondesk_styles() -> @lepusa.Html {
  let styles =
    #|<style>
    #|:root { color-scheme: dark; font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #0b0d10; }
    #|* { box-sizing: border-box; }
    #|html, body { min-height: 100%; margin: 0; color: #f7f7f5; background: #0b0d10; }
    #|body { background-image: radial-gradient(circle at 12% 0%, rgba(99,91,255,.16), transparent 28%), radial-gradient(circle at 90% 4%, rgba(56,189,147,.09), transparent 24%); }
    #|button, input, select { font: inherit; }
    #|button { color: inherit; }
    #|#lepusa-root { min-height: 100vh; }
    #|.app { width: min(1600px, 100%); min-height: 100vh; margin: 0 auto; padding: 28px 32px 40px; }
    #|.app-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
    #|.brand, .header-actions, .metric-line, .lane-title, .aside-heading { display: flex; align-items: center; }
    #|.brand { gap: 13px; }
    #|.brand-mark { display: grid; width: 42px; height: 42px; place-items: center; border-radius: 13px; color: #0d0f12; background: linear-gradient(145deg, #9b95ff, #6d64ff); font-weight: 900; box-shadow: 0 12px 32px rgba(109,100,255,.28); }
    #|.brand-copy h1 { margin: 0; font-size: 19px; letter-spacing: -.02em; }
    #|.brand-copy p { margin: 3px 0 0; color: #777d88; font-size: 12px; }
    #|.header-actions { gap: 9px; }
    #|.native-badge, .live-pill { border: 1px solid rgba(65,208,158,.28); border-radius: 999px; color: #78ddb8; background: rgba(65,208,158,.09); font-size: 11px; font-weight: 750; letter-spacing: .06em; text-transform: uppercase; }
    #|.native-badge { padding: 8px 12px; }
    #|.ghost-button, .primary-button, .clear-button, .filter, .card-action, .task-title { border: 0; cursor: pointer; }
    #|.ghost-button { padding: 9px 13px; border: 1px solid #292d34; border-radius: 10px; color: #b8bdc6; background: #14171b; font-size: 12px; font-weight: 650; }
    #|.ghost-button:hover { border-color: #454b56; color: #fff; }
    #|.ghost-button.disabled { cursor: default; opacity: .38; }
    #|.metrics { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 16px; }
    #|.metric { min-height: 104px; padding: 17px 18px; border: 1px solid #20242a; border-radius: 15px; background: rgba(19,22,27,.86); box-shadow: 0 14px 40px rgba(0,0,0,.16); }
    #|.metric-label, .metric-note { display: block; color: #727985; font-size: 11px; font-weight: 650; }
    #|.metric-value { display: block; margin: 8px 0 4px; font-size: 29px; letter-spacing: -.04em; }
    #|.metric-line { justify-content: space-between; color: #8b919c; font-size: 11px; }
    #|.metric-line strong { color: #f4f5f6; font-size: 17px; }
    #|progress { width: 100%; height: 8px; margin: 14px 0 9px; border: 0; border-radius: 999px; overflow: hidden; background: #282c33; }
    #|progress::-webkit-progress-bar { background: #282c33; }
    #|progress::-webkit-progress-value { border-radius: 999px; background: linear-gradient(90deg, #766eff, #9b95ff); }
    #|.quick-add { display: grid; grid-template-columns: 1fr 180px auto; gap: 10px; margin-bottom: 20px; padding: 10px; border: 1px solid #23272e; border-radius: 15px; background: #111419; }
    #|.add-field { display: flex; align-items: center; gap: 10px; min-width: 0; }
    #|.add-icon { display: grid; width: 30px; height: 30px; flex: 0 0 auto; place-items: center; border-radius: 9px; color: #9f99ff; background: rgba(118,110,255,.12); font-size: 19px; }
    #|.task-input, .priority-select { width: 100%; border: 0; outline: 0; color: #eef0f3; background: transparent; }
    #|.task-input::placeholder { color: #5f6570; }
    #|.priority-select { padding: 8px 10px; border-left: 1px solid #292d34; color: #aeb4be; }
    #|.primary-button { padding: 10px 16px; border-radius: 10px; color: white; background: linear-gradient(145deg, #766eff, #635aff); font-size: 12px; font-weight: 750; box-shadow: 0 8px 22px rgba(99,90,255,.22); }
    #|.workspace { display: grid; grid-template-columns: minmax(0, 1fr) 270px; gap: 16px; }
    #|.board-panel, .aside-card { border: 1px solid #20242a; border-radius: 17px; background: rgba(17,20,25,.9); }
    #|.board-panel { min-width: 0; padding: 18px; }
    #|.board-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 20px; margin-bottom: 16px; }
    #|.section-heading h2, .aside-card h2 { margin: 0; font-size: 14px; letter-spacing: -.01em; }
    #|.section-heading p { margin: 4px 0 0; color: #666d78; font-size: 11px; }
    #|.filters { display: flex; gap: 5px; padding: 4px; border-radius: 10px; background: #0c0f13; }
    #|.filter { padding: 6px 10px; border-radius: 7px; color: #737a86; background: transparent; font-size: 10px; font-weight: 700; }
    #|.filter.active { color: #f1f0ff; background: #27243c; }
    #|.board-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 11px; }
    #|.lane { min-width: 0; min-height: 440px; padding: 11px; border-radius: 13px; background: #0d1014; }
    #|.lane-header { display: flex; align-items: center; justify-content: space-between; padding: 4px 3px 12px; }
    #|.lane-title { gap: 8px; color: #b8bdc5; font-size: 11px; }
    #|.lane-dot { width: 7px; height: 7px; border-radius: 99px; }
    #|.lane-backlog { background: #7d8592; }.lane-doing { background: #8c83ff; box-shadow: 0 0 10px rgba(140,131,255,.55); }.lane-done { background: #48c99b; }
    #|.lane-count { min-width: 21px; padding: 3px 6px; border-radius: 7px; color: #707681; background: #171a20; font-size: 10px; text-align: center; }
    #|.task-list { display: grid; gap: 9px; }
    #|.task-card { position: relative; min-width: 0; padding: 12px; border: 1px solid #242830; border-radius: 12px; background: #171a20; box-shadow: 0 8px 22px rgba(0,0,0,.14); transition: border-color 120ms ease, transform 120ms ease; }
    #|.task-card:hover { border-color: #373c46; transform: translateY(-1px); }
    #|.task-card.selected { border-color: #6f67e9; box-shadow: inset 0 0 0 1px rgba(118,110,255,.18), 0 10px 28px rgba(0,0,0,.2); }
    #|.card-meta, .card-actions, .detail-actions { display: flex; align-items: center; }
    #|.card-meta { justify-content: space-between; }
    #|.priority { padding: 3px 6px; border-radius: 6px; font-size: 8px; font-weight: 800; letter-spacing: .07em; text-transform: uppercase; }
    #|.priority-low { color: #8f99a9; background: rgba(143,153,169,.1); }.priority-medium { color: #e2b96f; background: rgba(226,185,111,.11); }.priority-high { color: #ff8c91; background: rgba(255,105,112,.11); }
    #|.points { color: #5f6671; font-size: 9px; }
    #|.task-title { width: 100%; padding: 10px 0 12px; color: #e8eaed; background: transparent; font-size: 12px; font-weight: 660; line-height: 1.4; text-align: left; }
    #|.card-actions { justify-content: flex-end; gap: 5px; opacity: .7; }
    #|.card-action { display: grid; width: 25px; height: 23px; place-items: center; border-radius: 6px; color: #858c97; background: #22262d; font-size: 12px; }
    #|.card-action:hover { color: white; }.card-action.accent { color: #a8a2ff; }.card-action.danger { color: #d17b80; }
    #|.empty-column { padding: 28px 10px; border: 1px dashed #252932; border-radius: 10px; color: #545a64; font-size: 10px; text-align: center; }
    #|.sidebar { display: grid; align-content: start; gap: 12px; }
    #|.aside-card { padding: 17px; }
    #|.detail h2 { margin: 8px 0 16px; font-size: 15px; line-height: 1.35; }
    #|.eyebrow { color: #7d75ed; font-size: 9px; font-weight: 850; letter-spacing: .11em; text-transform: uppercase; }
    #|.detail-grid { display: grid; gap: 8px; }
    #|.detail-row { display: flex; justify-content: space-between; gap: 12px; padding: 8px 0; border-bottom: 1px solid #242830; color: #6f7681; font-size: 10px; }
    #|.detail-row strong { color: #c6cad1; font-weight: 650; text-align: right; }
    #|.detail-actions { gap: 7px; margin-top: 15px; }
    #|.empty-detail { color: #656c77; text-align: center; }.empty-detail h2 { margin-top: 8px; }.empty-detail p { margin: 5px 0; font-size: 11px; line-height: 1.5; }
    #|.detail-icon { color: #6f67e9; font-size: 22px; }
    #|.aside-heading { justify-content: space-between; margin-bottom: 14px; }
    #|.live-pill { padding: 3px 6px; font-size: 7px; }
    #|.activity-list { display: grid; gap: 12px; }
    #|.activity-row { display: grid; grid-template-columns: 7px 1fr; align-items: start; gap: 8px; color: #858c97; font-size: 9px; line-height: 1.45; }
    #|.activity-dot { width: 5px; height: 5px; margin-top: 4px; border-radius: 99px; background: #6f67e9; }
    #|.clear-button { width: 100%; padding: 10px; border: 1px solid #302328; border-radius: 11px; color: #bd7379; background: rgba(92,36,43,.12); font-size: 10px; font-weight: 700; }
    #|.compact .task-card { padding: 9px; }.compact .task-title { padding: 7px 0 8px; }.compact .lane { min-height: 380px; }
    #|@media (max-width: 980px) { .workspace { grid-template-columns: 1fr; }.sidebar { grid-template-columns: repeat(2, 1fr); }.metrics { grid-template-columns: repeat(2, 1fr); } }
    #|@media (max-width: 720px) { .app { padding: 20px 16px; }.app-header, .board-toolbar { align-items: flex-start; flex-direction: column; }.header-actions { flex-wrap: wrap; }.quick-add { grid-template-columns: 1fr; }.priority-select { border: 0; }.board-grid { grid-template-columns: 1fr; }.lane { min-height: auto; }.sidebar { grid-template-columns: 1fr; } }
    #|@media (prefers-reduced-motion: reduce) { * { transition: none !important; } }
    #|</style>
  @ui.raw(styles)
}
