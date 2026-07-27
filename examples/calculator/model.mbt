///|
pub(all) enum Operator {
  Add
  Subtract
  Multiply
  Divide
} derive(Debug, Eq)

///|
pub fn Operator::symbol(self : Operator) -> String {
  match self {
    Add => "+"
    Subtract => "−"
    Multiply => "×"
    Divide => "÷"
  }
}

///|
pub(all) enum Message {
  Digit(Int)
  DecimalPoint
  ChooseOperator(Operator)
  Equals
  Clear
  ToggleSign
  Percent
} derive(Debug, Eq)

///|
pub struct Model {
  display : String
  accumulator : Double?
  pending : Operator?
  replace_input : Bool
  status : String
} derive(Debug, Eq)

///|
pub fn Model::initial() -> Model {
  {
    display: "0",
    accumulator: None,
    pending: None,
    replace_input: false,
    status: "",
  }
}

///|
pub fn Model::display(self : Model) -> String {
  self.display
}

///|
pub fn Model::status(self : Model) -> String {
  self.status
}

///|
pub fn Model::operation_label(self : Model) -> String {
  if self.status != "" {
    self.status
  } else {
    match (self.accumulator, self.pending) {
      (Some(value), Some(operator)) =>
        "\{format_number(value)} \{operator.symbol()}"
      _ => "MoonBit calculator"
    }
  }
}

///|
pub fn update(message : Message, model : Model) -> Model {
  match message {
    Digit(value) => model.push_digit(value)
    DecimalPoint => model.push_decimal_point()
    ChooseOperator(operator) => model.choose_operator(operator)
    Equals => model.evaluate()
    Clear => Model::initial()
    ToggleSign => model.toggle_sign()
    Percent => model.to_percent()
  }
}

///|
fn Model::has_error(self : Model) -> Bool {
  self.status != ""
}

///|
fn Model::numeric_value(self : Model) -> Double {
  let value : Double = @strconv.from_str(self.display) catch { _ => 0.0 }
  value
}

///|
fn Model::push_digit(self : Model, digit : Int) -> Model {
  if digit < 0 || digit > 9 {
    return self
  }
  let base = if self.has_error() || self.replace_input {
    "0"
  } else {
    self.display
  }
  let next = if base == "0" {
    digit.to_string()
  } else if base == "-0" {
    if digit == 0 {
      base
    } else {
      "-\{digit}"
    }
  } else if base.length() >= 16 {
    base
  } else {
    base + digit.to_string()
  }
  { ..self, display: next, replace_input: false, status: "" }
}

///|
fn Model::push_decimal_point(self : Model) -> Model {
  let base = if self.has_error() || self.replace_input {
    "0"
  } else {
    self.display
  }
  let next = if base.contains(".") { base } else { base + "." }
  { ..self, display: next, replace_input: false, status: "" }
}

///|
fn Model::toggle_sign(self : Model) -> Model {
  let base = if self.has_error() { Model::initial() } else { self }
  if base.replace_input {
    { ..base, display: "-0", replace_input: false }
  } else {
    let display = match base.display.strip_prefix("-") {
      Some(positive) => positive.to_owned()
      None => "-" + base.display
    }
    { ..base, display, }
  }
}

///|
fn Model::to_percent(self : Model) -> Model {
  if self.has_error() {
    self
  } else {
    {
      ..self,
      display: format_number(self.numeric_value() / 100.0),
      replace_input: false,
    }
  }
}

///|
fn Model::choose_operator(self : Model, next : Operator) -> Model {
  if self.has_error() {
    return self
  }
  if self.replace_input {
    return match self.accumulator {
      Some(_) => { ..self, pending: Some(next) }
      None =>
        { ..self, accumulator: Some(self.numeric_value()), pending: Some(next) }
    }
  }
  match (self.accumulator, self.pending) {
    (Some(left), Some(operator)) =>
      match calculate(operator, left, self.numeric_value()) {
        Ok(value) =>
          {
            ..self,
            display: format_number(value),
            accumulator: Some(value),
            pending: Some(next),
            replace_input: true,
          }
        Err(problem) => error_model(problem)
      }
    _ =>
      {
        ..self,
        accumulator: Some(self.numeric_value()),
        pending: Some(next),
        replace_input: true,
      }
  }
}

///|
fn Model::evaluate(self : Model) -> Model {
  if self.has_error() {
    return self
  }
  match (self.accumulator, self.pending) {
    (Some(left), Some(operator)) =>
      match calculate(operator, left, self.numeric_value()) {
        Ok(value) =>
          {
            ..self,
            display: format_number(value),
            accumulator: None,
            pending: None,
            replace_input: true,
          }
        Err(problem) => error_model(problem)
      }
    _ => self
  }
}

///|
fn error_model(problem : String) -> Model {
  {
    display: "Error",
    accumulator: None,
    pending: None,
    replace_input: true,
    status: problem,
  }
}

///|
fn calculate(
  operator : Operator,
  left : Double,
  right : Double,
) -> Result[Double, String] {
  if operator is Divide && right == 0.0 {
    return Err("Cannot divide by zero")
  }
  let result = match operator {
    Add => left + right
    Subtract => left - right
    Multiply => left * right
    Divide => left / right
  }
  if result.is_inf() || result.is_nan() {
    Err("Number is out of range")
  } else {
    Ok(result)
  }
}

///|
fn format_number(value : Double) -> String {
  value.to_string()
}
