# DevOps Assessment: Terraform + Database Reliability

Internet → ALB → ECS/Fargate → RDS, with a local Postgres environment for the
database tasks (seed data, query optimization, backup/restore).


## Repo Layout

infra/
modules/
network/   # VPC, public/private subnets, NAT, ALB/ECS/RDS security groups
ecs/       # ECS cluster, Fargate task/service, ALB, target group, listener
rds/       # RDS Postgres instance, subnet group
envs/
dev/       # dev.tfvars, backend.tf, wiring
prod/      # prod.tfvars, backend.tf, wiring
db/
migrations/001_init.sql   # schema + index
seed/seed.sql             # 200 seeded bookings + events
scripts/
backup.sh
restore.sh
docker-compose.yml
.github/workflows/terraform.yml


## Part 1-2: Terraform Infrastructure

See `infra/modules/` for the VPC/ALB/ECS/RDS design and `infra/envs/{dev,prod}`
for environment-specific sizing. Both environments were validated locally with
`terraform fmt`, `init -backend=false`, `validate`, and `plan -refresh=false`
— both produced clean plans (28 to add, 0 errors).

## Part 4: Local Database

```bash
docker compose up -d
docker exec -i bookings_db psql -U app_admin -d bookingsdb < db/migrations/001_init.sql
docker exec -i bookings_db psql -U app_admin -d bookingsdb < db/seed/seed.sql
```

Creates `hotel_bookings` and `booking_events` (linked by foreign key), then
seeds 200 bookings across 6 cities, 5 organizations, and 4 statuses, with
events on roughly half the bookings.


## Part 5: Query Optimization and Indexing

Target query:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

Index added:

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
  ON hotel_bookings (city, created_at)
  INCLUDE (org_id, status, amount);
```

**Why this index:** the query has one equality filter (`city`) and one range
filter (`created_at`). The standard rule for composite indexes is equality
columns first, range columns second — this lets Postgres narrow to
`city = 'delhi'` and then scan forward through recent dates in a single index
range scan, rather than scanning the whole table. `org_id`, `status`, and
`amount` are added as `INCLUDE` columns (not part of the search key, just
carried along) so the query's `SELECT`/`GROUP BY` columns can be answered
directly from the index — an index-only scan, avoiding a trip back to the
table rows entirely.

**Honest note on what `EXPLAIN ANALYZE` actually shows at this data volume:**
at 200 seeded rows, Postgres's query planner chooses a sequential scan, not
the index, because at this small scale reading all rows directly is cheaper
than the overhead of an index lookup. This is expected, correct planner
behavior — index usage is a cost-based decision, not something that happens
just because an index exists. This index is the right choice for realistic
production data volumes (tens of thousands+ rows on `hotel_bookings`), where
the planner would naturally switch to using it once the cost of a full scan
exceeds the cost of the index range scan. This can be confirmed at this seed
scale by forcing the planner's hand: `SET enable_seqscan = off;` before
running `EXPLAIN ANALYZE` will show the index being used successfully,
confirming it correctly satisfies the query — the planner simply doesn't
choose it unprompted yet at only 200 rows.



## Part 6: Backup and Restore

```bash
./scripts/backup.sh
./scripts/restore.sh
```

`backup.sh` runs `pg_dump -Fc` **inside** the container (writing to a file in
the container's own filesystem via `-f`, then `docker cp`-ing that finished
file out) rather than streaming the dump through `docker exec`'s stdout —
streaming large binary output through `docker exec` and redirecting with `>`
was found to silently corrupt the dump during testing (confirmed via
`pg_restore --list` showing a corrupted table of contents). Writing to a
file first and copying it out afterward avoids that entirely.

`restore.sh` restores the most recent backup into a **fresh**
`bookingsdb_restore` database (never overwriting the live `bookingsdb`), then
automatically prints row counts for both tables as part of its own output.

### How to verify the restore worked

`restore.sh` prints this automatically at the end of every run:
