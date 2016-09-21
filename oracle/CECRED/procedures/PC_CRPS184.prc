CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS184 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                              ,pr_dtrefere IN crapdat.dtmvtolt%TYPE
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ..........................................................................
 Programa: PC_CRPS184 (Antigo Fontes/crps184.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006                  Ultima atualizacao: 28/09/2015

   Dados referentes ao programa:

   Frequencia: Tela.
   Objetivo  : Atende a solicitacao 104.
               Emite relatorio da provisao para creditos de liquidacao duvidosa
               (227).

   Alteracoes: 16/02/2006 - Criadas variaveis p/ listagem de Riscos por PAC
                            (Diego).
                            
               04/12/2009 - Retirar o nao uso mais do buffer crabass 
                            e aux_recid (Gabriel).             

               24/08/2010 - Incluir w-crapris.qtatraso (Magui).
               
               25/08/2010 - Inclusao das variaveis aux_rel1725, aux_rel1726,
                            aux_rel1725_v, aux_rel1726_v. Devido a alteracao
                            na includes crps280.i (Adriano).
                            
               19/10/2012 - Incluido variaveis aux_rel1724 devido as alteracoes
                            na include crps280.i (Rafael).
                            
               22/04/2013 - Incluido os campos cdorigem, qtdiaatr na criacao 
                            da temp-table w-crapris (Adriano).   
                            
               21/06/2013 - Adicionado campo w-crapris.nrseqctr (Lucas)
               
               02/08/2013 - Removido a declaracao da temp-table w-crapris.
                            (Fabricio)
                            
               28/09/2015 - Convers�o Progress >> Oracle PL-Sql (Vanessa) 
............................................................................. */

   DECLARE
      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros para parar a cadeia
      vr_exc_saida exception;
      -- Tratamento de erro sem parar a cadeia
      vr_exc_fimprg exception;
      -- Erro em chamadas da pc_gera_erro
      --vr_des_reto VARCHAR2(3);
      -- Codigo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      -- Descricao da critica
      vr_dscritic VARCHAR2(2000);
      
      ---------------- Cursores gen�ricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrctactl
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Valores para retorno da crps280.i
      vr_vltotprv NUMBER(14,2); --> Total acumulado de provis�o
      vr_vltotdiv NUMBER(14,2); --> Total acumulado de d�vida
      
     
   ---------------------------------------
   -- Inicio Bloco Principal pc_crps184
   ---------------------------------------

   BEGIN
      -- C�digo do programa
      vr_cdprogra := 'CRPS184';

      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS184'
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haver� raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic := 651;
         RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
      END IF;

      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois efetuaremos raise
         CLOSE btch0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic := 1;
         RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
         CLOSE btch0001.cr_crapdat;
      END IF;
          
      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

      -- Se a variavel de erro � <> 0
      IF vr_cdcritic <> 0 THEN
         -- Envio centralizado de log de erro
         RAISE vr_exc_saida;
      END IF;
      
     
      -- Chamar a rotina crps280_i (Antiga includes/crps280.i)
      pc_crps280_i(pr_cdcooper   => pr_cdcooper         --> Coop. conectada
                  ,pr_rw_crapdat => rw_crapdat          --> Vetor com calend�rio
                  ,pr_dtrefere   => pr_dtrefere         --> Data ref - Ultimo dia m�s corrente
                  ,pr_cdprogra   => vr_cdprogra         --> Codigo programa conectado
                  ,pr_dsdircop   => rw_crapcop.dsdircop --> Diret�rio base da cooperativa
                  ,pr_vltotprv   => vr_vltotprv         --> Total acumulado de provis�o
                  ,pr_vltotdiv   => vr_vltotdiv         --> Total acumulado de d�vida
                  ,pr_cdcritic   => vr_cdcritic         --> C�digo de erro encontrado
                  ,pr_dscritic   => vr_dscritic);       --> Descri��o de erro encontrado

      -- Retornar nome do m�dulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

      -- Testar sa�da de erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar commit final
      COMMIT;

   EXCEPTION
      WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas c�digo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descri��o
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Se foi gerada critica para envio ao log
         IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         END IF;
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         -- Efetuar commit pois gravaremos o que foi processo at� ent�o
         COMMIT;
      WHEN vr_exc_saida THEN
         -- Se foi retornado apenas c�digo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descri��o
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos c�digo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;
      WHEN OTHERS THEN
         -- Efetuar retorno do erro n�o tratado
         pr_cdcritic := 0;
         pr_dscritic := SQLERRM;
         -- Efetuar rollback
         ROLLBACK;
   END;
END pc_crps184;
/
