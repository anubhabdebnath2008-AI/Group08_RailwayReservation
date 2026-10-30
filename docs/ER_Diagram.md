# ER Diagram (render in GitHub or mermaid.live, export as image for the report)
```mermaid
erDiagram
 TRAIN ||--o{ TRAIN_ROUTE : has
 STATION ||--o{ TRAIN_ROUTE : "stop at"
 TRAIN ||--o{ SCHEDULE : runs
 TRAIN ||--o{ COACH : has
 COACH ||--o{ SEAT : contains
 SCHEDULE ||--o{ SCHEDULE_SEAT : tracks
 SEAT ||--o{ SCHEDULE_SEAT : "status on"
 PASSENGER ||--o{ BOOKING : makes
 SCHEDULE ||--o{ BOOKING : for
 STATION ||--o{ BOOKING : "from/to"
 BOOKING ||--|{ BOOKING_PASSENGER : includes
 SCHEDULE_SEAT ||--o{ BOOKING_PASSENGER : reserves
 BOOKING ||--|| PAYMENT : paid_by
 BOOKING ||--o| CANCELLATION : "may have"
```
Business rules: a seat can be held by only one active passenger per schedule; a station appears once per train route; cancellation refunds 90% (2+ days before travel), 50% (1 day), 0% (same day); total fare = sum of passenger fares.
