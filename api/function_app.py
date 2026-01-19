import azure.functions as func
import json
import logging
import os
from azure.cosmos import CosmosClient

# 1. Initialize the app with a lowercase route for better compatibility
app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="getresumecounter", methods=["GET", "POST"])
@app.cosmos_db_output(arg_name="outputDoc",
                      database_name="ResumeData",
                      container_name="CounterUnique",
                      connection="CosmosDbConnectionString")
def GetResumeCounter(req: func.HttpRequest, outputDoc: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('Processing unique visitor count.')

    # 2. Get Visitor ID from the request 
    visitor_id = req.params.get('visitorId')
    if not visitor_id:
        try:
            req_body = req.get_json()
            visitor_id = req_body.get('visitorId')
        except Exception:
            pass

    if not visitor_id:
        return func.HttpResponse("Missing visitorId", status_code=400)

    # 3. Create the unique visitor doc
    # Ensure partitionKey matches your Terraform configuration
    visitor_item = {
        "id": visitor_id,
        "partitionKey": "unique_visitors", 
        "lastVisit": "2026-01-19"          
    }

    # 4. Save/Update the visitor (Upsert)
    outputDoc.set(func.Document.from_dict(visitor_item))

    # 5. Connect to Cosmos and get count INSIDE the function 
    # This prevents the 404 if the connection fails on startup
    try:
        # Note: 'CosmosDbConnectionString' usually contains the key and endpoint. 
        # For this SDK call, we need the specific endpoint and key app settings.
        conn_str = os.environ.get("CosmosDbConnectionString")
        client = CosmosClient.from_connection_string(conn_str)
        database = client.get_database_client("ResumeData")
        container = database.get_container_client("CounterUnique")

        query = "SELECT VALUE COUNT(1) FROM c"
        # Enable cross-partition query since we are counting everything
        items = list(container.query_items(query=query, enable_cross_partition_query=True))
        unique_count = items[0] if items else 0
    except Exception as e:
        logging.error(f"Error querying CosmosDB: {str(e)}")
        # Fallback so the user sees something even if the query fails
        unique_count = "Error"

    return func.HttpResponse(
        json.dumps({"count": unique_count}),
        mimetype="application/json",
        status_code=200
    )