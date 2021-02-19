--create table vrates_table_2 as
EXPLAIN ANALYZE SELECT  tStudents.StudentID,
                         vRoadMap_table_1.DisciplineID,
                         cast(SUM(CASE WHEN vRoadMap_table_1.ModuleType = 'regular' THEN  rt.Rate ELSE  0 END) as integer)AS RateRegular,
                         cast(SUM(CASE WHEN vRoadMap_table_1.ModuleType = 'extra' THEN  rt.Rate ELSE  0 END)as integer) AS RateExtra,
                         cast(SUM(CASE WHEN vRoadMap_table_1.ModuleType = 'bonus' THEN  rt.Rate ELSE  0 END)as integer) AS RateBonus,
                         MAX(CASE WHEN vRoadMap_table_1.ModuleType = 'exam' THEN  rt.Rate ELSE  0 END) AS RateExam,
                         cast( SUM(CASE WHEN vRoadMap_table_1.ModuleType = 'exam' THEN  1 ELSE  0 END)as integer) AS CntExam,
                         MAX(CASE WHEN vRoadMap_table_1.ModuleType = 'exam' THEN  vRoadMap_table_1.SubmoduleOrdernum ELSE  0 END) AS OrderNum
                 FROM (select vs.recordbookid, vs.studentid from view_students as vs where vs.groupid=4405 and vs.semesterid=13) tStudents
                          CROSS join vRoadMap_table_1
                          LEFT JOIN rating_table as rt  ON  rt.RecordBookID = tStudents.RecordBookID AND
                                                            rt.SubmoduleID = vRoadMap_table_1.SubmoduleID
                          LEFT JOIN disciplines_students on disciplines_students.disciplineid = vRoadMap_table_1.DisciplineID and disciplines_students.recordbookid=tStudents.RecordbookID
                          LEFT JOIN disciplines on disciplines.id = vRoadMap_table_1.DisciplineID
                 WHERE rt.Rate IS NOT NULL AND ((disciplines.isGlobal AND disciplines_students."type" = 'attach') OR (NOT disciplines.isGlobal))
                 GROUP BY tStudents.StudentID, vRoadMap_table_1.DisciplineID;
             
             
         
        
         