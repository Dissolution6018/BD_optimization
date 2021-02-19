CREATE OR REPLACE FUNCTION public.compare_tables(pgroupid_first integer, psemesterid_first integer, pgroupid_second integer, psemesterid_second integer)
 RETURNS TABLE("Rows" bigint)
 LANGUAGE sql
AS $function$
/*
1 - original entities 
2 - after inner join 
3 - after right join
*/
	SELECT COUNT(o1)
	FROM getratesforgroupall(pgroupid_first, psemesterid_first) o1
	UNION ALL
	SELECT COUNT(gr1)
	FROM (SELECT * FROM getratesforgroupall(pgroupid_first, psemesterid_first)) gr1 INNER JOIN (SELECT * FROM getratesforgroupall(pgroupid_second, psemesterid_second)) gr2 ON gr1."StudentID" = gr2."StudentID" AND
		gr1."DisciplineID" = gr2."DisciplineID" AND gr1.intermediate = gr2.intermediate AND gr1.bonus = gr2.bonus AND gr1.exam = gr2.exam AND 
		gr1.examcnt = gr2.examcnt AND gr1.ordernum = gr2.ordernum
	UNION ALL
	SELECT COUNT(gr1)
	FROM (SELECT * FROM getratesforgroupall(pgroupid_first, psemesterid_first)) gr1 RIGHT JOIN (SELECT * FROM getratesforgroupall(pgroupid_second, psemesterid_second)) gr2 ON gr1."StudentID" = gr2."StudentID" AND
		gr1."DisciplineID" = gr2."DisciplineID" AND gr1.intermediate = gr2.intermediate AND gr1.bonus = gr2.bonus AND gr1.exam = gr2.exam AND
		gr1.examcnt = gr2.examcnt AND gr1.ordernum = gr2.ordernum;
	
$function$
;
