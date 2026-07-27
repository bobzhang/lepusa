///|
test "calculator accepts integer and decimal input" {
  let mut model = @lepusa_calculator.Model::initial()
  model = @lepusa_calculator.update(Digit(1), model)
  model = @lepusa_calculator.update(Digit(2), model)
  model = @lepusa_calculator.update(DecimalPoint, model)
  model = @lepusa_calculator.update(Digit(5), model)
  assert_eq(model.display(), "12.5")
}

///|
test "calculator chains arithmetic operations" {
  let mut model = @lepusa_calculator.Model::initial()
  model = @lepusa_calculator.update(Digit(1), model)
  model = @lepusa_calculator.update(Digit(2), model)
  model = @lepusa_calculator.update(ChooseOperator(Add), model)
  model = @lepusa_calculator.update(Digit(3), model)
  model = @lepusa_calculator.update(Equals, model)
  assert_eq(model.display(), "15")
  model = @lepusa_calculator.update(ChooseOperator(Multiply), model)
  model = @lepusa_calculator.update(Digit(4), model)
  model = @lepusa_calculator.update(Equals, model)
  assert_eq(model.display(), "60")
}

///|
test "calculator reports division by zero and recovers on digit input" {
  let mut model = @lepusa_calculator.Model::initial()
  model = @lepusa_calculator.update(Digit(8), model)
  model = @lepusa_calculator.update(ChooseOperator(Divide), model)
  model = @lepusa_calculator.update(Digit(0), model)
  model = @lepusa_calculator.update(Equals, model)
  assert_eq(model.display(), "Error")
  assert_eq(model.status(), "Cannot divide by zero")
  model = @lepusa_calculator.update(Digit(7), model)
  assert_eq(model.display(), "7")
  assert_eq(model.status(), "")
}

///|
test "calculator supports sign and percent" {
  let mut model = @lepusa_calculator.Model::initial()
  model = @lepusa_calculator.update(Digit(5), model)
  model = @lepusa_calculator.update(ToggleSign, model)
  model = @lepusa_calculator.update(Percent, model)
  assert_eq(model.display(), "-0.05")
}
