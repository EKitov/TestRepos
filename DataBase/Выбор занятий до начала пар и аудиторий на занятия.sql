WITH FreeLessons AS (
    SELECT l."LessonNumber", l."StartTime", l."EndTime"
    FROM public."Lesson" as l
    LEFT JOIN public."GroupLesson" as gl ON l."LessonNumber" = gl."LessonNumber" 
	AND gl."LessonDate" = '20.03.2024' 
    WHERE gl."LessomID" IS NULL AND l."StartTime" < '15:00'
),
Gaps AS (
    SELECT fl."LessonNumber",
           COUNT(*) AS "GapCount",
           fl."StartTime",
           fl."EndTime"
    FROM FreeLessons fl
    JOIN FreeLessons fl2 ON fl."LessonNumber" > fl2."LessonNumber"
    GROUP BY fl."LessonNumber", fl."StartTime", fl."EndTime"
    HAVING COUNT(*) <= 1
)
SELECT gaps."LessonNumber", gaps."StartTime", gaps."EndTime",
       ARRAY_AGG(r."RoomNumber") FILTER (WHERE r."isFavourite") as RoomNumbers,
       ARRAY_AGG(r."isFavourite") FILTER (WHERE r."isFavourite") as IsFavourites
FROM Gaps as gaps
JOIN public."Lesson" as l ON gaps."LessonNumber" = l."LessonNumber" 
LEFT JOIN public."Room" as r ON NOT EXISTS (
        SELECT 1 FROM public."GroupLesson" as gl 
        WHERE gl."ClassID" = r."RoomID" AND gl."LessonNumber" = gaps."LessonNumber" AND gl."LessonDate" = '20.03.2024'
) AND r."isFavourite" = true
GROUP BY gaps."LessonNumber", gaps."StartTime", gaps."EndTime";
