<?php
	/*********************************************************************************************
	 Fonte     : carrega_justificativas.php                                                     
	 Autor     : Cristian Filipe Fernandes (GATI)                                          
	 Data      : 05/09/2013                                                                
	 Objetivo  : Efetuar pesquisa de Justificativas Tela CLDSED                            
	 
	 Alterações: 25/04/2016 - Corrigir passagem do parâmetro cddopcao conforme solicitado no
 							  chamado 430180. (Kelvin)                                                                                        
	*********************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	$cddopcao  = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : "" ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);	
	}
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$cddjusti  = $_POST['cddjusti'];
	$tipoBusca = $_POST['tipoBusca'];
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0173.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>Carrega_justificativas</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= '        <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlSetPesquisa .= '        <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlSetPesquisa .= '        <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlSetPesquisa .= '        <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlSetPesquisa .= '        <idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlSetPesquisa .= '        <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlSetPesquisa .= '        <cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa );
	// Cria objeto para classe de tratamento de XML
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}	
	$registros = $xmlObjPesquisa->roottag->tags[0]->tags;
	
	$dsdjusti = "";
	if($tipoBusca == "pesquisa")	{
		foreach($registros as $values){
			if(getByTagName($values->tags, 'cddjusti') == $cddjusti) {
				$dsdjusti = getByTagName($values->tags, 'dsdjusti');
				echo "$('#dsdjusti', '#frmInfConsultaMovimentacao').val('".$dsdjusti."')";
			}
		}
		if($dsdjusti == "") {
			exibirErro("error","C&oacute;digo da Justificativa Inv&aacute;lido","Alerta - Ayllos","focaCampoErro('cddjusti', 'frmInfConsultaMovimentacao');",false);
		}
	} else{
		include('tab_justificativa.php');
	}
?>