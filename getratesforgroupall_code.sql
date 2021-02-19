CREATE OR REPLACE FUNCTION public.getratesforgroupall(pgroupid integer, psemesterid integer)
 RETURNS TABLE("StudentID" integer, "DisciplineID" integer, "CompoundDiscID" integer, intermediate integer, bonus integer, extra integer, exam integer, examcnt integer, ordernum integer)
 LANGUAGE plpgsql
AS $function$
BEGIN

    DROP TABLE IF EXISTS vRoadMap;
    CREATE TEMPORARY TABLE vRoadMap AS (
        SELECT  view_roadmap.disciplineid,
                view_roadmap.ModuleType,
                view_roadmap.SubmoduleID,
                view_roadmap.SubmoduleOrdernum
        from view_roadmap where view_roadmap.disciplineid in (SELECT view_disciplines_recordbooks.DisciplineID
                                                              FROM view_disciplines_recordbooks
                                                                       INNER JOIN students_groups ON students_groups.RecordBookID = view_disciplines_recordbooks.RecordBookID AND
                                                                                                     students_groups.SemesterID = view_disciplines_recordbooks.semesterid
                                                              WHERE students_groups.GroupID = pGroupID and students_groups.semesterid = pSemesterID and
                                                                      students_groups.state <= 'outlet'
                                                              GROUP BY view_disciplines_recordbooks.DisciplineID)
    );

    return query
        SELECT  vRates.StudentID as "StudentID",
                vRates.DisciplineID as "DisciplineID",
                disciplines.CompoundDiscID as "CompoundDiscID",
                vRates.RateRegular AS intermediate,
                vRates.RateBonus AS bonus,
                vRates.RateExtra AS extra,
                vRates.RateExam AS exam,
                vRates.CntExam AS examCnt,
                vRates.OrderNum AS ordernum
        FROM (
                 SELECT  tStudents.StudentID,
                         vRoadMap.DisciplineID,
                         cast(SUM(CASE WHEN vRoadMap.ModuleType = 'regular' THEN  rt.Rate ELSE  0 END) as integer)AS RateRegular,
                         cast(SUM(CASE WHEN vRoadMap.ModuleType = 'extra' THEN  rt.Rate ELSE  0 END)as integer) AS RateExtra,
                         cast(SUM(CASE WHEN vRoadMap.ModuleType = 'bonus' THEN  rt.Rate ELSE  0 END)as integer) AS RateBonus,
                         MAX(CASE WHEN vRoadMap.ModuleType = 'exam' THEN  rt.Rate ELSE  0 END) AS RateExam,
                         cast( SUM(CASE WHEN vRoadMap.ModuleType = 'exam' THEN  1 ELSE  0 END)as integer) AS CntExam,
                         MAX(CASE WHEN vRoadMap.ModuleType = 'exam' THEN  vRoadMap.SubmoduleOrdernum ELSE  0 END) AS OrderNum
                 FROM (select vs.recordbookid, vs.studentid from view_students as vs where vs.groupid=pgroupid and vs.semesterid=psemesterid) tStudents
                          CROSS join vRoadMap
                          LEFT JOIN rating_table as rt  ON  rt.RecordBookID = tStudents.RecordBookID AND
                                                            rt.SubmoduleID = vRoadMap.SubmoduleID
                          LEFT JOIN disciplines_students on disciplines_students.disciplineid = vRoadMap.DisciplineID and disciplines_students.recordbookid=tStudents.RecordbookID
                          LEFT JOIN disciplines on disciplines.id = vRoadMap.DisciplineID
                 WHERE rt.Rate IS NOT NULL AND ((disciplines.isGlobal AND disciplines_students."type" = 'attach') OR (NOT disciplines.isGlobal))
                 GROUP BY tStudents.StudentID, vRoadMap.DisciplineID
             ) vRates
                 INNER JOIN students ON students.ID = vRates.StudentID
                 INNER JOIN accounts ON students.AccountID = accounts.ID
                 INNER JOIN disciplines ON disciplines.id = vRates.DisciplineID
        ORDER BY    CONCAT(accounts.LastName, accounts.FirstName,  coalesce(accounts.SecondName,'')) ASC,
                    vRates.DisciplineID ASC;
END
$function$
;
