DECLARE
  vr_idprglog  tbgen_prglog.idprglog%TYPE;
  CURSOR cr_crapprm IS
    select a.cdcooper
      from cecred.crapcop a 
     where a.flgativo = 1 
       and a.cdcooper <> 3
       and a.cdcooper not in (select cdcooper
                                from crapprm 
                               where cdacesso = 'COOP_PILOTO_POUPANCA_PF') ;
  rw_crapprm cr_crapprm%ROWTYPE;
   
BEGIN
  
  FOR rw_crapprm in cr_crapprm LOOP
    
    insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', rw_crapprm.cdcooper, 'COOP_PILOTO_POUPANCA_PF', 'Indica se a cooperativa habilita contratacao de POUPANCA (0=Inativa,1=Piloto para algumas contas,2=Ativa)', '2');

    insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', rw_crapprm.cdcooper, 'CAPT_POUPANCA_RENT_ATIVA', 'Indica se a rentabilidade da poupanca esta ativa para a cooperativa', '1');

  END LOOP;
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',33187541100,49832883920,07101524931,71713476991,95110429987,02650137983,02429298937,01666295965,48447897915,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 5;
  
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',74809342972,60660716968,03474201921,77416570972,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 5;  
  
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',04744599931,02381914943,01796336947,'
   WHERE cdacesso = 'PESSOA_LIGADA_DIRETORIA'
     AND p.cdcooper = 2;    
     
   UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',97095079900,41848950934,00456419942,91998441920,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 2;  

   UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',04361013942,86030132920,31059473968,03819816909,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 13;

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',02222355940,01903886929,15470571904,'
   WHERE cdacesso = 'PESSOA_LIGADA_DIRETORIA'
     AND p.cdcooper = 8; 
  
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',02998912915,33365040668,00339525908,59486570949,45247340906,06963084955,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 8;
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',38531860920,61412856949,39922359987,25756923934,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 8;   
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',02992710997,17914108987,01799964957,44194536991,87899230900,37888722920,96328045972,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 7;       

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',78080959072,00927510910,01249421055,'
   WHERE cdacesso = 'PESSOA_LIGADA_DIRETORIA'
     AND p.cdcooper = 10; 
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',26579833831,89216466987,01996179969,56804989953,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 10;
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',00927569990,56603916991,'
   WHERE cdacesso = 'PESSOA_LIGADA_DIRETORIA'
     AND p.cdcooper = 12;

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',90483103934,01946958913,09376578830,03409972900,58267638920,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 12;

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',03684397989,59950960959,03044923964,07851283957,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 12;
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',70880670991,02027794913,80641075987,28382293972,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 14;     

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',37039318920,04231851956,57755795934,37036122900,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 14;
     
 UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',74979698034,53289064034,'
   WHERE cdacesso = 'PESSOA_LIGADA_DIRETORIA'
     AND p.cdcooper = 9;   
 
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',00908373988,93938098015,09339892968,00940247909,83320954920,06748481953,01621510042,00882085085,38617528915,75123037934,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 9;         

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',37039318920,04231851956,57755795934,37036122900,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 9;
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',54094275991,41739507991,59171332987,06240921866,00036644064,80642446920,72997842972,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 6;
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',00667603999,52121011900,81696965934,88767019900,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 6;    
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',18170374987,89176294900,02759338908,21629137987,94850089968,00484245953,57379068091,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 1;   
     
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',04804487956,05017352910,72850469904,38212544915,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 1;         

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = ',75103990920,05044292990,03281320988,06751758952,'
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 16; 
    
  COMMIT;
   EXCEPTION
   WHEN OTHERS then

         CECRED.pc_log_programa(pr_dstiplog      => 'O'
                               ,pr_tpocorrencia  => 4 
                               ,pr_cdcriticidade => 0 
                               ,pr_tpexecucao    => 3 
                               ,pr_dsmensagem    => sqlerrm
                               ,pr_cdmensagem    => 0
                               ,pr_cdprograma    => 'LIBERACAO-POUPANCA'
                               ,pr_cdcooper      => 3 
                               ,pr_idprglog      => vr_idprglog);
         ROLLBACK; 
END;
