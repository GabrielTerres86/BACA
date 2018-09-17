<?php 
/*!
 * FONTE      : consulta.php                                        
 * AUTOR      : Lucas R                                                   
 * DATA       : Novembro/2013                																  
 * OBJETIVO   : Consultar dados da CONCAP.
 *--------------------
 * ALTERACÇÕES:    
 * 
 *--------------------											   
 */		
	
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica permissão
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"T");
		
	$cddopcao = $_POST["cddopcao"];
	$cdagenci = $_POST["cdagenci"];
	$dtmvtolt = $_POST["dtmvtolt"];
	$opcaoimp = $_POST["opcaoimp"];
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ; 
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ; 
			
	// Monta o xml de requisição
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= "	<Cabecalho>";
	$xmlConsulta .= "		<Bo>b1wgen0180.p</Bo>";
	$xmlConsulta .= "		<Proc>consulta-captacao</Proc>";
	$xmlConsulta .= "	</Cabecalho>";
	$xmlConsulta .= "	<Dados>";
	$xmlConsulta .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "		<dtmvtolt>".$dtmvtolt."</dtmvtolt>";
	$xmlConsulta .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlConsulta .= "		<opcaoimp>".$opcaoimp."</opcaoimp>";
	$xmlConsulta .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsulta .= "		<cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	$xmlConsulta .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlConsulta .= "		<nrregist>".$nrregist."</nrregist>";
	$xmlConsulta .= "		<nriniseq>".$nriniseq."</nriniseq>";	
	$xmlConsulta .= "	</Dados>";
	$xmlConsulta .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjConsulta = getObjectXML($xmlResult);
	
	$msgErro = $xmlObjConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata;
	
    // Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsulta->roottag->tags[0]->name) == "ERRO") { 
		echo "<script>";
		echo "$('#divOpcaoT').css({'display':'none'});";
		
		echo "</script>";
		
		exibirErro('error',$msgErro,'Alerta - BLQJUD','$(\'#cdagenci\',\'#frmOperacao\').focus();',true);				
	}		
	
	$vltotapl = $xmlObjConsulta->roottag->tags[0]->attributes["VLTOTAPL"];
	$vltotrgt = $xmlObjConsulta->roottag->tags[0]->attributes["VLTOTRGT"];
	$vlcapliq = $xmlObjConsulta->roottag->tags[0]->attributes["VLCAPLIQ"];
	$qtregist = $xmlObjConsulta->roottag->tags[0]->attributes['QTREGIST'];
	
	$dados = $xmlObjConsulta->roottag->tags[0]->tags;	
	
	echo "<script>";
		echo "$('#divOpcaoT').css({'display':'block'});";
				
		echo "$('#vltotapl','#frmOpcaoT').val('".number_format(str_replace(",",".",$vltotapl),2,",",".")."');";
		echo "$('#vltotrgt','#frmOpcaoT').val('".number_format(str_replace(",",".",$vltotrgt),2,",",".")."');";
		echo "$('#vlcapliq','#frmOpcaoT').val('".number_format(str_replace(",",".",$vlcapliq),2,",",".")."');";
										
	echo "</script>"; 
				
	include('form_opcaoT.php'); 
	include('form_tab_opcaoT.php');
	
?>
