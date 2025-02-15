PL/SQL Developer Test script 3.0
130
/* Libera acesso a tela RATMOV para os operadores do  cdcooper = 3. */
declare 
  cursor cr_crapcop is
  select cdcooper 
    from crapcop
   where flgativo = 1
     and cdcooper <> 3
   ;
    rw_crapcop cr_crapcop%ROWTYPE; 
 
  cursor cr_crapope(pr_cdcooper in crapcop.cdcooper%TYPE, pr_cddepart in crapope.cddepart%TYPE) is
  select cdoperad 
    from crapope
   where cdcooper =   pr_cdcooper
     and cddepart =   pr_cddepart;
  rw_crapope cr_crapope%ROWTYPE;
 SIGLA_TELA varchar2(400);
begin
  
SIGLA_TELA := 'RATMOV';
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
  
    --FAZ O INSERT PARA OPERADORES DO GRUPO CONTROLE CONSULTAR
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper, 14) LOOP
    
  BEGIN 
    insert into crapace (
          nmdatela
        , cddopcao
        , cdoperad
        , nmrotina
        , cdcooper
        , nrmodulo
        , idevento
        , idambace
      )
      values (
         SIGLA_TELA
        , 'C'
        , rw_crapope.cdoperad
        , ' '
        , rw_crapcop.cdcooper
        , 8
        , 0
        , 2
      ); 
        DBMS_OUTPUT.PUT_LINE('Inser��o em crapace  realizada com sucesso!  tela ' ||
                           SIGLA_TELA || ' Cooperativa:' ||
                           rw_crapcop.CDCOOPER||'Operador '||rw_crapope.cdoperad);                
      EXCEPTION
        WHEN dup_val_on_index THEN
           DBMS_OUTPUT.PUT_LINE('Inser��o em crapace n�o realizada.  J� EXISTE REGISTRO PARA  OPERADOR ' ||
                           rw_crapope.cdoperad || ' Cooperativa:' ||
                          rw_crapcop.cdcooper|| ' OP��O C ');
         END;
 
    END LOOP;
    -- FAZ O INSERT PARA OPERADORES DO GRUPO PRODUTO ALTERAR
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper, 7) LOOP
      BEGIN
      insert into crapace (
          nmdatela
        , cddopcao
        , cdoperad
        , nmrotina
        , cdcooper
        , nrmodulo
        , idevento
        , idambace
      )
      values (
         SIGLA_TELA
        , 'A'
        , rw_crapope.cdoperad
        , ' '
        , rw_crapcop.cdcooper
        , 8
        , 0
        , 2
      );  
      DBMS_OUTPUT.PUT_LINE('Inser��o em crapace  realizada com sucesso!  tela ' ||
                           SIGLA_TELA || ' OP��O A. Cooperativa:' ||
                           rw_crapcop.CDCOOPER||'Operador '||rw_crapope.cdoperad);      
       EXCEPTION
        WHEN dup_val_on_index THEN
           DBMS_OUTPUT.PUT_LINE('Inser��o em crapace n�o realizada.  J� EXISTE REGISTRO PARA  OPERADOR ' ||
                           rw_crapope.cdoperad || ' Cooperativa:' ||
                          rw_crapcop.cdcooper|| ' OP��O A ');
     END;
     
     BEGIN     
      insert into crapace (
          nmdatela
        , cddopcao
        , cdoperad
        , nmrotina
        , cdcooper
        , nrmodulo
        , idevento
        , idambace
      )
      values (
          SIGLA_TELA
        , 'C'
        , rw_crapope.cdoperad
        , ' '
        , rw_crapcop.cdcooper
        , 8
        , 0
        , 2
      );   
            DBMS_OUTPUT.PUT_LINE('Inser��o em crapace  realizada com sucesso!  tela ' ||
                           SIGLA_TELA || ' OP��O C. Cooperativa:' ||
                           rw_crapcop.CDCOOPER||'Operador '||rw_crapope.cdoperad);                     
    EXCEPTION
        WHEN dup_val_on_index THEN
             DBMS_OUTPUT.PUT_LINE('Inser��o em crapace n�o realizada.  J� EXISTE REGISTRO PARA  OPERADOR ' ||
                           rw_crapope.cdoperad || ' Cooperativa:' ||
                          rw_crapcop.cdcooper|| ' OP��O C ');
         END;
  
  
  END LOOP; 
  
  END LOOP;
  
  COMMIT;
end;

0
0
