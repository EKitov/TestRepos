SELECT r."RoomNumber" 
FROM public."Room" as r
WHERE r."isFavourite" = true AND NOT EXISTS (
    SELECT 1 
    FROM public."GroupLesson" as gl
    JOIN public."Lesson" as l ON gl."LessonNumber" = l."LessonNumber" 
    WHERE gl."LessonDate" = '20.03.2024' AND 
          (l."StartTime" >= '9:40' AND l."EndTime" <= '11:10') AND 
          r."RoomID" = gl."ClassID")
