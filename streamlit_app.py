import streamlit as st
import requests
from datetime import date


API_URL = "http://localhost:8000"

def validate_date(date_string: str) -> bool:
    """
    Validate if the given date string is in correct format and is in the past.

    Args:
        date_string (str): Date string in format 'YYYY-MM-DD'.

    Returns:
        bool: True if date is valid and in the past, False otherwise.
    """
    try:
        year, month, day = map(int, date_string.split('-'))
        input_date = date(year, month, day)
        if input_date >= date.today():
            return False
        return True
    except ValueError:
        return False

def save_user_page():
    """
    Render the page for saving a new user or updating an existing user's birthday.

    This page includes input fields for username and date of birth,
    and a button to submit the data to the API.
    """
    st.header("Save User")
    
    username = st.text_input("Enter username")
    date_of_birth = st.date_input("Enter date of birth", min_value=date(1900, 1, 1), max_value=date.today())
    
    if st.button("Save User"):
        if username and date_of_birth:
            response = requests.put(
                f"{API_URL}/hello/{username}",
                json={"dateOfBirth": date_of_birth.isoformat()}
            )
            if response.status_code == 204:
                st.success(f"User {username} saved successfully!")
            else:
                st.error(f"Error saving user: {response.text}")
        else:
            st.warning("Please enter both username and date of birth.")

def get_birthday_message_page():
    """
    Render the page for retrieving a user's birthday message.

    This page includes an input field for the username and a button
    to fetch the birthday message from the API.
    """
    st.header("Get Birthday Message")
    
    username = st.text_input("Enter username")
    
    if st.button("Get Message"):
        if username:
            response = requests.get(f"{API_URL}/hello/{username}")
            if response.status_code == 200:
                message = response.json()["message"]
                st.success(message)
            elif response.status_code == 404:
                st.warning("User not found.")
            else:
                st.error(f"Error getting message: {response.text}")
        else:
            st.warning("Please enter a username.")

def main():
    """
    Main function to run the Streamlit application.

    This function sets up the page layout and navigation,
    and renders the appropriate page based on user selection.
    """
    st.title("Birthday App")

    page = st.sidebar.selectbox("Choose a page", ["Save User", "Get Birthday Message"])

    if page == "Save User":
        save_user_page()
    elif page == "Get Birthday Message":
        get_birthday_message_page()

if __name__ == "__main__":
    main()