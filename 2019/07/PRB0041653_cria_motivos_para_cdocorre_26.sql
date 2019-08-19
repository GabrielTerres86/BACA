/*
Roberto Holz (Mout´s)
17/05/2019
Script para geração de novos motivos para a ocorrência de retorno 26

PRB0041653
 
*/
declare 
  -- Local variables here
  i integer:=0;
  x integer:=0;
  vr_dscritic varchar2(500);
  
  cursor cr_crapmot is
  select crapmot.cdcooper,
         crapmot.cddbanco,
         crapmot.cdocorre,
         crapmot.tpocorre,
         crapmot.cdmotivo,
         crapmot.dsmotivo,
         crapmot.dsabrevi,
         crapmot.cdoperad,
         crapmot.dtaltera,
         crapmot.hrtransa,
         crapmot.progress_recid
    from crapmot
   where crapmot.cdocorre = 26
     and crapmot.tpocorre = 2
     and crapmot.cdmotivo IN ('A8','A9','H3','H4','H6')
  order by crapmot.cdcooper,crapmot.cddbanco,crapmot.cdmotivo;
  
begin
FOR x in 1..5 LOOP
BEGIN
  insert into crapmot
  SELECT 
  C.CDCOOPER,
  C.CDDBANCO,
  C.CDOCORRE,
  C.TPOCORRE,
  DECODE(x,1,'A8',
           2,'A9',
           3,'H3',
           4,'H4',
           5,'H6') CDMOTIVO,
  DECODE(x,1,'Título pendente na CIP',
           2,'Título pendente na CIP',
           3,'Dias para prot. Inv. Min/max',
           4,'Prazo prot. Inv.',
           5,'Prot. não habilitado') DSMOTIVO,
  ' ' DSABREVI,
  C.CDOPERAD,
  TRUNC(SYSDATE) DTALTERA,
  gene0002.fn_busca_time HRTRANSA,
  NULL PROGRESS_RECID
   FROM CRAPMOT C
  WHERE C.CDOCORRE = 26
    AND C.TPOCORRE = 2
    AND C.CDMOTIVO = '99'
  ORDER BY C.CDCOOPER,C.CDDBANCO;
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL; --> Caso ja exista nao deve apresentar critica
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir crapmot: '||SQLERRM;
        dbms_output.put_line(vr_dscritic);
    END;
END LOOP;
FOR rw in cr_crapmot
   LOOP
     DBMS_OUTPUT.put_line(
         to_char(rw.cdcooper,'99') || ' - ' ||
         to_char(rw.cddbanco,'99') || ' - ' ||
         rw.cdocorre || ' - ' ||
         rw.tpocorre || ' - ' ||
         rw.cdmotivo || ' - ' ||
         rw.dsmotivo || ' - ' ||
         rw.dsabrevi || ' - ' ||
         rw.cdoperad || ' - ' ||
         rw.dtaltera || ' - ' ||
         rw.hrtransa || ' - ' ||
         rw.progress_recid );
   END LOOP;
Commit;
end;
