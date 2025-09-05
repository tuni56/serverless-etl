# Serverless ETL — AWS Lambda + Step Functions + EventBridge (Terraform-ready)

> Serverless ETL pipeline designed to process millions of events per day.  
> Orchestration with Step Functions. Ingestion via EventBridge. Transformations in AWS Lambda. Infrastructure as Code with Terraform.

---

## Overview
This repository contains a production-grade serverless ETL pipeline.  
EventBridge ingests events from APIs, S3 uploads, and scheduled triggers.  
Step Functions orchestrates a state machine that runs modular Lambdas for validation, enrichment, transformation, and loading.  
The final curated dataset is stored in S3. All components are deployable with reusable Terraform modules.

---

## Problem
The business needed to:
- Handle highly variable workloads (50K events per hour up to 5M+ during peak hours).  
- Operate without a dedicated DevOps team.  
- Guarantee traceability, modularity, and strict SLAs on freshness and reliability.  
- Avoid managing EC2, containers, or batch servers.

---

## Goals
1. Fully serverless architecture.  
2. Multi-step orchestration with retries and timeouts.  
3. Automatic scaling for millions of daily events.  
4. Reproducible deployments with Terraform.  
5. Observability and fault tolerance (DLQ, idempotency).

---

# Serverless ETL — AWS Lambda + Step Functions + EventBridge (Terraform-ready)

> Serverless ETL pipeline designed to process millions of events per day.  
> Orchestration with Step Functions. Ingestion via EventBridge. Transformations in AWS Lambda. Infrastructure as Code with Terraform.

---

## Overview
This repository contains a production-grade serverless ETL pipeline.  
EventBridge ingests events from APIs, S3 uploads, and scheduled triggers.  
Step Functions orchestrates a state machine that runs modular Lambdas for validation, enrichment, transformation, and loading.  
The final curated dataset is stored in S3. All components are deployable with reusable Terraform modules.

---

## Problem
The business needed to:
- Handle highly variable workloads (50K events per hour up to 5M+ during peak hours).  
- Operate without a dedicated DevOps team.  
- Guarantee traceability, modularity, and strict SLAs on freshness and reliability.  
- Avoid managing EC2, containers, or batch servers.

---

## Goals
1. Fully serverless architecture.  
2. Multi-step orchestration with retries and timeouts.  
3. Automatic scaling for millions of daily events.  
4. Reproducible deployments with Terraform.  
5. Observability and fault tolerance (DLQ, idempotency).

---

## Architecture diagram

![1_Vx2pzdxsLXKhMLQUSHAMMw](https://github.com/user-attachments/assets/94203377-07c7-4ca3-91bc-9dee2e522fbf)

---

## Workflow
1. **Ingestion**  
   Events arrive from multiple sources into EventBridge. Scheduled rules (cron) also trigger flows.  

2. **Trigger**  
   EventBridge starts the Step Functions state machine.  

3. **Processing (Step Functions)**  
   - **Validate**: schema validation and idempotency checks (S3 flag).  
   - **Enrich**: fetches additional data from external APIs.  
   - **Transform**: normalizes timestamps, flattens payloads, prepares curated record.  
   - **Upload**: writes curated record to S3 and returns the key.  

4. **Completion**  
   The state machine emits a completion event back to EventBridge for notifications or downstream triggers.  

5. **Error handling**  
   Each step defines retries and timeouts. Final failures are routed to SQS DLQ. Lambdas have dead-letter configs.  

---

## Key Design Decisions
- **Step Functions orchestration** for visual debugging and parallelism.  
- **Parallel execution**: each event runs independently.  
- **Retries & timeouts** defined per state in ASL.  
- **Idempotency** using record hash flags in S3.  
- **Decoupled Lambdas**: each function is modular and replaceable.  
- **Terraform modules** for reusability (`lambda_fn`, `s3_bucket`, `eventbridge_rule`, etc.).  
- **Packaging** with `archive_file` or ZIPs.  
- **Observability** with structured logging and CloudWatch metrics.  
- **Cost efficiency**: pay-per-use with minimal operational overhead.  

---

## Results
- Scale: millions of records per day.  
- Reliability: >99.99% successful executions.  
- Latency: <15s end-to-end per record (depending on flow).  
- Operations: near-zero infrastructure maintenance.  
- Deployment: fully automated in minutes with Terraform.  

---

## Stack
- AWS Lambda (Python 3.11)  
- AWS Step Functions (ASL JSON)  
- Amazon EventBridge (ingestion + completion)  
- Amazon S3 (raw, curated)  
- Amazon SQS (DLQ)  
- CloudWatch (logs, metrics, alarms)  
- Terraform (IaC modules)  
- GitHub Actions (CI/CD recommended)  
- Optional: OpenSearch for error triage, Lambda Powertools for logging/tracing  

---

## Deployment (Quick Start)
1. Configure AWS credentials.  
2. Update `env/dev.tfvars` with `project`, `region`, `env`.  
3. Initialize Terraform: make init
4. Plan and apply: make plan    make apply
5. Manual test:
Trigger Step Functions execution:
    aws stepfunctions start-execution \
  --state-machine-arn $STATE_MACHINE_ARN \
  --input file://event.json
Check logs: aws logs filter-log-events --log-group-name /aws/lambda/<fn-name> --limit 50   
