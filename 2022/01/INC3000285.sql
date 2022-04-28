DECLARE
  
  CURSOR cr_tbcrd_intermed_utlz_cartao is
      SELECT dtmvtolt, 
             nrconta_cartao
        FROM tbcrd_intermed_utlz_cartao a --AIMARO
       WHERE dtmvtolt between to_date('01/01/2021','dd/mm/yyyy') and to_date('31/12/2021','dd/mm/yyyy')
         AND NOT EXISTS (SELECT nrconta_cartao FROM tbcrd_utilizacao_cartao b WHERE a.nrconta_cartao = b.nrconta_cartao AND a.dtmvtolt = b.dtmvtolt)
       ORDER BY a.nrconta_cartao;  
       rw_tbcrd_intermed_utlz_cartao cr_tbcrd_intermed_utlz_cartao%ROWTYPE;                       
  
  CURSOR cr_tbcrd_conta_cartao(pDataMov date, pContaCartao number) is
      SELECT a.dtmvtolt,
             a.nrconta_cartao,
             NVL(cdcooper,DECODE(a.nrconta_cartao,7563232018039,6,7563239671220,1,7564438062146,11,7564420077122,16)) cdcooper,
             NVL(nrdconta,DECODE(a.nrconta_cartao,7563232018039,201901,7563239671220,11250399,7564438062146,773964,7564420077122,166197)) nrdconta,
             a.qttransa_debito,
             a.qttransa_credito,
             a.vltransa_debito,
             a.vltransa_credito            
        FROM tbcrd_intermed_utlz_cartao a,
             tbcrd_conta_cartao b
       WHERE a.nrconta_cartao = b.nrconta_cartao(+)
         AND a.nrconta_cartao = pContaCartao
         AND a.dtmvtolt       = pDataMov;  
         rw_tbcrd_conta_cartao cr_tbcrd_conta_cartao%ROWTYPE; 
                                                           
BEGIN
  
  FOR rw_tbcrd_intermed_utlz_cartao IN cr_tbcrd_intermed_utlz_cartao LOOP
      
     -- busca os dados a serem inseridos
     FOR rw_tbcrd_conta_cartao IN cr_tbcrd_conta_cartao(rw_tbcrd_intermed_utlz_cartao.dtmvtolt,rw_tbcrd_intermed_utlz_cartao.nrconta_cartao) LOOP
         
        INSERT INTO tbcrd_utilizacao_cartao (dtmvtolt,
                                             nrconta_cartao,
                                             cdcooper,
                                             nrdconta,
                                             qttransa_debito,
                                             qttransa_credito,
                                             vltransa_debito,
                                             vltransa_credito)
                                      VALUES(rw_tbcrd_conta_cartao.dtmvtolt,
                                             rw_tbcrd_conta_cartao.nrconta_cartao,
                                             rw_tbcrd_conta_cartao.cdcooper,
                                             rw_tbcrd_conta_cartao.nrdconta,
                                             rw_tbcrd_conta_cartao.qttransa_debito,
                                             rw_tbcrd_conta_cartao.qttransa_credito,
                                             rw_tbcrd_conta_cartao.vltransa_debito,
                                             rw_tbcrd_conta_cartao.vltransa_credito);        

     END LOOP;      
    
  END LOOP;
  
  COMMIT;
  
END;                 


