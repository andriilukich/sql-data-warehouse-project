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

## 🧱 Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

### High Level Architecture

![High Level Architecture](link-to-image-if-hosted)

**Sources**:  
- CRM and ERP systems  
- **Object Type**: CSV Files  
- **Interface**: Files in Folders

---

### Bronze Layer
- **Object Type**: Tables  
- **Load**:  
  - Batch Processing  
  - Full Load  
  - Truncate & Insert  
- **Transformations**: None  
- **Data Model**: None (as-is)  
- **Description**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.

---

### Silver Layer
- **Object Type**: Tables  
- **Load**:  
  - Batch Processing  
  - Full Load  
  - Truncate & Insert  
- **Transformations**:  
  - Data Cleansing  
  - Data Standardization  
  - Data Normalization  
  - Derived Columns  
  - Data Enrichment  
- **Data Model**: None (as-is)  
- **Description**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.

---

### Gold Layer
- **Object Type**: Views  
- **Load**: No Load  
- **Transformations**:  
  - Data Integrations  
  - Aggregations  
  - Business Logics  
- **Data Model**:  
  - Star Schema  
  - Flat Table  
  - Aggregated Table  
- **Description**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

### Data Consumption
- **BI & Reporting**
- **Ad-Hoc SQL Queries**
- **Machine Learning**

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
