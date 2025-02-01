from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Set up Chrome options
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run in headless mode
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

# Start WebDriver
service = Service()
driver = webdriver.Chrome(service=service, options=chrome_options)

# Open the page
driver.get("http://localhost:8080")

# ✅ Wait for the title to be non-empty
WebDriverWait(driver, 10).until(lambda d: d.title.strip() != "")

# ✅ Get the title
page_title = driver.title.strip()
print(f"Page title is: {repr(page_title)}")  # Print the actual title for debugging

# ✅ Check title with expected format
assert "CliXX Retail! Best Products On The Market" in page_title.replace("\n", "").replace("\r", "")

# Close WebDriver
driver.quit()
