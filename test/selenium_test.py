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
driver.get("http://172.17.0.2")

# Print the page source for debugging
print("Page Source:\n", driver.page_source[:500])  # Print only the first 500 characters

try:
    WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
    print("Page title is:", driver.title)
except Exception as e:
    print("Title not found!", str(e))

driver.quit()
