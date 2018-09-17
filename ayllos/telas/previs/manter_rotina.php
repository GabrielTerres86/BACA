<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 28/12/2011 
 * OBJETIVO     : Rotina para manter as operações da tela PREVIS
 * --------------
 * ALTERAÇÕES   : 
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
	$procedure 		= '';
	$retornoAposErro= '';
	
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : '' ;
	$dtmvtolx		= (isset($_POST['dtmvtolx']))   ? $_POST['dtmvtolx']   : '' ; 
	$cdagencx		= (isset($_POST['cdagencx']))   ? $_POST['cdagencx']   : 0  ; 
	$cdcoopex		= (isset($_POST['cdcoopex']))   ? $_POST['cdcoopex']   : 0  ;
	$vldepesp       = (isset($_POST['vldepesp']))   ? $_POST['vldepesp']   : 0  ;
	$vldvlnum       = (isset($_POST['vldvlnum']))   ? $_POST['vldvlnum']   : 0  ;
	$vldvlbcb       = (isset($_POST['vldvlbcb']))   ? $_POST['vldvlbcb']   : 0  ;
	$qtmoeda1		= (isset($_POST['qtmoeda1']))   ? $_POST['qtmoeda1']   : 0  ;
	$qtmoeda2       = (isset($_POST['qtmoeda2']))   ? $_POST['qtmoeda2']   : 0  ;
	$qtmoeda3       = (isset($_POST['qtmoeda3']))   ? $_POST['qtmoeda3']   : 0  ;
	$qtmoeda4		= (isset($_POST['qtmoeda4']))   ? $_POST['qtmoeda4']   : 0  ;
	$qtmoeda5       = (isset($_POST['qtmoeda5']))   ? $_POST['qtmoeda5']   : 0  ;
	$qtmoeda6       = (isset($_POST['qtmoeda6']))   ? $_POST['qtmoeda6']   : 0  ;
	$qtdnota1		= (isset($_POST['qtdnota1']))   ? $_POST['qtdnota1']   : 0  ;
	$qtdnota2       = (isset($_POST['qtdnota2']))   ? $_POST['qtdnota2']   : 0  ;
	$qtdnota3       = (isset($_POST['qtdnota3']))   ? $_POST['qtdnota3']   : 0  ;
	$qtdnota4       = (isset($_POST['qtdnota4']))   ? $_POST['qtdnota4']   : 0  ;
	$qtdnota5       = (isset($_POST['qtdnota5']))   ? $_POST['qtdnota5']   : 0  ;
	$qtdnota6       = (isset($_POST['qtdnota6']))   ? $_POST['qtdnota6']   : 0  ;

	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0131.p</Bo>";
	$xml .= "        <Proc>Grava_Dados</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "		<cdprogra>".$glbvars['cdprogra']."</cdprogra>";	
	$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";	
	$xml .= "		<dtmvtopr>".$glbvars['dtmvtopr']."</dtmvtopr>";	
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";	
	$xml .= "		<dtmvtolx>".$dtmvtolx."</dtmvtolx>";
	$xml .= "		<cdagencx>".$cdagencx."</cdagencx>"; 
	$xml .= "		<cdcoopex>".$cdcoopex."</cdcoopex>"; 
	$xml .= "		<vldepesp>".$vldepesp."</vldepesp>"; 	
	$xml .= "		<vldvlnum>".$vldvlnum."</vldvlnum>"; 	
	$xml .= "		<vldvlbcb>".$vldvlbcb."</vldvlbcb>"; 	
	$xml .= "		<qtmoeda1>".$qtmoeda1."</qtmoeda1>"; 	
	$xml .= "		<qtmoeda2>".$qtmoeda2."</qtmoeda2>"; 	
	$xml .= "		<qtmoeda3>".$qtmoeda3."</qtmoeda3>"; 	
	$xml .= "		<qtmoeda4>".$qtmoeda4."</qtmoeda4>"; 	
	$xml .= "		<qtmoeda5>".$qtmoeda5."</qtmoeda5>"; 	
	$xml .= "		<qtmoeda6>".$qtmoeda6."</qtmoeda6>"; 	
	$xml .= "		<qtdnota1>".$qtdnota1."</qtdnota1>"; 	
	$xml .= "		<qtdnota2>".$qtdnota2."</qtdnota2>"; 	
	$xml .= "		<qtdnota3>".$qtdnota3."</qtdnota3>"; 	
	$xml .= "		<qtdnota4>".$qtdnota4."</qtdnota4>"; 	
	$xml .= "		<qtdnota5>".$qtdnota5."</qtdnota5>"; 	
	$xml .= "		<qtdnota6>".$qtdnota6."</qtdnota6>"; 	

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
	
	echo "estadoInicial();";
	echo "hideMsgAguardo();";
?>