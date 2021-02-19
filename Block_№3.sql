 EXPLAIN ANALYZE SELECT  vrates_table_2.StudentID as "StudentID",
                vrates_table_2.DisciplineID as "DisciplineID",
                disciplines.CompoundDiscID as "CompoundDiscID",
                vrates_table_2.RateRegular AS intermediate,
                vrates_table_2.RateBonus AS bonus,
                vrates_table_2.RateExtra AS extra,
                vrates_table_2.RateExam AS exam,
                vrates_table_2.CntExam AS examCnt,
                vrates_table_2.OrderNum AS ordernum
        FROM vrates_table_2, disciplines