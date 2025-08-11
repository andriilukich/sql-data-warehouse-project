# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀  
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

## 📌 Project Requirements

### Building the Data Warehouse (Data Engineering)

**Objective**  
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

**Specifications**

- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

## 🗂 Project Board

You can view the project's task board and progress tracking on Notion:

**🔗 [Data Warehouse Project – Task & Ticket Board](https://www.notion.so/Data-Warehouse-Project-2463a5ddcc3d8010bea7f634bd6522b5?source=copy_link)**

This board includes all relevant development tasks, milestones, and documentation for the Data Warehouse and Analytics Project.

---

## 🧱 Data Architecture
### High Level Architecture
The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

![High Level Architecture](https://i.postimg.cc/wMPwM11M/Screenshot-2025-08-06-at-9-05-58-AM.png)

- **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
- **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
- **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

### Data Consumption
- **BI & Reporting**
- **Ad-Hoc SQL Queries**
- **Machine Learning**

---

## 🚀 Getting Started

### Prerequisites
- Docker and Docker Compose installed
- Git (for cloning the repository)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sql-data-warehouse-project
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file and set your secure database password:
   ```bash
   MSSQL_SA_PASSWORD=your_secure_password_here
   ```

3. **Start the services**
   ```bash
   docker-compose up -d
   ```

4. **Verify the setup**
   The SQL Server will be available at `localhost:1433`

### Security Note
- The `.env` file contains sensitive credentials and is excluded from version control
- Never commit actual passwords to the repository
- Use the `.env.example` file as a template for required environment variables

---

### BI: Analytics & Reporting (Data Analytics)

**Objective**  
Develop SQL-based analytics to deliver detailed insights into:

- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

## 🛡 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). You are free to use, modify, and share this project with proper attribution.

---

## 🌟 About Me

Hi there! I'm **Baraa Khatib Salkini**, also known as **Data With Baraa**. I'm an IT professional and passionate YouTuber on a mission to share knowledge and make working with data enjoyable and engaging!
