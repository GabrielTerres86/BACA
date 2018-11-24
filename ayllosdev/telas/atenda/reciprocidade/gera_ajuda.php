<?php 
    /**************************************************************************
      Fonte: gera_ajuda.php
      Autor: Jaison
      Data : Abril/2016                   Última Alteração: 

      Objetivo  : Carregar dados para impressões dos emprestimos

      Alterações: 
     ************************************************************************* */

    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
    require_once("../../../includes/config.php");
    require_once("../../../includes/funcoes.php");
    require_once("../../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo método POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../../class/xmlfile.php");

    $xml = '';
    $xml .= '<Root>';
    $xml .= '	<Dados />';
    $xml .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "GERA_ARQ_AJUDA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
        $msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
        exit();
    }

    // Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    $nmarqpdf = $xmlObject->roottag->tags[0]->cdata;

	// Imprime o nome do arquivo
	echo $nmarqpdf;
?>