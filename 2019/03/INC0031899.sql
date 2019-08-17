/*            


     UPDATE PARA ATUALIZAR A DATA DE INICIO DOS BANCOS QUE NÃO POSSUEM ESSA INFORMAÇÃO         
 

    SELECT b.cdbccxlt,
           b.nrispbif,
           b.nmresbcc,    
           'update CRAPBAN a ' ||
              'set a.dtinispb = '''' '  ||
            'where a.progress_recid = ' || b.progress_recid || ';' Cmd_update,
           'update CRAPBAN a ' ||
              'set a.dtinispb = ' || decode(b.dtinispb,NULL,'NULL',b.dtinispb) ||
           ' where a.progress_recid = ' || b.progress_recid || ';' Cmd_backup
      FROM CRAPBAN B
     WHERE B.FLGDISPB = 1
       AND B.DTINISPB IS NULL
       ORDER BY b.cdbccxlt;
       

*/

--Update para atualizar
update CRAPBAN a set a.dtinispb = '08/08/2008' where a.progress_recid = 12;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 37;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 51;
update CRAPBAN a set a.dtinispb = '11/11/2005' where a.progress_recid = 59;
update CRAPBAN a set a.dtinispb = '10/04/2006' where a.progress_recid = 60;
update CRAPBAN a set a.dtinispb = '31/07/2008' where a.progress_recid = 62;
update CRAPBAN a set a.dtinispb = '25/07/2008' where a.progress_recid = 63;
update CRAPBAN a set a.dtinispb = '24/10/2008' where a.progress_recid = 65;
update CRAPBAN a set a.dtinispb = '12/06/2009' where a.progress_recid = 66;
update CRAPBAN a set a.dtinispb = '17/05/2010' where a.progress_recid = 69;
update CRAPBAN a set a.dtinispb = '01/07/2010' where a.progress_recid = 76;
update CRAPBAN a set a.dtinispb = '22/06/2010' where a.progress_recid = 79;
update CRAPBAN a set a.dtinispb = '12/11/2004' where a.progress_recid = 80;
update CRAPBAN a set a.dtinispb = '10/10/2011' where a.progress_recid = 102;
update CRAPBAN a set a.dtinispb = '04/04/2012' where a.progress_recid = 104;
update CRAPBAN a set a.dtinispb = '26/09/2013' where a.progress_recid = 114;
update CRAPBAN a set a.dtinispb = '23/05/2016' where a.progress_recid = 1268;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 122;
update CRAPBAN a set a.dtinispb = '16/10/2017' where a.progress_recid = 2169;
update CRAPBAN a set a.dtinispb = '14/05/2018' where a.progress_recid = 2619;
update CRAPBAN a set a.dtinispb = '05/11/2018' where a.progress_recid = 3319;
update CRAPBAN a set a.dtinispb = '24/01/2019' where a.progress_recid = 3519;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 187;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 196;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 224;
update CRAPBAN a set a.dtinispb = '27/09/2010' where a.progress_recid = 1318;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 304;
update CRAPBAN a set a.dtinispb = '22/04/2002' where a.progress_recid = 309;

COMMIT;

/*

--Update para backup
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 12;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 37;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 51;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 59;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 60;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 62;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 63;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 65;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 66;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 69;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 76;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 79;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 80;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 102;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 104;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 114;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 1268;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 122;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 2169;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 2619;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 3319;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 3519;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 187;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 196;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 224;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 1318;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 304;
update CRAPBAN a set a.dtinispb = NULL where a.progress_recid = 309;

commit;

*/
