# Birthday Message Application

This project consists of a FastAPI backend, a Streamlit frontend, and a test suite, all containerized using Docker. This is a simple application that allows you to read from a postgres database records about people and and dates of birth. If the birthday falls on the same day as the current one, then there is a message with wishes. 

## Project Structure

- `main.py`: FastAPI backend application
- `streamlit_app.py`: Streamlit frontend application
- `test_birthday_api.py`: Test suite for the API
- `Dockerfile.fastapi`: Dockerfile for the FastAPI application
- `Dockerfile.streamlit`: Dockerfile for the Streamlit application
- `Dockerfile.test`: Dockerfile for running tests
- `requirements.txt`: Python dependencies
- `build_and_run_containers.sh`: Script to build and run Docker containers

## Prerequisites

- Docker
- Python 3.12 or later

## Setup

1. Clone the repository
2. Install opentofu and configure https://github.com/Maciej-Wasniewski/Interwiev/blob/main/opentofu/interview/backend.tf and https://github.com/Maciej-Wasniewski/Interwiev/blob/main/opentofu/interview/variables.tf (you need to change S3 bucket to keep state file, change dynamodb for session and change region for your AWS account) 
3. Install awscli and configure connection for your AWS account
4. Create infrastructure on AWS cloud using opentofu: "tofu init", "tofu plan", "tofu apply"
5. Run sql script https://github.com/Maciej-Wasniewski/Interwiev/blob/main/people.sql to create table on postgres RDS (must find a way to automate this)
6. 