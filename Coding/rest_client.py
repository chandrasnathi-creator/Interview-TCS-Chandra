import json
import logging
import requests
import argparse

# --- Configuration ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# --- Main Application Logic ---
def process_data(input_file, service_url):
    """
    Reads, filters, and posts data to a web service.
    """
    #1. Read and validate the JSON file
    logging.info(f"Reading data from '{input_file}'...")
    try:
        with open(input_file, 'r') as f:
            data = json.load(f)
        logging.info("Successfully parsed JSON file.")
    except FileNotFoundError:
        logging.error(f"Error: Input file not found at '{input_file}'.")
        return
    except json.JSONDecodeError:
        logging.error(f"Error: Could not decode JSON from '{input_file}'.")
        return
    except Exception as e:
        logging.error(f"An unexpected error occurred while reading the file: {e}")
        return

    #2. Modify the structure to only include public objects
    logging.info("Filtering for objects where 'private' is false...")
    public_data = {
        key: value
        for key, value in data.items()
        if isinstance(value, dict) and value.get("private") is False
    }

    if not public_data:
        logging.warning("No public objects found after filtering. Nothing to send.")
        return

    logging.info(f"Filtered data to be sent: {json.dumps(public_data, indent=2)}")

    #3. Make a REST POST call
    endpoint = f"{service_url}/service/generate"
    logging.info(f"Posting data to endpoint: {endpoint}")
    try:
        response = requests.post(endpoint, json=public_data, timeout=10)
        response.raise_for_status()
        logging.info("Successfully received response from the server.")
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to connect to the web service: {e}")
        return

    #4. Process the web server response
    try:
        response_data = response.json()
        logging.info("Processing server response...")
        
        valid_keys = []
        for key, obj in response_data.items():
            if isinstance(obj, dict) and obj.get("valid") is True:
                valid_keys.append(key)
        
        if valid_keys:
            print("\n--- Keys of valid objects from response ---")
            for key in valid_keys:
                print(key)
            print("-----------------------------------------")
        else:
            logging.info("No objects with 'valid: true' found in the response.")

    except json.JSONDecodeError:
        logging.error("Failed to decode JSON response from the server.")
    except Exception as e:
        logging.error(f"An unexpected error occurred while processing the response: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="A client to process JSON data and interact with a web service."
    )
    parser.add_argument(
        "--input-file",
        default="example.json",
        help="Path to the input JSON file."
    )
    parser.add_argument(
        "--service-url",
        default="https://mock-service.example.com",
        help="The base URL of the target web service."
    )
    args = parser.parse_args()

    process_data(args.input_file, args.service_url)