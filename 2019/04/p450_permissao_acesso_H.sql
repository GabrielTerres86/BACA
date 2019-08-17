/* Libera acesso a tela RATMOV para os operadores com privilégio consultar histórico rating */
declare 
  cursor cr_crapcop is
  select cdcooper 
    from crapcop
   where flgativo = 1
   --and cdcooper = 3
   ;
    rw_crapcop cr_crapcop%ROWTYPE; 
 
  cursor cr_crapope(pr_cdcooper in crapcop.cdcooper%TYPE) is
  select cdoperad 
    from crapope
   where cdcooper =   pr_cdcooper
    and   UPPER( cdoperad) in ('F0032113','F0030517','F0030516','F0031090', 'F0030689')  ;
  rw_crapope cr_crapope%ROWTYPE;
 SIGLA_TELA varchar2(400);
begin
  
SIGLA_TELA := 'RISCO';
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
  
    --FAZ O INSERT PARA OPERADORES DO GRUPO CONTROLE CONSULTAR
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper) LOOP
    
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
        , 'H'
        , rw_crapope.cdoperad
        , ' '
        , rw_crapcop.cdcooper
        , 1
        , 1
        , 1
      ); 
        DBMS_OUTPUT.PUT_LINE('Inserção em crapace  realizada com sucesso!  tela ' ||
                           SIGLA_TELA || ' Cooperativa:' ||
                           rw_crapcop.CDCOOPER||'Operador '||rw_crapope.cdoperad);                
      EXCEPTION
        WHEN dup_val_on_index THEN
           DBMS_OUTPUT.PUT_LINE('Inserção em crapace não realizada.  JÁ EXISTE REGISTRO PARA  OPERADOR ' ||
                           rw_crapope.cdoperad || ' Cooperativa:' ||
                          rw_crapcop.cdcooper|| ' OPÇÃO H ');
         END;
 
    END LOOP;
   
  
  END LOOP;
  
  COMMIT;
end;



