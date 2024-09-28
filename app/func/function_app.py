import logging
import azure.functions as func


app = func.FunctionApp()

# @app.function_name(name="eventGridTrigger")
# @app.event_grid_trigger(arg_name="event")
# def event_grid_trigger(event: func.EventGridEvent):
#     """Process an event grid trigger for a new blob in the container."""
#     logging.info("Processing event %s", event.id)

@app.function_name(name="eventGridTrigger01")
@app.event_grid_trigger(arg_name="event")
def event_grid_trigger(event: func.EventGridEvent):
    """Process an event grid trigger for a new blob in the container."""
    logging.info("Processing event %s", event.id)

@app.schedule(schedule="0 */5 * * * *", arg_name="myTimer", run_on_startup=True,
              use_monitor=False)
def myazfunction(myTimer: func.TimerRequest) -> None:
    logging.info('Python timer trigger function starting.')