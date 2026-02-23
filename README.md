# Newity Compliance Assessment App

This is a Ruby on Rails application developed for the compliance team. It provides a comprehensive dashboard for reviewers to manage their compliance queue, prioritize tasks, and track capacity.

## Key Features
- **Compliance Dashboard:** Visual overview of pending, flagged, and overdue tasks, alongside reviewer capacity metrics.
- **Task Management:** Create, assign, edit, and track compliance reviews for specific applications.
- **Audit Trails:** Built-in auditing using PaperTrail to safely track changes to compliance reviews.
- **Authentication:** Secure user login and authorization system.
- **Modern UI:** Styled with Tailwind CSS for a clean, responsive, and robust interface.

## Tech Stack
- **Ruby:** 4.0.1
- **Rails:** 8.0.4
- **Database:** SQLite3
- **Frontend:** HTML, Tailwind CSS, Hotwire (Turbo & Stimulus)
- **Background Jobs:** Solid Queue
- **Caching:** Solid Cache

## Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd newity_compliance
   ```

2. **Install dependencies:**
   Ensure you have Ruby 4.0.1 installed, then run:
   ```bash
   bundle install
   ```

3. **Setup the database and run the initial seed of the CSV:**
   This command creates the database, schema, and imports the `sample_data_c_compliance_queue.csv` into the database, transforming the notes column into standard comments:
   ```bash
   bin/rails db:setup
   ```
   *Note: If you ever need to wipe the test and development data and re-import from the CSV, simply run `bin/rails db:drop db:setup`.*

4. **Start the Rails server:**
   Use the `dev` script to start Puma and Tailwind watch components:
   ```bash
   bin/dev
   ```

5. **Access the application:**
   Open a browser and navigate to `http://localhost:3000`

## Testing

Minitest is configured for models, controllers, and system tests alongside Capybara and Selenium.

To run the test suite:
```bash
bin/rails test
bin/rails test:system
```
