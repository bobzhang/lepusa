///|
fn main {
  match calculator_project().runtime_host() {
    Err(problems) => abort(problems.join("; "))
    Ok(host) =>
      match @macos.runtime(host) {
        Err(problems) => abort(problems.join("; "))
        Ok(runtime) =>
          match @macos.launch(runtime) {
            Ok(_) => ()
            Err(problems) => abort(problems.join("; "))
          }
      }
  }
}
