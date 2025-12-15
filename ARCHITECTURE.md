# Architecture Overview – Automated Database Backup and Recovery on Google Cloud

## Purpose of This Document

This document explains the system architecture of the project at a high level.  
It is intended for reviewers and recruiters who want to understand **how the system works**, **why it was designed this way**, and **how reliability and recovery are achieved**, without needing to read infrastructure code.

---

## High-Level Goal

The goal of this system is to ensure that application data remains **recoverable and protected** in the event of failures such as infrastructure outages, accidental data loss, or operational errors.

This is achieved by:
- Running the application on managed, serverless infrastructure
- Using a highly available managed database
- Automating database backups
- Storing backup artifacts securely and independently
- Verifying that backups are usable for recovery

---

## Architecture Summary (30-Second Explanation)

The application runs in a serverless environment on Google Cloud and uses a managed PostgreSQL database configured for high availability. A scheduled background job automatically exports the database on a regular basis and stores compressed backup files in cloud storage. All permissions are handled through service identities rather than credentials, and all infrastructure is defined as code. The backup process is validated end-to-end to ensure data can be restored if needed.

---

## Logical Architecture Diagram 

                          ┌──────────────────────────┐
                          │        End Users         │
                          └─────────────┬────────────┘
                                        │
                                        ▼
                          ┌──────────────────────────┐
                          │   Global Load Routing    │
                          │ (Traffic Distribution)   │
                          └─────────────┬────────────┘
                                        │
                                        ▼
                          ┌──────────────────────────┐
                          │   Serverless Application │
                          │      (Cloud Run)         │
                          └─────────────┬────────────┘
                                        │
                                        ▼
            ┌────────────────────────────────────────────────┐
            │        Managed PostgreSQL Database             │
            │           (High Availability)                  │
            └───────────────────┬────────────────────────────┘
                                │
                                │  Automated Export
                                │
    ┌───────────────────────────▼──────────────────────────┐
    │                Scheduled Backup Workflow             │
    │                                                      │
    │   ┌───────────────┐        ┌───────────────────────┐ │
    │   │   Scheduler   │ ─────▶ │  Background Job       │ │
    │   │ (Time-based)  │        │  (Containerized Task) │ │
    │   └───────────────┘        └───────────┬───────────┘ │
    │                                        │             │
    │                                        ▼             │
    │                        ┌───────────────────────────┐ │
    │                        │   Database Export Process │ │
    │                        └───────────┬───────────────┘ │
    └────────────────────────────────────┼─────────────────┘
                                         │
                                         ▼
                          ┌──────────────────────────┐
                          │    Secure Cloud Storage  │
                          │   (Database Backups)     │
                          └──────────────────────────┘

---

## Component Responsibilities

### Serverless Application
- Handles application requests
- Scales automatically based on traffic
- Does not manage infrastructure directly

### Managed PostgreSQL Database
- Stores application data
- Configured for high availability
- Supports automated exports for backup purposes

### Background Backup Job
- Runs inside a container
- Executes database export commands
- Fails fast if errors occur
- Produces logs for observability

### Scheduler
- Triggers the backup job automatically
- Ensures backups happen consistently without manual intervention

### Cloud Storage
- Stores compressed database backup files
- Isolated from the database runtime
- Used as the recovery source in case of data loss

### Identity and Access Management
- Uses service accounts instead of credentials
- Grants minimum required permissions
- Separates application access from backup access

---

## Why This Architecture Was Chosen

- **Serverless components** reduce operational overhead
- **Managed database services** provide built-in resilience
- **Automated backups** eliminate human error
- **Independent storage** ensures backups survive database failures
- **Infrastructure as code** enables repeatability and auditability
- **Explicit validation** ensures backups are not just created, but usable

---

## Recovery Model

In the event of data loss or database failure:
1. A backup file is selected from cloud storage
2. The restore script imports the backup into a new or existing database instance
3. The application reconnects to the restored database

This provides a clear and tested recovery path.

---

## What This Demonstrates

- System design thinking rather than tool usage
- Understanding of real-world failure scenarios
- Secure automation of operational workflows
- Practical experience with cloud identity and permissions
- Ability to design for reliability and recovery

---

## Notes

This document intentionally avoids low-level commands and focuses on architectural intent.  
Detailed setup and deployment steps are available in separate documentation for engineers who want to reproduce the environment.

