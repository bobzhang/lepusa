///|
test "MoonDesk dispatches derived JSON into native state" {
  let payload = @moondesk.Message::AddTask("Review release checklist", High)
    .to_json()
    .stringify()
  match moondesk_program().dispatch(payload) {
    Err(problem) => abort(problem)
    Ok(transition) => {
      assert_eq(transition.model().total(), 7)
      assert_eq(transition.model().count(Backlog), 4)
      assert_true(transition.command() != @lepusa.none)
    }
  }
}

///|
test "MoonDesk prepares a bridged macOS webview" {
  match moondesk_project().runtime_host() {
    Err(problems) => abort(problems.join("; "))
    Ok(host) => {
      assert_true(host.sync_command_routes().contains("moondesk.dispatch"))
      match @macos.runtime(host) {
        Err(problems) => abort(problems.join("; "))
        Ok(runtime) =>
          match @macos.prepare_run(runtime) {
            Err(problems) => abort(problems.join("; "))
            Ok(plan) => {
              assert_eq(plan.webviews().length(), 1)
              assert_true(
                plan
                .bridge()
                .sync_command_routes()
                .contains("moondesk.dispatch"),
              )
            }
          }
      }
    }
  }
}
