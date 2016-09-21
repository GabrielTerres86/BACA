<?php

/* !
 * FONTE        : excluir_lcr_finali.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : 10/08/2015
 * OBJETIVO     : Excluir Linhas de Crédito atreladas à finalidade - Tela FINALI
 * --------------
 * ALTERACOES   : 10/08/2015 - Alterações e correções (Lunelli SD 102123)
 * --------------
 */

session_cache_limiter("private");
session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : 0;
$camposDc = (isset($_POST['camposDc']))  ? $_POST['camposDc']  : '' ;
$dadosDc  = (isset($_POST['dadosDc']))   ? $_POST['dadosDc']   : '' ;
	
if ($cdfinemp == 0) {
	exibeErro("C&oacute;digo da Finalidade inv&aacute;lido.");
}

$retornoAposErro = 'estadoInicial();';

echo "alert('aaa');";
if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}
echo "alert('bbbb');";
// Monta o xml dinâmico de acordo com a operação
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0167.p</Bo>';
$xml .= '		<Proc>excluir-lcr-finali</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
$xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';	
$xml .= '       <cdfinemp>'.$cdfinemp.'</cdfinemp>';
$xml .= 		retornaXmlFilhos( $camposDc, $dadosDc, 'FinaliLcr', 'Itens');
$xml .= '	</Dados>';
$xml .= '</Root>';

echo "alert('ccc');";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

echo "alert('ddd');";

// ----------------------------------------------------------------------------------------------------------------------------------
// Controle de Erros
// ----------------------------------------------------------------------------------------------------------------------------------
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {		
		exibirErro('error', "adriano".$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','estadoInicial();',false);
		
	} 	
	
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro, false);
}

?>