<?
/*!
 * FONTE        : obtem_consulta_conciliacao.php
 * CRIAÇÃO      : Helinton Steffens (Supero)
 * DATA CRIAÇÃO : 29/03/2018
 * OBJETIVO     : Capturar dados para tela MANPRT
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

	// Recebe o POST
	$inidtpro 			= $_POST['inidtpro'] ;
	$fimdtpro 			= $_POST['fimdtpro'];
	$inivlpro 			= (isset($_POST['inivlpro'])) ? $_POST['inivlpro'] : 0 ;
	$fimvlpro 			= (isset($_POST['fimvlpro'])) ? $_POST['fimvlpro'] : 0 ;
    $nmrescop 			= (isset($_POST['nmrescop'])) ? $_POST['nmrescop'] : 0 ;
    $nrdconta 			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$dscartor 			= (isset($_POST['dscartor'])) ? $_POST['dscartor'] : null ;
	$nriniseq 			= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1  ;
	$nrregist 			= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 50  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
    $xml .= "   <dtinicial>".$inidtpro."</dtinicial>";
	$xml .= "   <dtfinal>".$fimdtpro."</dtfinal>";
	$xml .= "   <vlinicial>".$inivlpro."</vlinicial>";
	$xml .= "   <vlfinal>".$fimvlpro."</vlfinal>";
    $xml .= "   <nmrescop>".$nmrescop."</nmrescop>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cartorio></cartorio>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANPRT", "CONSULTA_CONCILIACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
	 	exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

	$registro 	= $xmlObjeto->roottag->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];

	include('form_opcao_cabecalho.php');
	include('form_opcao_c.php');
	include('form_consulta_conciliacao.php');
		
?>

<script>
	controlaOpcao();
</script>