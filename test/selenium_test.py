# from selenium import webdriver
# from selenium.webdriver.chrome.service import Service
# from selenium.webdriver.chrome.options import Options
# from webdriver_manager.chrome import ChromeDriverManager

# chrome_options = Options()
# chrome_options.add_argument("--headless")  # Run in headless mode
# chrome_options.add_argument("--no-sandbox")
# chrome_options.add_argument("--disable-dev-shm-usage")

# service = Service(ChromeDriverManager().install())
# driver = webdriver.Chrome(service=service, options=chrome_options)

# driver.get("http://localhost:8080")

# # Wait for the title element to be visible or page to fully load
# WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "title")))

# # Now assert the title
# print(f"Page title is: {repr(driver.title)}")
# assert "CliXX Retail! Best Products On The Market" in driver.title.replace('\n', '').replace('\r', '').strip()
# driver.quit()

# from webdriver_manager.chrome import ChromeDriverManager
# from selenium import webdriver
# from selenium.webdriver.chrome.service import Service
# from selenium.webdriver.chrome.options import Options
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC

# # Configure Chrome options
# chrome_options = Options()
# chrome_options.headless = False
# #chrome_options.add_argument("--headless")  # Run Chrome in headless mode
# chrome_options.add_argument("--no-sandbox")  # Required for CI/CD environments
# chrome_options.add_argument("--disable-dev-shm-usage")  # Prevent memory issues

# # Initialize WebDriver with Chrome options
# service = Service()  # You can specify a chromedriver path if needed
# driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)

# # Navigate to the page
# driver.get("http://localhost:8080")

# # Wait for the page title
# WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "title")))

# # Print and verify the page title
# print(f"Page title is: {repr(driver.title)}")
# assert "CliXX Retail! Best Products On The Market" in driver.title.replace('\n', '').replace('\r', '').strip()

# # Close the driver
# driver.quit()



from webdriver_manager.chrome import ChromeDriverManager
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Configure Chrome options
chrome_options = Options()
chrome_options.headless = False  # Set to True for CI/CD, False for debugging
chrome_options.add_argument("--no-sandbox")  # Required for CI/CD environments
chrome_options.add_argument("--disable-dev-shm-usage")  # Prevent memory issues
chrome_options.add_argument("--user-data-dir=/tmp/selenium-user-data")  # Prevent profile lock
chrome_options.add_argument("--remote-debugging-port=9222")  # Allow debugging

# Initialize WebDriver with Chrome options
service = Service(ChromeDriverManager().install())  # Use Service explicitly
driver = webdriver.Chrome(service=service, options=chrome_options)

# Navigate to the page
driver.get("http://localhost:8080")

# Wait for the page title
WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "title")))

# Print and verify the page title
print(f"Page title is: {repr(driver.title)}")
assert "CliXX Retail! Best Products On The Market" in driver.title.replace('\n', '').replace('\r', '').strip()

# Close the driver
driver.quit()
