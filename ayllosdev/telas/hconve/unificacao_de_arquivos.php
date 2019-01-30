<?php
/*!
 * FONTE        : unificacao_de_arquivos.php
 * CRIAÇÃO      : Gabriel Marcos - (Mouts)
 * DATA CRIAÇÃO : 28/11/2018
 * OBJETIVO     : 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');	
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

require_once("../../includes/carrega_permissoes.php");

$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibirErro('error',$msgError,'Alerta - Aimaro','',false);
}

$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0092.p</Bo>';
$xml .= '		<Proc>exec_unificacao_arquivos</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '	</Dados>';
$xml .= '</Root>';

//$retornoAposErro = 'focaCampoErro(\'cdalinea\', \'frmAlinea\');';
$retornoAposErro = 'bloqueiaFundo(divRotina);';

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

// --------------------------------------------------------------------------------------------------------------------
// Controle de Erros
// --------------------------------------------------------------------------------------------------------------------
if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
}else{
	//echo $xmlResult;
	exibirErro('inform','Arquivo homologado com sucesso!','Alerta - Ayllos','hideMsgAguardo();btnContinuar(1,30);',false);
}