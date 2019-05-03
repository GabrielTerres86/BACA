declare
  vr_nrseqrdr number;

BEGIN

  -- Movendo a opção 
  UPDATE CRAPTEL TEL
   SET TEL.CDOPPTEL = TEL.CDOPPTEL||',D'
      ,TEL.LSOPPTEL = TEL.LSOPPTEL||',DESABILITAR OPERACAO'
  WHERE TEL.NMDATELA = 'ATENDA'
   AND TEL.NMROTINA = 'LIMITE CRED';
  
  -- Removendo desabilitar operações
  DELETE craptel tel
   WHERE UPPER(tel.NMDATELA) = 'ATENDA'
     AND UPPER(tel.NMROTINA) = 'DESABILITAR OPERACOES';
  
  DELETE CRAPACE ACE
   WHERE ACE.CDCOOPER = 1
     AND UPPER(ACE.NMDATELA) = 'ATENDA'
     AND UPPER(ACE.NMROTINA) = 'DESABILITAR OPERACOES'
     AND UPPER(ACE.CDDOPCAO) = '@';
  
  -- Movendo ACA da package tela_contas_desab para tela_atenda_limite
  UPDATE crapaca aca
     SET aca.nmpackag = 'TELA_ATENDA_LIMITE'
  WHERE aca.nmproced IN('pc_grava_dados_conta','pc_busca_dados_conta')
    AND aca.nmpackag = 'TELA_CONTAS_DESAB';  
  
  -- Removendo Aca não mais utilizada    
  DELETE CRAPACA ACA
   WHERE ACA.NMPACKAG = 'TELA_CONTAS_DESAB';    
     
     
  -- Movendo os acessos do Alterar para o Limite de Credito   
  UPDATE CRAPACE ACE
     SET ACE.CDDOPCAO = 'D'
        ,ACE.NMROTINA = 'LIMITE CRED'
   WHERE ACE.CDCOOPER = 1
     AND UPPER(ACE.NMDATELA) = 'ATENDA'
     AND UPPER(ACE.NMROTINA) = 'DESABILITAR OPERACOES'
     AND UPPER(ACE.CDDOPCAO) = 'A';   

  BEGIN
    INSERT INTO craprdr(nmprogra,dtsolici) VALUES('TELA_ATENDA_PREAPV',SYSDATE)
             RETURNING nrseqrdr INTO vr_nrseqrdr; 
  EXCEPTION
    WHEN OTHERS THEN
      SELECT nrseqrdr
        INTO vr_nrseqrdr
      FROM craprdr
      WHERE nmprogra = 'TELA_ATENDA_PREAPV';
  END; 
  
  BEGIN
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'RESUMO_PREAPV','TELA_ATENDA_PREAPV','pc_resumo_pre_aprovado','pr_nrdconta');
  
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'MOTIVO_SEM_PREAPV','TELA_ATENDA_PREAPV','pc_lista_motivos_sem_preapv','pr_nrdconta');
               
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'COMBO_MOTIVOS_BLOQ','TELA_ATENDA_PREAPV','pc_lista_motivos_tela',NULL);
  
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'GRAVA_PARAM_PREAPV','TELA_ATENDA_PREAPV','pc_mantem_param_preapv','pr_nrdconta,pr_flglibera_pre_aprv,pr_dtatualiza_pre_aprv,pr_idmotivo');               
  EXCEPTION 
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    SELECT r.nrseqrdr 
      INTO vr_nrseqrdr
    FROM craprdr r 
    WHERE r.nmprogra = 'ATENDA_CRD';

    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
      VALUES(vr_nrseqrdr, 'GRAVA_PARAM_MAJORA','TELA_ATENDA_CARTAOCREDITO','pc_mantem_param_majora','pr_nrdconta');

    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
      VALUES(vr_nrseqrdr, 'BUSCA_PARAM_MAJORA','TELA_ATENDA_CARTAOCREDITO','pc_busca_param_majora','pr_nrdconta');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;         
   
  commit;
end;