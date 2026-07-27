///|
fn moondesk_program() -> @ui.UiProgram[@moondesk.Model, @moondesk.Message] {
  @ui.UiProgram::new(
    model=@moondesk.Model::initial(),
    update=fn(message, model) {
      (@moondesk.update(message, model), @lepusa.none)
    },
    view=moondesk_view,
    encode=encode_message,
    decode=decode_message,
    route="moondesk.dispatch",
    render_event="moondesk.render",
  )
}

///|
fn moondesk_project() -> @desktop.DesktopProject {
  let program = moondesk_program()
  @desktop.DesktopProject::new(
    @lepusa.AppMetadata::new(
      identifier="dev.vectie.lepusa.examples.moondesk",
      product_name="MoonDesk",
      version="0.1.0",
    ),
    program.cell(),
  )
  .window(title="MoonDesk", width=1280, height=820, resizable=true)
  .with_plugin(program.plugin())
  .with_capability(program.capability_for_window())
  .with_registry(program.registry())
}

///|
fn encode_message(message : @moondesk.Message) -> String {
  message.to_json().stringify()
}

///|
fn decode_message(payload : String) -> Result[@moondesk.Message, String] {
  Ok(@json.from_json(@json.parse(payload))) catch {
    _ => Err("invalid MoonDesk message")
  }
}
