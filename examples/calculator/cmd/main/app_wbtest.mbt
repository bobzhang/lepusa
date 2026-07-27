///|
test "calculator app prepares a bridged macOS webview" {
  match calculator_project().runtime_host() {
    Err(problems) => abort(problems.join("; "))
    Ok(host) => {
      assert_true(host.sync_command_routes().contains("calculator.dispatch"))
      match @macos.runtime(host) {
        Err(problems) => abort(problems.join("; "))
        Ok(runtime) =>
          match @macos.prepare_run(runtime) {
            Err(problems) => abort(problems.join("; "))
            Ok(plan) => {
              assert_eq(plan.webviews().length(), 1)
              assert_eq(
                plan.webviews()[0].url(),
                "lepusa://rabbita/main/index.html",
              )
              assert_true(
                plan
                .bridge()
                .sync_command_routes()
                .contains("calculator.dispatch"),
              )
            }
          }
      }
    }
  }
}
