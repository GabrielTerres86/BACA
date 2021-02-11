/* Atualizar dados do títulos de cobrança para rejeitado e sem envio a CIP - INC0068484*/
BEGIN
  --
  UPDATE crapcob cob
     SET cob.insitpro = 0
        ,cob.flgcbdda = 0
        ,cob.inenvcip = 4
        ,cob.dhenvcip = NULL
        ,cob.inregcip = 0
   WHERE (cob.cdcooper, cob.nrdconta, cob.nrcnvcob, cob.nrdocmto, cob.idtitleg) IN
         ((10, 64050, 109090, 339, 22704917) --Caso 4
         ,(1, 9724176, 101004, 6814315, 39641703) --Caso 6
         ,(1, 10296255, 101002, 164, 22704981) --Caso 7
         ,(1, 10296255, 101002, 165, 22704982) --Caso 7
         ,(1, 10296255, 101002, 166, 22704983) --Caso 7
         ,(1, 10296255, 101002, 167, 22704984) --Caso 7
         ,(1, 10296255, 101002, 168, 22704985) --Caso 7
         ,(1, 10296255, 101002, 169, 22704986) --Caso 7
         --
         ,(1, 11273178, 101002, 729, 43126350) --Caso 8
         ,(1, 6832660 , 101002, 9829, 44161543) --Caso 5        
         
          );
  --
  COMMIT;
  --
END;
