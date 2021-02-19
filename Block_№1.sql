--CREATE TABLE vRoadMap_table_1 AS
EXPLAIN ANALYZE SELECT  view_roadmap.disciplineid,
                view_roadmap.ModuleType,
                view_roadmap.SubmoduleID,
                view_roadmap.SubmoduleOrdernum
        from view_roadmap where view_roadmap.disciplineid in (SELECT view_disciplines_recordbooks.DisciplineID
                                                              FROM view_disciplines_recordbooks
                                                                       INNER JOIN students_groups ON students_groups.RecordBookID = view_disciplines_recordbooks.RecordBookID AND
                                                                                                     students_groups.SemesterID = view_disciplines_recordbooks.semesterid
                                                              WHERE students_groups.GroupID = 4405 and students_groups.semesterid = 13 and
                                                                      students_groups.state <= 'outlet'
                                                              GROUP BY view_disciplines_recordbooks.DisciplineID);
                                                              
                                                              
                                                          
                                                        
  