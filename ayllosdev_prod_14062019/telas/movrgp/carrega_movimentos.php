<?php
/*!
 * FONTE        : carrega_movimentos.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina para buscar produtos cadastrados na tela MOVRGP
 * --------------
 * ALTERAÇÕES   :  
 *
 */
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcopsel  = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;
	$dtrefere  = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	$cdproduto = (isset($_POST["cdproduto"])) ? $_POST["cdproduto"] : 0;
	$nriniseq  = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 0;
	$nrregist  = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 0;
		
	validaDados();
	
	$xmlBuscarProdutos  = "";
	$xmlBuscarProdutos .= "<Root>";
	$xmlBuscarProdutos .= "   <Dados>";
	$xmlBuscarProdutos .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlBuscarProdutos .= "	   <cdcopsel>".$cdcopsel."</cdcopsel>";
	$xmlBuscarProdutos .= "	   <dtrefere>".$dtrefere."</dtrefere>";
	$xmlBuscarProdutos .= "	   <idproduto>".$cdproduto."</idproduto>";
	$xmlBuscarProdutos .= "	   <nriniseq>".$nriniseq."</nriniseq>";
	$xmlBuscarProdutos .= "	   <nrregist>".$nrregist."</nrregist>";
	$xmlBuscarProdutos .= "   </Dados>";
	$xmlBuscarProdutos .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscarProdutos, "TELA_MOVRGP", "CARREGAMVOTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscarProdutos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBuscarProdutos->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjBuscarProdutos->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjBuscarProdutos->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdproduto";
		}
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input\',\'#frmFiltroProduto\').removeClass(\'campoErro\');unblockBackground(); formataFiltroProduto();',false);		
							
	}   	
	
	$produtos = $xmlObjBuscarProdutos->roottag->tags[0]->tags[0]->tags;	
	$totais = $xmlObjBuscarProdutos->roottag->tags[0]->tags[1];	
	$qtregist = $xmlObjBuscarProdutos->roottag->tags[0]->attributes['QTREGIST'];
					
	include('tab_registros.php');	
			
	function validaDados(){
		
		//Código da cooperativa
        if (  $GLOBALS["cdcopsel"] == 0 ){
            exibirErro('error','C&oacute;digo da cooperativa inv&aacute;lida.','Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);
        }
		
		//Data de referência
        if (  $GLOBALS["dtrefere"] == '' ){
            exibirErro('error','Data de refer&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);
        }
		
		//Código do produto
        if (  $GLOBALS["cdproduto"] == 0 ){
            exibirErro('error','C&oacute;digo do produto inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'cdproduto\',\'frmFiltroProduto\');',false);
        }
		
	}
	
?>
