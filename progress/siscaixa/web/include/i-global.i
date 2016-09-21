/*

Include que valida se o usuário já efetuou o login e carrega as variáveis 
iniciais do cabecalho

Alteracoes: 15/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).

*/

    /* Se for a tela de mensagem que usou a include, nao redireciona para
       a tela inicial do caixa */
    IF get-value("user_log") <> "yes" THEN
       {&out} "<script>"
              "if(window.name!='werro')~{"
                "parent.location='crap001.w';"
              "~}"
              "</script>".

    FIND crapcop WHERE crapcop.nmrescop = get-value("user_coop")
                       NO-LOCK NO-ERROR.

    /* Forca uma saida caso nao encontre a cooperativa */
    IF   NOT AVAILABLE crapcop   THEN
         {&out} "<script>"
                "parent.location='index.html';"
                "</script>".

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    /* Forca uma saida caso nao encontre a data */
    IF   NOT AVAILABLE crapdat   THEN
         {&out} "<script>"
                "parent.location='index.html';"
                "</script>".

    ASSIGN ab_unmap.v_coop     = crapcop.nmrescop
           ab_unmap.v_data     = STRING(crapdat.dtmvtolt,"99/99/9999")
           ab_unmap.v_pac      = get-value("user_pac")
           ab_unmap.v_caixa    = get-value("user_cx")
           ab_unmap.v_operador = get-value("operador")

           /* Msg Alerta p/ Usuario -- Todas telas do Sistema */
           ab_unmap.v_msg      = "   ".  
       
