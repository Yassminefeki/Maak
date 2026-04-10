#C:\Users\lenovo\Maak\backend\main.py
from fastapi import FastAPI, Depends, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from models import Base, engine, UserProfile
from crud import create_user_profile, get_user_profile
from schemas import UserProfileCreate, UserProfileResponse
from database import SessionLocal
import pytesseract
from PIL import Image
from io import BytesIO
import os
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

# Path to the Tesseract executable (Dynamic for CI/CD and Docker)
TESS_PATH = os.getenv("TESSERACT_PATH")
if not TESS_PATH:
    if os.name == 'nt': # Windows
        TESS_PATH = r"C:\\Program Files\\Tesseract-OCR\\tesseract.exe"
    else: # Linux/Docker
        TESS_PATH = "/usr/bin/tesseract"

pytesseract.pytesseract.tesseract_cmd = TESS_PATH

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
    y_pos = 750
    if "name" in filled_form:
        c.drawString(100, y_pos, f"Nom: {filled_form['name']}")
        y_pos -= 20
    if "address" in filled_form:
        c.drawString(100, y_pos, f"Adresse/Ville: {filled_form['address']}")
        y_pos -= 20
    if "dob" in filled_form:
        c.drawString(100, y_pos, f"Date de naissance: {filled_form['dob']}")
        y_pos -= 20
    if "phone" in filled_form:
        c.drawString(100, y_pos, f"Telephone: {filled_form['phone']}")
        y_pos -= 20
    if "cin" in filled_form:
        c.drawString(100, y_pos, f"CIN: {filled_form['cin']}")
        y_pos -= 20
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
    This function fills the form with the user's profile data,
    only for fields that were detected via OCR in the image.
    """
    extracted_text_lower = extracted_text.lower()
    filled_form = {}

    if "nom" in extracted_text_lower or "name" in extracted_text_lower:
        filled_form["name"] = user_profile.full_name
        
    if "ville" in extracted_text_lower or "adresse" in extracted_text_lower or "address" in extracted_text_lower:
        filled_form["address"] = user_profile.address
        
    if "date" in extracted_text_lower or "naissance" in extracted_text_lower or "dob" in extracted_text_lower:
        filled_form["dob"] = user_profile.dob
        
    if "tel" in extracted_text_lower or "téléphone" in extracted_text_lower or "phone" in extracted_text_lower:
        filled_form["phone"] = user_profile.phone
        
    if "cin" in extracted_text_lower or "carte" in extracted_text_lower:
        filled_form["cin"] = user_profile.cin

    return filled_form
