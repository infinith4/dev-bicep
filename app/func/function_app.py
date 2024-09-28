import logging
import azure.functions as func


app = func.FunctionApp()

@app.function_name(name="eventGridTrigger")
@app.event_grid_trigger(arg_name="event")
def event_grid_trigger(event: func.EventGridEvent):
    """Process an event grid trigger for a new blob in the container."""
    logging.info("Processing event %s", event.id)

@app.function_name(name="eventGridTrigger01")
@app.event_grid_trigger(arg_name="event")
def event_grid_trigger(event: func.EventGridEvent):
    """Process an event grid trigger for a new blob in the container."""
    logging.info("Processing event %s", event.id)