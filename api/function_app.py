import azure.functions as func
import json
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="GetResumeCounter")
@app.cosmos_db_input(arg_name="inputDoc", 
                     database_name="ResumeData", 
                     container_name="Counter",
                     id="1",
                     partition_key="1",
                     connection="CosmosDbConnectionString")
@app.cosmos_db_output(arg_name="outputDoc",
                      database_name="ResumeData",
                      container_name="Counter",
                      connection="CosmosDbConnectionString")
def GetResumeCounter(req: func.HttpRequest, inputDoc: func.DocumentList, outputDoc: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # 1. Logic to handle if doc not present
    if not inputDoc:
        counter_item = {
            "id": "1",
            "count": 1
        }
    else:
        # 2. Increment existing counter
        counter_item = inputDoc[0]
        counter_item['count'] += 1

    # 3. Push the updated item to the db
    outputDoc.set(func.Document.from_dict(counter_item))

    # 4. Return the new count 
    return func.HttpResponse(
        json.dumps({"count": counter_item['count']}),
        mimetype="application/json",
        status_code=200
    )