-- Remove duplicate reviews before adding unique constraint (keep newest per user+target)
DELETE FROM "reviews" r
USING (
  SELECT id,
    ROW_NUMBER() OVER (
      PARTITION BY user_id, target_type, target_id
      ORDER BY created_at DESC
    ) AS rn
  FROM "reviews"
) ranked
WHERE r.id = ranked.id AND ranked.rn > 1;

-- CreateIndex
CREATE UNIQUE INDEX "reviews_user_id_target_type_target_id_key" ON "reviews"("user_id", "target_type", "target_id");
