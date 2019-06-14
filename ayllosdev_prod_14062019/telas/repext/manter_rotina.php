<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 03/05/2018
 * OBJETIVO     : Rotina para manter as operações da tela REPEXT
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

	$retornoAposErro	= 'bloqueiaFundo( $(\'#divRotina\') );';
		
	// Recebe a operação que está sendo realizada
	$cddopcao			  = (isset($_POST['cddopcao']))             ? $_POST['cddopcao']             : '' ;
	$operacao			  = (isset($_POST['operacao']))             ? $_POST['operacao']             : '' ;
	$idtipo_dominio       = (isset($_POST['idtipo_dominio']))       ? $_POST['idtipo_dominio']       : '' ;
	$inoperacao           = (isset($_POST['inoperacao']))           ? $_POST['inoperacao']           : '' ;
	$cdtipo_dominio       = (isset($_POST['cdtipo_dominio']))       ? $_POST['cdtipo_dominio']       : '' ;
	$insituacao           = (isset($_POST['insituacao']))           ? $_POST['insituacao']           : '' ;
	$dstipo_dominio       = (isset($_POST['dstipo_dominio']))       ? $_POST['dstipo_dominio']       : '' ;
	$inexige_proprietario = (isset($_POST['inexige_proprietario'])) ? $_POST['inexige_proprietario'] : '' ;
	
	$nrcpfcgc            = (isset($_POST['nrcpfcgc']))            ? $_POST['nrcpfcgc']            : '' ;
	$inreportavel        = (isset($_POST['inreportavel']))        ? $_POST['inreportavel']        : '' ;
	$cdtipo_declarado    = (isset($_POST['cdtipo_declarado']))    ? $_POST['cdtipo_declarado']    : '' ;
	$cdtipo_proprietario = (isset($_POST['cdtipo_proprietario'])) ? $_POST['cdtipo_proprietario'] : '' ;
	$dsjustificativa     = (isset($_POST['dsjustificativa']))     ? $_POST['dsjustificativa']     : '' ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	if ($operacao == 'AC') {

		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrcpfcgc>"           .$nrcpfcgc.           "</nrcpfcgc>";
		$xml .= "   <inreportavel>"       .$inreportavel.       "</inreportavel>";
		$xml .= "   <cdtipo_declarado>"   .$cdtipo_declarado.   "</cdtipo_declarado>";
		$xml .= "   <cdtipo_proprietario>".$cdtipo_proprietario."</cdtipo_proprietario>";
		$xml .= "   <dsjustificativa>"    .$dsjustificativa.    "</dsjustificativa>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_REPEXT", "ATUALIZA_COMPLIANCE_PESSOA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
		$xmlObjeto = getObjectXML($xmlResult);

		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		}
		
		echo "fechaRotina($('#divRotina'));";
		echo "$('#divTabela').css('display','none');";
		echo "buscarDadosCompliance(1,30);";

	} else {

		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <idtipo_dominio>"      .$idtipo_dominio.      "</idtipo_dominio>";
		$xml .= "   <inoperacao>"          .$inoperacao.          "</inoperacao>";
		$xml .= "   <cdtipo_dominio>"      .$cdtipo_dominio.      "</cdtipo_dominio>";
		$xml .= "   <insituacao>"          .$insituacao.          "</insituacao>";
		$xml .= "   <dstipo_dominio>"      .$dstipo_dominio.      "</dstipo_dominio>";
		$xml .= "   <inexige_proprietario>".$inexige_proprietario."</inexige_proprietario>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_REPEXT", "ATUALIZA_DOMINIO_TIPO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
		$xmlObjeto = getObjectXML($xmlResult);

		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		}
		
		echo "fechaRotina($('#divRotina'));";
		echo "controlaOperacao();";

	}		

?>