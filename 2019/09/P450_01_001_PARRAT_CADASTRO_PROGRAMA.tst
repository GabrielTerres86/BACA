PL/SQL Developer Test script 3.0
161
-- Created on 29/01/2019 by T0032419 
DECLARE
  CURSOR C_craptel(PRNMDATELA IN craptel.NMDATELA%TYPE,
                   PRCDCOOPER IN craptel.CDCOOPER%TYPE) IS
  
    SELECT *
      FROM craptel
     WHERE craptel.NMDATELA = PRNMDATELA
       AND craptel.CDCOOPER = PRCDCOOPER;
  RG_craptel C_craptel%ROWTYPE;

  CURSOR C_crapPRG(PRNMDATELA IN crapPRG.CDPROGRA%TYPE,
                   PRCDCOOPER IN crapPRG.CDCOOPER%TYPE) IS
  
    SELECT *
      FROM crapPRG
     WHERE crapPRG.CDPROGRA = PRNMDATELA
       AND crapPRG.CDCOOPER = PRCDCOOPER;
  RG_crapPRG C_crapPRG%ROWTYPE;
  SIGLA_TELA VARCHAR2(4000);

---
  V_NRORDPRG    crapPRG.NRORDPRG%TYPE;
  V_NRSOLICI    crapPRG.NRSOLICI%TYPE;
  V_COOPER      crapPRG.CDCOOPER%TYPE;
---
BEGIN

  SIGLA_TELA := 'PARRAT';
  V_NRSOLICI   := 50;
  V_COOPER     := 3;
 ----------------------------------------------------------
  begin
     SELECT max(NRORDPRG) +1
      into  V_NRORDPRG
      FROM  crapPRG
     WHERE  NVL(V_COOPER,crapPRG.cdcooper) = crapPRG.cdcooper 
       and  NRSOLICI  = V_NRSOLICI ;
  end;     
  ----------------------------------------------------------
  
  FOR REG_OPER IN (select cdcooper from crapcop where flgativo = 1 AND NVL(V_COOPER,cdcooper) = cdcooper )LOOP
     
     OPEN C_craptel(SIGLA_TELA, REG_OPER.cdcooper);
    FETCH C_craptel
     INTO RG_craptel;
  
    IF C_craptel%NOTFOUND THEN
    
      CLOSE C_craptel;
    
      insert into craptel
        (NMDATELA,
         NRMODULO,
         CDOPPTEL,
         TLDATELA,
         TLRESTEL,
         FLGTELDF,
         FLGTELBL,
         NMROTINA,
         LSOPPTEL,
         INACESSO,
         CDCOOPER,
         IDSISTEM,
         IDEVENTO,
         NRORDROT,
         NRDNIVEL,
         NMROTPAI,
         IDAMBTEL)
      values
        (SIGLA_TELA, --NMDATELA
         8, --NRMODULO
         'C,A,P', --CDOPPTEL
         'Alter/Consulta Nota do Rating após a Efetivação', --TLDATELA
         'Alter/Consulta Nota do Rating após a Efetivação', --TLRESTEL
         0, --FLGTELDF
         1, --FLGTELBL
         ' ', --NMROTINA
         'CONSULTA,ALTERACAO,HABILITAR ALTERACAO RATING', --LSOPPTEL
         0, --INACESSO
         REG_OPER.CDCOOPER, --CDCOOPER
         1, --IDSISTEM
         0, --IDEVENTO
         0, --NRORDROT
         0, --NRDNIVEL
         ' ', --NMROTPAI
         0) --IDAMBTEL
      ;
    
      DBMS_OUTPUT.PUT_LINE('Inseriu em craptel Alter./Consulta Nota do Rating após a Efetivação. cooperativa-> ' ||
                           REG_OPER.CDCOOPER);
    ELSE
      CLOSE C_craptel;
      DBMS_OUTPUT.PUT_LINE('Inserção em craptel não realizada. tela ' ||
                           SIGLA_TELA || ' Cooperativa:' ||
                           REG_OPER.CDCOOPER);
    END IF;
  
    -----------------------------------------------------------------------------------------------------------------
  
    OPEN C_crapPRG(SIGLA_TELA, REG_OPER.cdcooper);
    FETCH C_crapPRG
      INTO rg_crapPRG;
  
    IF C_crapPRG%NOTFOUND THEN
    
      CLOSE C_crapPRG;
    
      insert into crapPRG
        (NMSISTEM,
         CDPROGRA,
         DSPROGRA##1,
         DSPROGRA##2,
         DSPROGRA##3,
         DSPROGRA##4,
         NRSOLICI,
         NRORDPRG,
         INCTRPRG,
         CDRELATO##1,
         CDRELATO##2,
         CDRELATO##3,
         CDRELATO##4,
         CDRELATO##5,
         INLIBPRG,
         CDCOOPER,
         QTMINMED)
      values 
        ('CRED', --NMSISTEM
         SIGLA_TELA, --CDPROGRA
         'Alter/Consulta Nota do Rating após a Efetivação', -- DSPROGRA##1
         ' ', -- DSPROGRA##2
         ' ', --DSPROGRA##3 
         ' ', --DSPROGRA##4
         50, --NRSOLICI
         V_NRORDPRG, --NRORDPRG
         1, --INCTRPRG
         0, --CDRELATO##1
         0, --CDRELATO##2
         0, --CDRELATO##3
         0, ---CDRELATO##4 
         0, --CDRELATO##5
         1, --INLIBPRG
         REG_OPER.CDCOOPER, --CDCOOPER
         null); --QTMINMED
    
      DBMS_OUTPUT.PUT_LINE( 'Inseriu em crapPRG Alter./Consulta Nota do Rating após a Efetivação. cooperativa-> ' ||
                           REG_OPER.CDCOOPER||' chave NRORDPRG -> '||V_NRORDPRG);
    ELSE
       CLOSE C_crapPRG;
      DBMS_OUTPUT.PUT_LINE('Inserção em crapPRG não realizada. '||V_NRORDPRG||' tela ' ||
                           SIGLA_TELA || ' Cooperativa:' ||
                           REG_OPER.CDCOOPER);
    END IF;
  end loop;
  commit;
exception
  when others then
    DBMS_OUTPUT.PUT_LINE('Erro: ' || sqlerrm);
    DBMS_OUTPUT.PUT_LINE('Inserção em craptel/crapPRG não realizada. tela ' ||
                         SIGLA_TELA);
end;
0
0
