<?php
/*!
 * FONTE        : responsavel_legal2.php
 * CRIAÇÃO      : Adriano
 * DATA CRIAÇÃO : 04/05/2012 
 * OBJETIVO     : Mostra rotina de Reponsavel Legal da tela de CONTAS
 *
 * ALTERACOES   : 29/09/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *							 13/07/2016 - Correcao do uso da variavel $op indefinida. SD 479874. Carlos R.
 */	
 
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$flgcadas = ( isset($_POST['flgcadas']) ) ? $_POST['flgcadas'] : null;
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	$op           = ( $flgcadas == null ) ? '@'  : $flgcadas;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,false);
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST['nmdatela']) || !isset($_POST['nmrotina'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);		
		
	include('../../../includes/responsavel_legal/responsavel_legal2.php');
	
	
?>
	
	
