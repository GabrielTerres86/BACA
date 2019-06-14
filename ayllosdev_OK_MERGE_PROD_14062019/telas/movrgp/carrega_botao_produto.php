<?php
/*!
 * FONTE        : carrega_botao_produto.php();.php                    �ltima altera��o:
 * CRIA��O      : Jonata (RKAM)
 * DATA CRIA��O : Maio/2017
 * OBJETIVO     : Rotina para busca informa��es para montar o campo produto da tela MOVRGP
 * --------------
 * ALTERA��ES   :  
 *
 */
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// Carrega permiss�es do operador
	require_once('../../includes/carrega_permissoes.php');	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$cdcopsel = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	validaDados();
		
	$xmlBuscarInfoFiltro  = "";
	$xmlBuscarInfoFiltro .= "<Root>";
	$xmlBuscarInfoFiltro .= "   <Dados>";
	$xmlBuscarInfoFiltro .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlBuscarInfoFiltro .= "	   <cdcopsel>".$cdcopsel."</cdcopsel>";
	$xmlBuscarInfoFiltro .= "   </Dados>";
	$xmlBuscarInfoFiltro .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscarInfoFiltro, "TELA_MOVRGP", "CARREGACAMPOPROD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscarInfoFiltro = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjBuscarInfoFiltro->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjBuscarInfoFiltro->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjBuscarInfoFiltro->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cddopcao";
		}
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input\',\'#frmCabParrgp\').removeClass(\'campoErro\');unblockBackground(); estadoInicial();',false);		
							
	}   	
	
	$produtos  = $xmlObjBuscarInfoFiltro->roottag->tags[0]->tags;	
				
	include('form_filtro_produto.php');	
			
	function validaDados(){
		
		//ID do produto
        if (  $GLOBALS["cdcopsel"] == 0 ){
            exibirErro('error','C&oacute;digo da cooperativa inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'cdcopsel\',\'frmFiltroCoop\');',false);
        }
		
	}
	
?>
