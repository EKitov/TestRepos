WITH FreeLessons AS (
    SELECT l."LessonNumber", l."StartTime", l."EndTime",
           LEAD(l."StartTime") OVER (ORDER BY l."StartTime") - l."EndTime" AS "NextGap",
           LAG(l."EndTime") OVER (ORDER BY l."StartTime") - l."StartTime" AS "PrevGap"
    FROM public."Lesson" as l
    LEFT JOIN public."GroupLesson" as gl ON l."LessonNumber" = gl."LessonNumber" 
	AND gl."LessonDate" = '20.03.2024' 
    WHERE gl."LessomID" IS NULL AND l."StartTime" <= '16:40'
),
Gaps AS (
    SELECT *,
           CASE
               WHEN "NextGap" IS NOT NULL AND "PrevGap" IS NOT NULL THEN "NextGap" + "PrevGap"
               WHEN "NextGap" IS NULL THEN "PrevGap"
               WHEN "PrevGap" IS NULL THEN "NextGap"
               ELSE NULL
           END AS "TotalGap"
    FROM FreeLessons
),
FilteredGaps AS (
    SELECT *
    FROM Gaps
    WHERE "TotalGap" >= '1:00' or "TotalGap" <= '0:00' OR "TotalGap" IS NULL
)
SELECT fg."LessonNumber", fg."StartTime", fg."EndTime",
       ARRAY_AGG(r."RoomNumber") FILTER (WHERE r."isFavourite") as RoomNumbers,
       ARRAY_AGG(r."isFavourite") FILTER (WHERE r."isFavourite") as IsFavourites
FROM FilteredGaps fg
LEFT JOIN public."Room" as r ON NOT EXISTS (
        SELECT 1 FROM public."GroupLesson" as gl 
        WHERE gl."ClassID" = r."RoomID" AND gl."LessonNumber" = fg."LessonNumber" AND gl."LessonDate" = '20.03.2024'
) AND r."isFavourite" = true
GROUP BY fg."LessonNumber", fg."StartTime", fg."EndTime";
