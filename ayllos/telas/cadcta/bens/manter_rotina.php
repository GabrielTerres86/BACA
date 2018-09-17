<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os dados dos BENS da tela de CONTAS
 *
 * ALTERACOES   : Reformulacao cadastral (Gabriel-RKAM).
 *								14/07/2016 - Corrigi a forma de recuperacao das variaveis do XML. SD 479874. Carlos R.
 */
 
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		

	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : "";	
		
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";	
	$nrdrowid = (isset($_POST["nrdrowid"])) ? $_POST["nrdrowid"] : "";	
	$idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : "";	
	$dsrelbem = (isset($_POST["dsrelbem"])) ? $_POST["dsrelbem"] : "";
	$persemon = (isset($_POST["persemon"])) ? $_POST["persemon"] : "";
	$qtprebem = (isset($_POST["qtprebem"])) ? $_POST["qtprebem"] : "";
	$vlprebem = (isset($_POST["vlprebem"])) ? $_POST["vlprebem"] : "";
	$vlrdobem = (isset($_POST["vlrdobem"])) ? $_POST["vlrdobem"] : "";	
	$flgcadas = (isset($_POST["flgcadas"])) ? $_POST["flgcadas"] : "";
	
	// Retirando os "." dos valores monetários
	$vlrdobem = str_replace('.','',$vlrdobem);
	$vlprebem = str_replace('.','',$vlprebem);
	
	// Se a operação é de inclusão, limpo o "nrdrowid"
	$nrdrowid = (in_array($operacao,array('IV','VI'))) ? "" : $nrdrowid;
	$idseqbem = (in_array($operacao,array('IV','VI'))) ? "" : $idseqbem;
	
	// Se não for informado qual operação, exibir mensagem de erro
	if ($operacao == "") exibirErro('error','O par&acirc;metro operação n&atilde;o foi informado.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	

	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	if( $operacao == 'IV' ) {$procedure = 'valida-dados';    $cddopcao ='I'; }
	if( $operacao == 'AV' ) {$procedure = 'valida-dados';    $cddopcao ='A'; }
	if( $operacao == 'VI' ) {$procedure = 'inclui-registro'; $cddopcao ='I'; }
	if( $operacao == 'VA' ) {$procedure = 'altera-registro'; $cddopcao ='A'; }
	if( $operacao == 'CE' ) {$procedure = 'exclui-registro'; $cddopcao ='E'; }
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0056.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<nrdrowid>".$nrdrowid."</nrdrowid>";
	$xml .= "		<idseqbem>".$idseqbem."</idseqbem>";
	$xml .= "		<dsrelbem>".$dsrelbem."</dsrelbem>";		
	$xml .= "		<persemon>".$persemon."</persemon>";		
	$xml .= "		<qtprebem>".$qtprebem."</qtprebem>";
	$xml .= "		<vlprebem>".$vlprebem."</vlprebem>";
	$xml .= "		<vlrdobem>".$vlrdobem."</vlrdobem>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	//exibirErro('error','Op.: '.$operacao.' | Procedure: '.$procedure,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	
	$metodo = ( $operacao == 'CE' ) ? 'controlaOperacao();' : 'bloqueiaFundo(divRotina);' ;
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodo,false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ?  $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';	
	$msgAlerta    = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	$msgRvcad   = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'] : '';
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgRvcad!='' ) $msg[] = $msgRvcad;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt    = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad    = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';	
	
	// exibirErro('error','OP- '.$operacao,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	// Se é Validação
	if(in_array($operacao,array('IV','AV'))) {
		
		if($operacao=='AV') exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);
		if($operacao=='IV') exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Ayllos','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);
		
	// Se é Inclusão ou Alteração
	} else {
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad != '' && $flgcadas != 'M') {
					
			if($operacao=='VI') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0056.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\')',false);
			
			if($operacao=='VA') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0056.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\')',false);
			
			if($operacao=='CE') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0056.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FE\")\')',false);
			
		// Se não existe necessidade de Revisão Cadastral
		} else {	
			
			// Chama o controla Operação Finalizando a Inclusão ou Alteração
			if($operacao=='VI') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\');';
		    if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\');';
		    if($operacao=='CE') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FE\")\');';	
		}
	} 
?>