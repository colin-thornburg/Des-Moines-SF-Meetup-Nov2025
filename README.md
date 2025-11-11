# Des Moines Snowflake Meetup: Dynamic Tables & Data Products Demo

## Overview

This dbt project demonstrates **enterprise data product development** using Snowflake Dynamic Tables with contract-first data modeling. The demo showcases how to build governed, self-refreshing data products with guaranteed schema stability and freshness SLAs.

## Demo Architecture

```
Raw Event Data (JSON/Avro-style)
    ↓
Staging Layer (Type conversion & parsing)
    ↓
Data Product Layer (Dynamic Table with Contract)
    ↓
Consumption (BI Tools, Analytics Teams)
```

## Data Source

**Source**: `RAW_DESMOINES_SF_MEETUP.EVENTS.customer_interactions`

Semi-structured customer interaction events stored as JSON in a VARIANT column, simulating real-world event streams from Kafka topics, event collection systems, or CDC pipelines.

**Sample Event Structure**:
```json
{
  "interaction_id": "550e8400-e29b-41d4-a716-446655440000",
  "customer_id": "CUST-1234",
  "timestamp": "2024-11-11T14:30:00.000Z",
  "type": "purchase",
  "value_usd": 125.50,
  "channel": "web",
  "session_id": "abc-123-def"
}
```

## Contract-First Development (Avro Schema Analogy)

### What is an Avro Schema?

An **Avro schema** is a JSON-based contract that defines the exact structure of data including field names, data types, required vs optional fields, and schema evolution rules. Commonly used in event streaming platforms like Kafka to ensure data quality and compatibility across systems.

### How dbt Contracts Mirror Avro

We use **dbt model contracts** to achieve the same guarantees as Avro schemas:

**Key Benefits**:
- ✅ **Breaking change prevention**: Can't deploy schema changes that violate the contract
- ✅ **Documentation as code**: Schema is self-documenting
- ✅ **Type safety**: Data types are enforced at build time
- ✅ **Consumer protection**: Downstream teams trust the schema won't change unexpectedly

## The Data Product

### Model: `customer_interactions_product`

**Materialization**: Snowflake Dynamic Table

**Key Features**:
1. **Continuous Refresh**: Snowflake automatically maintains data freshness without manual orchestration
2. **Contract Enforcement**: Schema changes require explicit contract updates
3. **Data Quality Tests**: Automated validation on every refresh
4. **Self-Service Discovery**: Full documentation and lineage in dbt Explorer

**SLA**: Data refreshes on-demand (5-minute target lag in production scenarios)

**Governance**:
- Owner: Data Engineering Team
- Consumers: Marketing Analytics, Customer Success, BI Teams
- Quality: Automated tests including uniqueness, null checks, and accepted values

## Demo Workflow

### 1. Generate Source Data
```sql
CALL RAW_DESMOINES_SF_MEETUP.EVENTS.generate_events(20);
```

### 2. Build Data Product
```bash
dbt build
```

### 3. Show Contract Protection
Attempt to add an undeclared column → dbt prevents deployment

### 4. Live Refresh Demo
```sql
-- Add new events
CALL RAW_DESMOINES_SF_MEETUP.EVENTS.generate_events(10);

-- Trigger refresh
ALTER DYNAMIC TABLE analytics.marts.customer_interactions_product REFRESH;

-- Verify new data
SELECT COUNT(*) FROM analytics.marts.customer_interactions_product;
```

## Business Value

| Traditional Approach | Data Product Approach |
|---------------------|----------------------|
| Brittle pipelines that break with schema changes | Contract-enforced schema prevents breaking changes |
| Manual orchestration and scheduling | Automatic continuous refresh with SLAs |
| Tribal knowledge about data quality | Automated tests document and enforce quality |
| Unclear ownership and discovery | Self-service with full lineage and documentation |

## Key Takeaways

1. **Dynamic Tables** eliminate orchestration overhead while maintaining freshness guarantees
2. **dbt Contracts** provide Avro-like schema governance for analytics models
3. **Data Products** are discoverable, documented, and governed assets—not just tables
4. **Enterprise-ready** patterns that scale from 10 to 10,000 models

## Technologies Used

- **dbt Cloud**: Transformation and orchestration
- **Snowflake**: Data warehouse with Dynamic Tables
- **dbt Contracts**: Schema enforcement
- **dbt Tests**: Data quality validation
- **dbt Explorer**: Lineage and discovery

---

*Demo prepared for Des Moines Snowflake Meetup - November 2025*