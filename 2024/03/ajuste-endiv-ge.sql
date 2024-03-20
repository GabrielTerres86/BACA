BEGIN
  UPDATE cecred.tbcadast_cooperativa a 
     SET a.vlsomatorio_leco = (SELECT SUM(l.vlendividamento) 
                                 FROM credito.tbcred_somatorioleco l
                                WHERE l.cdcooper = a.cdcooper
                                  AND l.dtrefere = to_date('15/03/2024', 'DD/MM/RRRR'))
   WHERE a.cdcooper NOT IN (1);
  COMMIT;
END;
