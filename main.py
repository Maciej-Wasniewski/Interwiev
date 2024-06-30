import os
from datetime import date, datetime
import re

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, constr
from sqlalchemy import create_engine, Column, Integer, String, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker


app = FastAPI()

# Database configuration
DB_USER = os.getenv("DB_USER", "placeforcredentials")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "interview-database.c6w2clm2o6mk.eu-central-1.rds.amazonaws.com")
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/postgres"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

@app.get("/")
async def root():
    return {"message": "Hello World"}

class Person(Base):
    """
    SQLAlchemy model for the 'people' table.
    """
    __tablename__ = "people"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    birth_day = Column(Date, nullable=False)

class UserInput(BaseModel):
    """
    Pydantic model for user input validation.
    """
    dateOfBirth: str

def validate_name(name: str):
    """
    Validate that the name contains only letters.

    Args:
        name (str): The name to validate.

    Raises:
        HTTPException: If the name contains non-letter characters.
    """
    if not re.match("^[a-zA-Z]+$", name):
        raise HTTPException(status_code=400, detail="Name must contain only letters")

def validate_date(date_str: str):
    """
    Validate that the date is in the correct format and not in the future.

    Args:
        date_str (str): The date string to validate.

    Returns:
        date: The validated date object.

    Raises:
        HTTPException: If the date is invalid or in the future.
    """
    try:
        birth_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        if birth_date > date.today():
            raise HTTPException(status_code=400, detail="Date of birth must be today or earlier")
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
    return birth_date

@app.put("/hello/{username}", status_code=204)
async def save_user(username: str, user_input: UserInput):
    """
    Save or update a user's birthday.

    Args:
        username (str): The name of the user.
        user_input (UserInput): The user's date of birth.

    Returns:
        dict: A message indicating successful save.

    Raises:
        HTTPException: If the input data is invalid.
    """
    validate_name(username)
    birth_date = validate_date(user_input.dateOfBirth)
    
    db = SessionLocal()
    person = db.query(Person).filter(Person.name == username).first()
    
    if person:
        person.birth_day = birth_date
    else:
        person = Person(name=username, birth_day=birth_date)
        db.add(person)
    
    db.commit()
    db.close()
    
    return {"status_code": 204, "detail": "User saved successfully"}

@app.get("/hello/{username}")
async def get_birthday_message(username: str):
    """
    Get a birthday message for the user.

    Args:
        username (str): The name of the user.

    Returns:
        dict: A message about the user's birthday.

    Raises:
        HTTPException: If the user is not found or the name is invalid.
    """
    validate_name(username)
    
    db = SessionLocal()
    person = db.query(Person).filter(Person.name == username).first()
    db.close()
    
    if not person:
        raise HTTPException(status_code=404, detail="User not found")
    
    today = date.today()
    next_birthday = date(today.year, person.birth_day.month, person.birth_day.day)
    if next_birthday < today:
        next_birthday = date(today.year + 1, person.birth_day.month, person.birth_day.day)
    
    days_until_birthday = (next_birthday - today).days
    
    if days_until_birthday == 0:
        return {"message": f"Hello, {username}! Happy birthday!"}
    else:
        return {"message": f"Hello, {username}! Your birthday is in {days_until_birthday} day(s)"}