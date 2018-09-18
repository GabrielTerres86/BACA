<? 
/*!
 * FONTE        : busca_contrato.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2012
 * OBJETIVO     : Rotina para buscar contratos na tela AVALIS
 * --------------
 * ALTERAÇÕES   : 23/07/2015 - Alterado para chamar a nova rotina oracle: pc_busca_dados_contrato_web (Jéssica - DB1)
 * -------------- 
 *
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
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nmprimtl	= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : ''  ;
	$nrcpfcgc	= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
	
	$retornoAposErro = 'estadoInicial();';
			
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro',$retornoAposErro,false);
	}	
	
	$xmlBuscaContrato  = "";
	$xmlBuscaContrato .= "<Root>";
	$xmlBuscaContrato .= " <Dados>";
	$xmlBuscaContrato .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlBuscaContrato .= "	 <nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaContrato .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";	
	$xmlBuscaContrato .= " </Dados>";
	$xmlBuscaContrato .= "</Root>";
				
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaContrato, "AVALIS", "BUSCACTRAVALIS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjBuscaContrato = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBuscaContrato->roottag->tags[0]->name) == 'ERRO') {
		
		$campo    = $xmlObjBuscaContrato->roottag->tags[0]->attributes['NMDCAMPO'];		
		$retornoAposErro = 'estadoInicial();';
		
		if($campo != '' ){ 
			$retornoAposErro .= '$(\'#'.$campo.'\',\'#frmCab\').addClass(\'campoErro\').focus();';
		}
		
		$msgErro  = $xmlObjBuscaContrato->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
		
	}
		
	$registros = $xmlObjBuscaContrato->roottag->tags[0]->tags;
	
	$mensagens = $xmlObjBuscaContrato->roottag->tags[0]->tags;
	$msgconta = "";
	
	foreach( $mensagens as $m ){
		
			
		if (getByTagName($m->tags,'msgconta') != "") {
	
			$msgconta .= getByTagName($m->tags,'msgconta')."|";
			
		}
			
	}
	
	$msgconta = substr($msgconta,0,strlen($msgconta) - 1);

	include ('tab_contrato.php');	
	
	if ((getByTagName($r->tags,'nrdconta') != "") and 
	    (getByTagName($r->tags,'nrctremp') != "") and 
		(getByTagName($r->tags,'cdpesqui') != "") and 
		(getByTagName($r->tags,'nmprimtl') != "") and
		(getByTagName($r->tags,'vldivida') != "")) {
		
		$nmprimtl = $xmlObjBuscaContrato->roottag->tags[1]->tags[0]->cdata;
		$nrdconta = $xmlObjBuscaContrato->roottag->tags[1]->tags[1]->cdata;
		$nrcpfcgc = $xmlObjBuscaContrato->roottag->tags[1]->tags[2]->cdata;
	
	}else {
	
		$nmprimtl = $xmlObjBuscaContrato->roottag->tags[0]->tags[0]->cdata;
		$nrdconta = $xmlObjBuscaContrato->roottag->tags[0]->tags[1]->cdata;
		$nrcpfcgc = $xmlObjBuscaContrato->roottag->tags[0]->tags[2]->cdata;
	
	}
	
?>
<script type="text/javascript">

	var cpfCnpj = normalizaNumero('<? echo $nrcpfcgc; ?>');
			
	if(cpfCnpj.length <= 11){	
		cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));				
	}else{				
		cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));				
	}
	
	msgconta = "<? echo $msgconta; ?>";
		
	cNmprimtl.val("<? echo $nmprimtl; ?>");
    cNrdconta.val("<? echo $nrdconta; ?>");
    	
	cNrdconta.trigger('blur');
	cNrcpfcgc.trigger('blur');
	
	formataTabela();	
	
</script>