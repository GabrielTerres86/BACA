/*INC0029941 - Divergência data vecto CCB x Aimaro -*/

/*Descrição:Boa tarde, 

   Conforme alinhamento da Gestão de Crédito, solicitamos ajuste dos contratos que possuem divergência entre data da CCB e Aimaro. 
 O ajuste deve ser aplicado somente nas divergência decorrentes de alteração da data de vencimento antes da efetivação dos contratos. 
   Anexo segue troca de e-mails com o Oscar e relação de contas levantadas, porém, solicitamos levantamento atualizado.

  Atenciosamente, 

   Simone*/

DECLARE

  CURSOR CR_CONTRATOS IS
  SELECT E.CDCOOPER,
         E.CDAGENCI,
         E.TPEMPRST,
         E.NRDCONTA,
         E.NRCTREMP,
         E.DTMVTOLT,
         E.DTVENCTO,
         (SELECT P.DTVENCTO
            FROM CRAPPEP P
           WHERE P.NRPAREPR = 1
             AND P.CDCOOPER = E.CDCOOPER
             AND P.NRDCONTA = E.NRDCONTA
             AND P.NRCTREMP = E.NRCTREMP) DTVENCTOPARC,
         E.CDLCREMP,
         L.DSLCREMP,
         E.CDFINEMP,
         F.DSFINEMP
  
    FROM CRAWEPR E
  
    JOIN CRAPLCR L
      ON L.CDCOOPER = E.CDCOOPER
     AND L.CDLCREMP = E.CDLCREMP
  
    JOIN CRAPFIN F
      ON F.CDCOOPER = E.CDCOOPER
     AND F.CDFINEMP = E.CDFINEMP
  
    JOIN CRAPEPR EPR
      ON EPR.CDCOOPER = E.CDCOOPER
     AND EPR.NRDCONTA = E.NRDCONTA
     AND EPR.NRCTREMP = E.NRCTREMP
  
    JOIN CRAPPEP PEP
      ON PEP.NRPAREPR = 1
     AND PEP.CDCOOPER = EPR.CDCOOPER
     AND PEP.NRDCONTA = EPR.NRDCONTA
     AND PEP.NRCTREMP = EPR.NRCTREMP
     AND PEP.DTVENCTO <> E.DTVENCTO
  
   WHERE E.DTMVTOLT >= '01/01/2018'
     AND E.TPEMPRST = 1
     AND E.CDCOOPER IN (SELECT C.CDCOOPER FROM CRAPCOP C WHERE C.FLGATIVO = 1 );
  RW_CONTRATOS CR_CONTRATOS%ROWTYPE;

BEGIN

  FOR RW_CONTRATOS IN CR_CONTRATOS LOOP
    BEGIN
      UPDATE CRAWEPR E
         SET E.DTVENCTO = RW_CONTRATOS.DTVENCTOPARC
       WHERE E.TPEMPRST = RW_CONTRATOS.TPEMPRST
         AND E.CDCOOPER = RW_CONTRATOS.CDCOOPER
         AND E.NRDCONTA = RW_CONTRATOS.NRDCONTA
         AND E.NRCTREMP = RW_CONTRATOS.NRCTREMP;
    
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro na atualizacao de contrato: ' ||
                             RW_CONTRATOS.NRCTREMP || ';' ||
                             RW_CONTRATOS.CDCOOPER);                             
      END;
  END LOOP;
  COMMIT;
END;
