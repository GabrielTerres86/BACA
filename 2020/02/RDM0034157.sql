/*
 * Procedure para processar os arquivos de atualizacao dos enderecos com base nos enderecos disponibilizados pelos correios
 *
 * Leia com atencao as instrucoes nesse programa antes de continuar
 * Instrucoes:
 *   1 - Antes de iniciar o processo verifique se os arquivos estao no diretorio que sera processado
 *       Atualmente esta configurado para: /micros/cecred/correios/
 *
 *   2 - Os arquivos "LOG_LOCALIDADE.TXT" e "LOG_BAIRRO.TXT" sao obrigatorios
 *       Sem esses arquivos o processo nao sera executado
 * 
 *   3 - Os arquivos que devem ser processados devem possui o nome do arquivo e a extensao todos em MAIUSCULO
 *   
 *   4 - Para que o arquivo UNID OPER seja processado deve-se alterar a variavel vr_proc_arq_unid_oper para '1'
 *       Caso nao seja necessario sua importacao a variavel vr_proc_arq_unid_oper deve ser alterada para '0'
 *
 *   5 - Para que o arquivo GRANDE USUARIO seja processado deve-se alterar a variavel vr_proc_arq_grande_usuario para '1'
 *       Caso nao seja necessario sua importacao a variavel vr_proc_arq_grande_usuario deve ser alterada para '0'
 *
 *   6 - Para que o arquivo CAIXA POSTAL COMUNITARIA seja processado deve-se alterar a variavel vr_proc_arq_cpc para '1'
 *       Caso nao seja necessario sua importacao a variavel vr_proc_arq_cpc deve ser alterada para '0'
 *
 *   7 - No final do arquivo esta a lista de estados que podem ser processados, para processar estados especificos deve-se
 *       informar a sigla do estado na variavel vr_proc_arq_sigla_estado
 *       7.1 -> Para processar todos os estados esse campo nao deve ser informado 
 *       7.2 -> Para nao processar nenhum arquivo de estado deve ser informado "NADA" 
 *       7.3 -> Para processar apenas alguns estados informar as siglas correspondentes separadas por ";" (Ex: 'SC;PR;RS')
 *
 *   8 - Se ocorreu erro, a mensagem de critica sera exibida na aba "DBMS Output"
 *
 *   9 - As criticas que acontecerem quando esta sendo desmontado o arquivo sera escrita no arquivo ERRO_LEITURA*.TXT
 *
 *  10 - As criticas que acontecerem quando esta sendo inserido o endereco na base sera escrita no arquivo ERRO_INSERT*.TXT
 *
 *   Desenvolvido por: Douglas Quisinski
 *
 */

declare
  vr_proc_arq_unid_oper      INTEGER;
  vr_proc_arq_grande_usuario INTEGER;
  vr_proc_arq_cpc            INTEGER;
  vr_proc_arq_sigla_estado   VARCHAR(200);
  
  -- Criticas
  vr_tab_erro cecred.gene0001.typ_tab_erro;
  vr_ind      INTEGER;

begin
  
  -- Informar se sera processado o arquivo UNID OPER (0-NAO / 1-SIM)
  vr_proc_arq_unid_oper      := 1;
  -- Informar se sera processado o arquivo GRANDE USUARIO (0-NAO / 1-SIM)
  vr_proc_arq_grande_usuario := 1;
  -- Informar se sera processado o arquivo CAIXA POSTAL COMUNITARIA (0-NAO / 1-SIM)
  vr_proc_arq_cpc            := 1;
  -- Informar a sigla do estado que sera processada (consulta lista de siglas no fim deste arquivo)
  -- Para processar todos os estados esse campo nao deve ser informado
  -- Para nao processar nenhum arquivo de estado deve ser informado "NADA" para o campo abaixo
  -- Para processar apenas alguns estados informar as siglas correspondentes separadas por ";"
  -- Ex: 'SC;PR;RS'
  vr_proc_arq_sigla_estado   := '  ';

  -- Chamada do processamento dos arquivos
  cecred.tela_caddne.pc_proc_arq_correio(pr_fluniope => vr_proc_arq_unid_oper
                                        ,pr_flgrausu => vr_proc_arq_grande_usuario
                                        ,pr_flcpc    => vr_proc_arq_cpc
                                        ,pr_nmestado => vr_proc_arq_sigla_estado
                                        ,pr_tab_erro => vr_tab_erro);
                                         
  -- verifica se ocorreu erro
  IF vr_tab_erro.COUNT() > 0 THEN
    -- Percorrer os erros e exibi-los no "DBMS Output"
    FOR vr_ind IN vr_tab_erro.FIRST..vr_tab_erro.LAST LOOP
      dbms_output.put_line(vr_tab_erro(vr_ind).dscritic);
    END LOOP;
  END IF;

/*********************     ARQUIVOS OBRIGATORIOS     **********************
Arquivo LOCALIDADE  - LOG_LOCALIDADE.TXT
Arquivo BAIRRO      - LOG_BAIRRO.TXT

***********     SIGLAS DOS ESTADOS QUE PODEM SER PROCESSADOS     **********

  SIGAL - ESTADO - Arquivo que sera processado 

  AC - Acre                  - LOG_LOGADROURO_AC.TXT
  AL - Alagoas               - LOG_LOGADROURO_AL.TXT
  AP - Amapa                 - LOG_LOGADROURO_AP.TXT
  AM - Amazonas              - LOG_LOGADROURO_AM.TXT
  BA - Bahia                 - LOG_LOGADROURO_BA.TXT
  CE - Ceara                 - LOG_LOGADROURO_CE.TXT
  DF - Distrito Federal      - LOG_LOGADROURO_DF.TXT
  ES - Esperito Santo        - LOG_LOGADROURO_ES.TXT
  GO - Goias                 - LOG_LOGADROURO_GO.TXT
  MA - Maranhao              - LOG_LOGADROURO_MA.TXT
  MT - Mato Grosso           - LOG_LOGADROURO_MT.TXT
  MS - Mato Grosso do Sul    - LOG_LOGADROURO_MS.TXT
  MG - Minas Gerais          - LOG_LOGADROURO_MG.TXT
  PA - Para                  - LOG_LOGADROURO_PA.TXT
  PB - Paraiva               - LOG_LOGADROURO_PB.TXT
  PR - Parana                - LOG_LOGADROURO_PR.TXT
  PE - Pernambuco            - LOG_LOGADROURO_PE.TXT
  PI - Piaui                 - LOG_LOGADROURO_PI.TXT
  RJ - Rio de Janeiro        - LOG_LOGADROURO_RJ.TXT
  RN - Rio Grande do Norte   - LOG_LOGADROURO_RN.TXT
  RS - Rio Grande do Sul     - LOG_LOGADROURO_RS.TXT
  RO - Rondonia              - LOG_LOGADROURO_RO.TXT
  RR - Roraima               - LOG_LOGADROURO_RR.TXT
  SC - Santa Catarina        - LOG_LOGADROURO_SC.TXT
  SP - Sao Paulo             - LOG_LOGADROURO_SP.TXT
  SE - Sergipe               - LOG_LOGADROURO_SE.TXT
  TO - Tocantins             - LOG_LOGADROURO_TO.TXT
  EX - Estrangeiro           - LOG_LOGADROURO_EX.TXT


*************************     OUTROS ARQUIVOS     *************************
Arquivo UNID OPER                - LOG_UNID_OPER.TXT
Arquivo GRANDE USUARIO           - LOG_GRANDE_USUARIO.TXT
Arquivo CAIXA POSTAL COMUNITARIA - LOG_CPC.TXT

**************************************************************************/

end;
/

