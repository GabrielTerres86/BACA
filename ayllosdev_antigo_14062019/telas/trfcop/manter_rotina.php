<?php 
	/*********************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Gabriel                                                     
	 Data : Outubro/2011                Última Alteração: 26/12/2012  
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela TRFCOP.                                  
	                                                                  
	 Alterações: 26/12/2012 - Tratar paginacao da listagem (Gabriel)

				 14/03/2013 - Incluir nova informacao de Origem (Gabriel)	 
	**********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
				
	$cddopcao = $_POST["cddopcao"]; /* Opcao */
	$dttransa = $_POST["dttransa"]; /* Data transacao */
	$tpoperac = $_POST["tpoperac"]; /* Deposito/Transferencia */
	$tpdenvio = $_POST["tpdenvio"]; /* Envio/Recebimento */
	$vlaprcoo = $_POST["vlaprcoo"]; /* Valor aprovacao cx.online*/
	$cdpacrem = $_POST["cdpacrem"];
	$nrregist = 30;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
	
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"",substr($cddopcao,0,1))) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
	
	if ($cddopcao == 'L1' || $cddopcao == 'L2') {
		// Verifica se flag de identificação do log é válida
		if ($tpoperac != '1' && $tpoperac != '2') {	
			exibirErro('error','Tipo de opera&ccedil;&atilde;o inv&aacute;lido.','Alerta - Ayllos','voltar()',false);
		}
		
		// Verifica se tipo do log é um inteiro válido
		if ($tpdenvio != "1" && $tpdenvio != "2") {
			exibirErro('error','Tipo de envio inv&aacute;lido.','Alerta - Ayllos','voltar()',false);
		}	
	}
		
	// Verifica Opcao 	
	switch($cddopcao) {
		case 'L1': {
		  $procedure = 'busca-operacoes';	
		} break;
		case 'P1': {
		  $procedure = 'busca-parametro';	
		} break;		
		case 'P2': {
		  $procedure = 'altera-parametro';	
		} break;			
	}			
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0118.p</Bo>";
	$xml .= "    <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "    <dttransa>".$dttransa."</dttransa>";
	$xml .= "    <tpoperac>".$tpoperac."</tpoperac>";
	$xml .= "    <tpdenvio>".$tpdenvio."</tpdenvio>";
	$xml .= "    <cdpacrem>".$cdpacrem."</cdpacrem>";
	$xml .= "    <vlaprcoo>".$vlaprcoo."</vlaprcoo>";
	$xml .= "	 <nrregist>".$nrregist."</nrregist>";
	$xml .= "	 <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','voltar()',false);
	} 	
	
	// Verifica opcao 	
	switch($cddopcao) {

		case 'L1': {
			$logCompleto   = $xmlObjLog->roottag->tags[0]->tags;
			$qtregist      = $xmlObjLog->roottag->tags[0]->attributes["QTREGIST"];
			$qtLogCompleto = count($logCompleto);	
						
			include ('form_log.php'); 
						
		} break;
		
		case 'P1': {
			$vlaprcoo = $xmlObjLog->roottag->tags[0]->attributes["VLAPRCOO"];	

			echo '$("#vlaprcoo","#divOpcao_P").focus();';			
			echo '$("#vlaprcoo","#divOpcao_P").val("'.$vlaprcoo.'");'; 
			echo 'cddopcao = "P2";';
		
		} break;
		
		case 'P2': {
		    echo 'voltar();';
		} break;
			
	} 
		
	echo 'hideMsgAguardo();';	
		
?>
