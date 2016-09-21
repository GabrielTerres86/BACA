<?
/*
 * FONTE        : principal_titular.php
 * CRIA��O      : Gabriel Ramirez
 * DATA CRIA��O : 11/04/2011 
 * OBJETIVO     : Mostrar opcao Principal da rotina de DDA da tela de CONTAS 
 * 
 * ALTERACOES   :
 */ 
 ?>
 
 <?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	// Carrega permiss�es do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);
		
			
	// Guardo os par�metos do POST em vari�veis		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0  ;
	

	
	// Verifica se o n�mero da conta e o titular s�o inteiros v�lidos
	if (!validaInteiro($nrdconta)) exibeErro('Conta/dv inv&aacute;lida.');
	if (!validaInteiro($idseqttl)) exibeErro('Seq.Ttl n&atilde;o foi informada.');
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0078.p</Bo>';
	$xml .= '		<Proc>consulta-sacado-eletronico</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagecxa>0</cdagecxa>';
	$xml .= '		<nrdcaixa>0</nrdcaixa>';
	$xml .= '		<cdopecxa>'.$glbvars['cdoperad'].'</cdopecxa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
						
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
       exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}	 
	
	$dda = $xmlObjeto->roottag->tags[0]->tags;
			
	include('formulario_dda.php');
	
 ?>
<script >
	//controlaLayoutTabela();
</script>
