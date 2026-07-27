///|
fn calculator_view(
  emit : @ui.ViewEmit[@calculator.Message],
  model : @calculator.Model,
) -> @lepusa.Html {
  @ui.concat([
    calculator_styles(),
    @ui.div(
      [
        @ui.div(
          [
            @ui.p([@ui.text(model.operation_label())], attrs=[
              @ui.class_name("operation"),
            ]),
            @ui.element("output", [@ui.text(model.display())], attrs=[
              @ui.class_name("display"),
              @ui.aria("live", "polite"),
            ]),
          ],
          attrs=[@ui.class_name("screen")],
        ),
        @ui.div(
          [
            calculator_key(emit, "AC", Clear, kind="utility"),
            calculator_key(emit, "+/−", ToggleSign, kind="utility"),
            calculator_key(emit, "%", Percent, kind="utility"),
            calculator_key(emit, "÷", ChooseOperator(Divide), kind="operator"),
            calculator_key(emit, "7", Digit(7)),
            calculator_key(emit, "8", Digit(8)),
            calculator_key(emit, "9", Digit(9)),
            calculator_key(
              emit,
              "×",
              ChooseOperator(Multiply),
              kind="operator",
            ),
            calculator_key(emit, "4", Digit(4)),
            calculator_key(emit, "5", Digit(5)),
            calculator_key(emit, "6", Digit(6)),
            calculator_key(
              emit,
              "−",
              ChooseOperator(Subtract),
              kind="operator",
            ),
            calculator_key(emit, "1", Digit(1)),
            calculator_key(emit, "2", Digit(2)),
            calculator_key(emit, "3", Digit(3)),
            calculator_key(emit, "+", ChooseOperator(Add), kind="operator"),
            calculator_key(emit, "0", Digit(0), kind="zero"),
            calculator_key(emit, ".", DecimalPoint),
            calculator_key(emit, "=", Equals, kind="equals"),
          ],
          attrs=[@ui.class_name("keypad")],
        ),
        @ui.p([@ui.text("UI and state machine are written in MoonBit")], attrs=[
          @ui.class_name("footer"),
        ]),
      ],
      attrs=[@ui.class_name("calculator")],
    ),
  ])
}

///|
fn calculator_key(
  emit : @ui.ViewEmit[@calculator.Message],
  label : String,
  message : @calculator.Message,
  kind? : String = "number",
) -> @lepusa.Html {
  @ui.button(label, attrs=[@ui.class_name("key key-\{kind}"), emit(message)])
}

///|
fn calculator_styles() -> @lepusa.Html {
  let styles =
    #|<style>
    #|:root { color-scheme: dark; font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #121713; }
    #|* { box-sizing: border-box; }
    #|html, body { min-height: 100%; margin: 0; background: radial-gradient(circle at 50% -10%, #33443a 0, #1a211c 38%, #111512 100%); }
    #|body { display: grid; place-items: center; color: #f4f7f4; }
    #|#lepusa-root { width: 100%; }
    #|.calculator { width: min(100%, 430px); min-height: 100vh; margin: 0 auto; padding: 38px 24px 24px; display: flex; flex-direction: column; justify-content: flex-end; gap: 26px; }
    #|.screen { min-height: 168px; padding: 24px 12px 12px; display: flex; flex-direction: column; align-items: flex-end; justify-content: flex-end; overflow: hidden; }
    #|.operation { min-height: 24px; margin: 0 4px 12px; color: #9aaa9f; font-size: 14px; font-weight: 650; letter-spacing: .04em; }
    #|.display { width: 100%; overflow: hidden; color: #f8fbf8; font-size: clamp(56px, 16vw, 78px); font-weight: 350; line-height: 1; letter-spacing: -.055em; text-align: right; text-overflow: ellipsis; white-space: nowrap; font-variant-numeric: tabular-nums; }
    #|.keypad { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
    #|.key { min-height: 72px; border: 0; border-radius: 24px; color: #f7faf7; background: #2b332d; font: inherit; font-size: 27px; font-weight: 560; cursor: pointer; box-shadow: inset 0 1px rgba(255,255,255,.04), 0 8px 18px rgba(0,0,0,.14); transition: transform 120ms ease, filter 120ms ease; }
    #|.key:hover { filter: brightness(1.12); transform: translateY(-1px); }
    #|.key:active { filter: brightness(.9); transform: translateY(1px) scale(.98); }
    #|.key-utility { color: #172019; background: #aebbb1; font-size: 21px; font-weight: 720; }
    #|.key-operator, .key-equals { background: #e68b37; color: #fffaf4; }
    #|.key-zero { grid-column: span 2; text-align: left; padding-left: 30px; }
    #|.footer { margin: -8px 0 0; color: #6f7d73; font-size: 11px; letter-spacing: .04em; text-align: center; }
    #|@media (max-height: 650px) { .calculator { padding-top: 20px; gap: 14px; } .screen { min-height: 120px; } .key { min-height: 58px; } }
    #|@media (prefers-reduced-motion: reduce) { .key { transition: none; } }
    #|</style>
  @ui.raw(styles)
}
