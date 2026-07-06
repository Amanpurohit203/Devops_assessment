DO $$
DECLARE
  cities        TEXT[] := ARRAY['delhi', 'mumbai', 'bangalore', 'indore', 'pune', 'jaipur'];
  statuses      TEXT[] := ARRAY['confirmed', 'cancelled', 'completed', 'pending'];
  event_types   TEXT[] := ARRAY['created', 'payment_captured', 'checked_in', 'checked_out', 'cancelled'];
  org_ids       UUID[] := ARRAY[
    gen_random_uuid(), gen_random_uuid(), gen_random_uuid(),
    gen_random_uuid(), gen_random_uuid()
  ];
  i             INT;
  new_id        UUID;
  rand_created  TIMESTAMP;
BEGIN
  FOR i IN 1..200 LOOP
    new_id := gen_random_uuid();
    rand_created := now() - (random() * interval '90 days');

    INSERT INTO hotel_bookings (
      id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at
    ) VALUES (
      new_id,
      org_ids[1 + floor(random() * array_length(org_ids, 1))::int],
      'HOTEL-' || (1 + floor(random() * 40))::text,
      cities[1 + floor(random() * array_length(cities, 1))::int],
      current_date - (floor(random() * 60))::int,
      current_date - (floor(random() * 60))::int + (1 + floor(random() * 5))::int,
      round((500 + random() * 15000)::numeric, 2),
      statuses[1 + floor(random() * array_length(statuses, 1))::int],
      rand_created
    );

    IF random() < 0.5 THEN
      INSERT INTO booking_events (booking_id, event_type, payload, created_at)
      SELECT
        new_id,
        event_types[1 + floor(random() * array_length(event_types, 1))::int],
        jsonb_build_object('note', 'seed event', 'seq', gs),
        rand_created + (gs || ' hours')::interval
      FROM generate_series(1, 1 + floor(random() * 3)::int) AS gs;
    END IF;
  END LOOP;
END $$;