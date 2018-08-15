/* Seta produto Aplic Aut como Aplicação Programada default
   Insere na tabela de parâmetros o produto substituto da Poupança Programada

  Atenção!!! O produto deverá ser previamente cadastrado através da "pcapta"  e PRINCIPALMENTE a cláusula
  Where NMPRODUT = 'Aplic Aut' deverá ser corrigido para ter o nome correto do produto. 
   
*/   
DECLARE
  vr_cdprodut NUMBER(5) := 0;
Begin
  Begin
    Select CDPRODUT
      Into vr_cdprodut
      From crapcpc
     Where NMPRODUT = 'Aplic Aut'; -- Fix Me!
  Exception
    when no_data_found then
      raise_application_error(-20001,
                              'Produto "Aplic Aut" deve ser cadastrado através da PCAPTA previamente');
    
    when others then
      raise_application_error(-20002,
                              'Ocorreu o erro: ' || SQLCODE || ' - ' ||
                              SQLERRM);
  End;
  If vr_cdprodut <> 0 then
    Begin
      -- Seta produto Aplic Aut como Aplicação Programada default
      Update crapcpc
      Set INDPLANO = 1
      Where CDPRODUT = vr_cdprodut;     
      -- Insere na tabela de parâmetros o produto substituto da Poupança Programada
      Insert into crapprm
        (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
      Values
        ('CRED',
         0,
         'COD_MIGRACAO_APL_PROG',
         'Codigo do Produto de Aplicacao Programada substituindo a Poupanca Programada',
         vr_cdprodut);
         Commit;
    Exception
      when others then
        raise_application_error(-20002,
                                'Ocorreu o erro: ' || SQLCODE || ' - ' ||
                                SQLERRM);
        Rollback;
    End;
  End If;
End;

