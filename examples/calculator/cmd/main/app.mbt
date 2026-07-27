///|
fn calculator_program() -> @ui.UiProgram[@calculator.Model, @calculator.Message] {
  @ui.UiProgram::new(
    model=@calculator.Model::initial(),
    update=fn(message, model) {
      (@calculator.update(message, model), @lepusa.none)
    },
    view=calculator_view,
    encode=encode_message,
    decode=decode_message,
    route="calculator.dispatch",
    render_event="calculator.render",
  )
}

///|
fn calculator_project() -> @desktop.DesktopProject {
  let program = calculator_program()
  @desktop.DesktopProject::new(
    @lepusa.AppMetadata::new(
      identifier="dev.vectie.lepusa.examples.calculator",
      product_name="MoonBit Calculator",
      version="0.1.0",
    ),
    program.cell(),
  )
  .window(title="MoonBit Calculator", width=430, height=700, resizable=true)
  .with_plugin(program.plugin())
  .with_capability(program.capability_for_window())
  .with_registry(program.registry())
}

///|
fn encode_message(message : @calculator.Message) -> String {
  match message {
    Digit(value) => "{\"kind\":\"digit\",\"value\":\{value}}"
    DecimalPoint => "{\"kind\":\"decimal\"}"
    ChooseOperator(Add) => "{\"kind\":\"operator\",\"value\":\"add\"}"
    ChooseOperator(Subtract) => "{\"kind\":\"operator\",\"value\":\"subtract\"}"
    ChooseOperator(Multiply) => "{\"kind\":\"operator\",\"value\":\"multiply\"}"
    ChooseOperator(Divide) => "{\"kind\":\"operator\",\"value\":\"divide\"}"
    Equals => "{\"kind\":\"equals\"}"
    Clear => "{\"kind\":\"clear\"}"
    ToggleSign => "{\"kind\":\"toggle-sign\"}"
    Percent => "{\"kind\":\"percent\"}"
  }
}

///|
fn decode_message(payload : String) -> Result[@calculator.Message, String] {
  match payload {
    "{\"kind\":\"digit\",\"value\":0}" => Ok(Digit(0))
    "{\"kind\":\"digit\",\"value\":1}" => Ok(Digit(1))
    "{\"kind\":\"digit\",\"value\":2}" => Ok(Digit(2))
    "{\"kind\":\"digit\",\"value\":3}" => Ok(Digit(3))
    "{\"kind\":\"digit\",\"value\":4}" => Ok(Digit(4))
    "{\"kind\":\"digit\",\"value\":5}" => Ok(Digit(5))
    "{\"kind\":\"digit\",\"value\":6}" => Ok(Digit(6))
    "{\"kind\":\"digit\",\"value\":7}" => Ok(Digit(7))
    "{\"kind\":\"digit\",\"value\":8}" => Ok(Digit(8))
    "{\"kind\":\"digit\",\"value\":9}" => Ok(Digit(9))
    "{\"kind\":\"decimal\"}" => Ok(DecimalPoint)
    "{\"kind\":\"operator\",\"value\":\"add\"}" => Ok(ChooseOperator(Add))
    "{\"kind\":\"operator\",\"value\":\"subtract\"}" =>
      Ok(ChooseOperator(Subtract))
    "{\"kind\":\"operator\",\"value\":\"multiply\"}" =>
      Ok(ChooseOperator(Multiply))
    "{\"kind\":\"operator\",\"value\":\"divide\"}" => Ok(ChooseOperator(Divide))
    "{\"kind\":\"equals\"}" => Ok(Equals)
    "{\"kind\":\"clear\"}" => Ok(Clear)
    "{\"kind\":\"toggle-sign\"}" => Ok(ToggleSign)
    "{\"kind\":\"percent\"}" => Ok(Percent)
    _ => Err("unknown calculator message: \{payload}")
  }
}
