<?php 
	/*********************************************************************
	 Fonte: buscar_rotina.php                                                 
	 Autor: Renato Darosci                                                   
	 Data : Mai/2015                Última Alteração: 12/05/2017
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela PARFOL                                 
	                                                                  
	 Alterações: 21/10/2015 - Correcao para envio da cddopcao de consulta
	                          na validaPermissao (Marcos-Supero)
	 
				 19/01/2017 - Adicionado novo limite de horario para pagamento no dia
							  para contas da cooperativa. (M342 - Kelvin)
			     
				 12/05/2017 - Segunda fase da melhoria 342 (Kelvin).
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
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","C")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PARFOL", "FOLHAIB_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	// Retornar os valores
	echo 'Cdsvlrprm1.val("'.$xmlObjeto->roottag->tags[0]->cdata.'");';
	echo 'Cdsvlrprm2.val("'.$xmlObjeto->roottag->tags[1]->cdata.'");';
	echo 'Cdsvlrprm3.val("'.$xmlObjeto->roottag->tags[2]->cdata.'");';
	echo 'Cdsvlrprm4.val("'.$xmlObjeto->roottag->tags[3]->cdata.'");';
	echo 'Cdsvlrprm5.val("'.$xmlObjeto->roottag->tags[4]->cdata.'");';
	echo 'Cdsvlrprm6.val("'.$xmlObjeto->roottag->tags[5]->cdata.'");';
	echo 'Cdsvlrprm7.val("'.$xmlObjeto->roottag->tags[6]->cdata.'");';
	echo 'Cdsvlrprm8.val("'.$xmlObjeto->roottag->tags[7]->cdata.'");';
	echo 'Cdsvlrprm9.val("'.$xmlObjeto->roottag->tags[8]->cdata.'");';
	echo 'Cdsvlrprm10.val("'.$xmlObjeto->roottag->tags[9]->cdata.'");';
	echo 'Cdsvlrprm11.val("'.$xmlObjeto->roottag->tags[10]->cdata.'");';
	echo 'Cdsvlrprm12.val("'.$xmlObjeto->roottag->tags[11]->cdata.'");';
	echo 'Cdsvlrprm13.val("'.$xmlObjeto->roottag->tags[12]->cdata.'");';
	echo 'Cdsvlrprm14.val("'.$xmlObjeto->roottag->tags[13]->cdata.'");';
	echo 'Cdsvlrprm15.val("'.$xmlObjeto->roottag->tags[14]->cdata.'");';
	echo 'Cdsvlrprm16.val("'.$xmlObjeto->roottag->tags[15]->cdata.'");';
	echo 'Cdsvlrprm17.val("'.$xmlObjeto->roottag->tags[16]->cdata.'");';
	echo 'Cdsvlrprm18.val("'.$xmlObjeto->roottag->tags[17]->cdata.'");';
	echo 'Cdsvlrprm19.val("'.$xmlObjeto->roottag->tags[18]->cdata.'");';
	echo 'Cdsvlrprm20.val("'.$xmlObjeto->roottag->tags[19]->cdata.'");';
	echo 'Cdsvlrprm21.val("'.$xmlObjeto->roottag->tags[20]->cdata.'");';
	echo 'Cdsvlrprm22.val("'.$xmlObjeto->roottag->tags[21]->cdata.'");';
	echo 'Cdsvlrprm23.val("'.$xmlObjeto->roottag->tags[22]->cdata.'");';
	echo 'Cdsvlrprm24.val("'.$xmlObjeto->roottag->tags[23]->cdata.'");';
	echo 'Cdsvlrprm25.val("'.$xmlObjeto->roottag->tags[24]->cdata.'");';
	
	//Se habilita transferencia retornar falso desabilitar a tarifa
	if ($xmlObjeto->roottag->tags[22]->cdata == "0"){
		echo "Cdsvlrprm25.prop('disabled', true);";
		echo "Cdsvlrprm24.prop('disabled', true);";
	}
	echo 'Cdsvlrprm1.focus();';
?>
