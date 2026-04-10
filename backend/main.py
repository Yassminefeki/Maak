#C:\Users\lenovo\Maak\backend\main.py
from fastapi import FastAPI, Depends, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from .models import Base, engine, UserProfile
from .crud import create_user_profile, get_user_profile
from .schemas import UserProfileCreate, UserProfileResponse
from .database import SessionLocal
import pytesseract
from PIL import Image
from io import BytesIO
from fastapi.middleware.cors import CORSMiddleware
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows CORS for specified origins
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize database (create tables)
Base.metadata.create_all(bind=engine)

# Dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/register_user/")
async def register_user(user: UserProfileCreate, db: Session = Depends(get_db)):
    return await create_user_profile(user, db)


# Root endpoint for testing
@app.get("/")
async def read_root():
    return {"message": "Welcome to FastAPI!"}

# Endpoint to retrieve user profile data

@app.get("/get_user_profile/{user_id}")
async def get_user_profile_data(user_id: int, db: Session = Depends(get_db)):
    # Await the async function get_user_profile
    db_user = get_user_profile(user_id, db)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


# POST endpoint to add user profile
@app.post("/user_profiles/", response_model=UserProfileResponse)
async def add_user_profile(user: UserProfileCreate, db: Session = Depends(get_db)):
    return await create_user_profile(user, db)

# Path to the Tesseract executable
pytesseract.pytesseract.tesseract_cmd = r"C:\\Program Files\\Tesseract-OCR\\tesseract.exe"  

@app.post("/scan_form/")
async def scan_form(file: UploadFile = File("C:\\Users\\lenovo\\OneDrive\\Bureau\\master faster\\وقت لاختبار OCR!.png")):
    try:
        # Read image file
        image_data = await file.read()
        image = Image.open(BytesIO(image_data))

        # Use Tesseract to extract text from the image
        extracted_text = pytesseract.image_to_string(image)

        # Map extracted text to user profile fields (customize this logic)
        user_profile = map_extracted_text_to_profile(extracted_text)

        # Return the mapped user profile or save it to the database
        return {"user_profile": user_profile}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")


def map_extracted_text_to_profile(extracted_text: str):
    """
    This function takes the OCR-extracted text and maps it to user profile fields.
    You can use regex or string manipulation to extract specific fields.
    """
    profile_data = {
        "full_name": extract_field(extracted_text, "Name"),
        "address": extract_field(extracted_text, "Address"),
        "dob": extract_field(extracted_text, "Date of Birth"),
        "phone": extract_field(extracted_text, "Phone"),
        "cin": extract_field(extracted_text, "CIN")
    }
    return profile_data


def extract_field(text: str, field_name: str):
    """
    Extracts a specific field from the OCR extracted text.
    You can refine this function with regular expressions or more complex logic.
    """
    lines = text.split("\n")
    for line in lines:
        if field_name.lower() in line.lower():
            return line.split(":")[-1].strip()  # Assumes field value is after a colon
    return "Not found"

# Function to generate a print-ready PDF
def generate_pdf(filled_form):
    c = canvas.Canvas("filled_form.pdf", pagesize=letter)
    c.drawString(100, 750, f"Name: {filled_form['name']}")
    c.drawString(100, 730, f"Address: {filled_form['address']}")
    c.drawString(100, 710, f"DOB: {filled_form['dob']}")
    c.drawString(100, 690, f"Phone: {filled_form['phone']}")
    c.drawString(100, 670, f"CIN: {filled_form['cin']}")
    c.save()

@app.post("/auto_fill_form/{user_id}")
async def auto_fill_form(user_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):

    user_profile = get_user_profile(user_id, db)
    if not user_profile:
        raise HTTPException(status_code=404, detail="User not found")

    try:
        # Read the uploaded form image
        image_data = await file.read()
        image = Image.open(BytesIO(image_data))

        # Use Tesseract OCR to extract text from the form image
        extracted_text = pytesseract.image_to_string(image)

        # Auto-fill form fields using the user profile data
        filled_form = fill_form_with_user_data(extracted_text, user_profile)

        pdf_path = "filled_form.pdf"
        generate_pdf(filled_form)  # Save the filled form as a PDF

        # Return the filled form (could be a JSON response or generate a filled PDF)
        return filled_form

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing form: {str(e)}")


def fill_form_with_user_data(extracted_text, user_profile):
    """
    This function fills the form (extracted text or fields) with the user's profile data.
    """
    filled_form = {
        "name": user_profile.full_name,  # Access the attributes directly
        "address": user_profile.address,
        "dob": user_profile.dob,
        "phone": user_profile.phone,
        "cin": user_profile.cin
    }

    # You could process the extracted_text further to match it with these fields.
    # Optionally, use regular expressions to better extract specific fields from OCR text.

    return filled_form