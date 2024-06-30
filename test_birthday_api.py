import requests
import pytest
from datetime import date, timedelta

BASE_URL = "http://localhost:8000"

def test_save_user_valid_data():
    """Test saving a user with valid data."""
    username = "John"
    date_of_birth = (date.today() - timedelta(days=365*25)).isoformat()
    response = requests.put(f"{BASE_URL}/hello/{username}", json={"dateOfBirth": date_of_birth})
    assert response.status_code == 204

def test_save_user_invalid_name():
    """Test saving a user with an invalid name."""
    username = "John123"
    date_of_birth = (date.today() - timedelta(days=365*25)).isoformat()
    response = requests.put(f"{BASE_URL}/hello/{username}", json={"dateOfBirth": date_of_birth})
    assert response.status_code == 400
    assert "Name must contain only letters" in response.json()["detail"]

def test_save_user_future_date():
    """Test saving a user with a future birth date."""
    username = "Jane"
    date_of_birth = (date.today() + timedelta(days=1)).isoformat()
    response = requests.put(f"{BASE_URL}/hello/{username}", json={"dateOfBirth": date_of_birth})
    assert response.status_code == 400
    assert "Date of birth must be today or earlier" in response.json()["detail"]

def test_save_user_invalid_date_format():
    """Test saving a user with an invalid date format."""
    username = "Alice"
    date_of_birth = "2000/01/01"
    response = requests.put(f"{BASE_URL}/hello/{username}", json={"dateOfBirth": date_of_birth})
    assert response.status_code == 400
    assert "Invalid date format" in response.json()["detail"]

def test_get_birthday_message_existing_user():
    """Test getting a birthday message for an existing user."""
    username = "Bob"
    date_of_birth = (date.today() - timedelta(days=365*30)).isoformat()
    requests.put(f"{BASE_URL}/hello/{username}", json={"dateOfBirth": date_of_birth})
    
    response = requests.get(f"{BASE_URL}/hello/{username}")
    assert response.status_code == 200
    assert "Hello, Bob!" in response.json()["message"]

def test_get_birthday_message_nonexistent_user():
    """Test getting a birthday message for a non-existent user."""
    username = "NonexistentUser"
    response = requests.get(f"{BASE_URL}/hello/{username}")
    assert response.status_code == 404
    assert "User not found" in response.json()["detail"]

def test_get_birthday_message_today():
    """Test getting a birthday message on the user's birthday."""
    username = "Charlie"
    date_of_birth = date.today().isoformat()
    requests.put(f"{BASE_URL}/hello/{username}", json={"dateOfBirth": date_of_birth})
    
    response = requests.get(f"{BASE_URL}/hello/{username}")
    assert response.status_code == 200
    assert "Happy birthday!" in response.json()["message"]

@pytest.fixture(scope="session", autouse=True)
def cleanup():
    """Cleanup after all tests are run."""
    yield

if __name__ == "__main__":
    pytest.main([__file__])