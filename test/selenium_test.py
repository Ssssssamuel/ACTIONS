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


from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Initialize WebDriver
driver = webdriver.Chrome()  # Or any other driver you're using

# Navigate to the page
driver.get("http://localhost:8080")

# Wait for the title element to be visible or page to fully load
WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "title")))

# Print the title
print(f"Page title is: {repr(driver.title)}")

# Now check if the title is as expected
assert "CliXX Retail! Best Products On The Market" in driver.title.replace('\n', '').replace('\r', '').strip()

# Close the driver after the test
driver.quit()
