<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 26/12/2011 
 * OBJETIVO     : Rotina para manter as operações da tela VALPRO
 * --------------
 * ALTERAÇÕES   : 06/10/2015 - Incluindo validacao de protocolo MD5 - Sicredi
                               (Andre Santos - SUPERO)
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Inicializa
	$aux 			= array();
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ; 
	$nrdocmto		= (isset($_POST['nrdocmto']))   ? $_POST['nrdocmto']   : 0  ; 
	$nrseqaut		= (isset($_POST['nrseqaut']))   ? $_POST['nrseqaut']   : 0  ; 
	$dtmvtolx		= validaData($_POST['dtmvtolx'])   ? $_POST['dtmvtolx']   : '' ; 
	$horproto		= (isset($_POST['horproto']))   ? $_POST['horproto']   : 0  ; 
	$minproto		= (isset($_POST['minproto']))   ? $_POST['minproto']   : 0  ; 
	$segproto		= (isset($_POST['segproto']))   ? $_POST['segproto']   : 0  ; 
	$vlprotoc		= (isset($_POST['vlprotoc']))   ? $_POST['vlprotoc']   : 0  ; 
	$dsprotoc		= (isset($_POST['dsprotoc']))   ? $_POST['dsprotoc']   : '' ;
	$flvalgps		= (isset($_POST['flvalgps']))   ? $_POST['flvalgps']   : 0 ;
	
	
	if($flvalgps==0){ // Valida protocolo
		$procedure = 'Valida_Protocolo';
	}else{ // Valida protocolo atraves do Sicredi
		$procedure = 'pc_valida_protocolo';
	}
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0127.p</Bo>";
	$xml .= "        <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "		<cdprogra>".$glbvars['cdprogra']."</cdprogra>";	
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";	
	$xml .= "		<dtmvtopr>".$glbvars['dtmvtopr']."</dtmvtopr>";	
	$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";	
	$xml .= "		<cddopcao>C</cddopcao>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= "		<dtmvtolx>".$dtmvtolx."</dtmvtolx>";
	$xml .= "		<horproto>".$horproto."</horproto>";
	$xml .= "		<minproto>".$minproto."</minproto>";
	$xml .= "		<segproto>".$segproto."</segproto>";
	$xml .= "		<vlprotoc>".$vlprotoc."</vlprotoc>";
	$xml .= "		<dsprotoc>".$dsprotoc."</dsprotoc>";
	$xml .= "		<nrseqaut>".$nrseqaut."</nrseqaut>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " focaCampoErro('".$nmdcampo."','frmCab');"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$msgretur	= $xmlObjeto->roottag->tags[0]->attributes['MSGRETUR'];
	$msgerror	= $xmlObjeto->roottag->tags[0]->attributes['MSGERROR'];
	
	if ( !empty($msgerror) ) {	
		exibirErro('error',$msgerror,'Alerta - Ayllos','estadoInicial();',false);
		
	} else if (!empty($msgretur)) {
		exibirErro('inform',$msgretur,'Alerta - Ayllos','estadoInicial();',false);
	
	} else {
		echo "estadoInicial();";
	}
?>