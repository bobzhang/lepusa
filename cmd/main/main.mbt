///|
async fn main_async() -> Unit {
  let result = render_cli_async(drop_program(@env.args()))
  println(result.output)
  if result.exit_code != 0 {
    @env.exit(result.exit_code)
  }
}

///|
fn main {
  @async.run_async_main(main_async)
}
