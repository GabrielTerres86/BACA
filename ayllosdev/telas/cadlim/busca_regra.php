<? 
/*!
 * FONTE        : busca_regra.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 23/12/2014
 * OBJETIVO     : Rotina para busca da regra da tela CADPRE
 * --------------
 * ALTERAÇÕES   : 21/09/2016 - Inclusão do filtro "Tipo de Limite" no cabecalho. Inclusão dos campos
 *                             "pcliqdez" e "qtdialiq" no formulario de regras. Projeto 300. (Lombardi)
 *
 *				  16/03/2018 - Inclusão de novo campo (Quantidade de Meses do novo limite após o cancelamento)
 *							   Diego Simas (AMcom) 		
 *
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''; 
	$tplimite = (isset($_POST['tplimite'])) ? $_POST['tplimite'] : ''; 	
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : ''; 	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";	
	$xml .= "   <flgdepop>".(($cddopcao == 'C') ? 0 : 1)."</flgdepop>";
	$xml .= "   <idgerlog>0</idgerlog>";
    $xml .= "   <tplimite>".$tplimite."</tplimite>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADLIM", "CADLIM_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
	}
	$regra = $xmlObjeto->roottag->tags[0];
	
	include("form_regras.php");
?>

<script type="text/javascript">		
    formataRegra();	
    $('#vlmaxren','#frmRegra').val('<?= (getByTagName($regra->tags,'vlmaxren') > 0 ? formataMoeda(getByTagName($regra->tags,'vlmaxren')) : 0); ?>');
    $('#nrrevcad','#frmRegra').val('<?= getByTagName($regra->tags,'nrrevcad'); ?>');
    $('#qtmincta','#frmRegra').val('<?= getByTagName($regra->tags,'qtmincta'); ?>');
    $('#qtdiaren','#frmRegra').val('<?= getByTagName($regra->tags,'qtdiaren'); ?>');
	//Diego Simas (AMcom)
	$('#qtmeslic','#frmRegra').val('<?= getByTagName($regra->tags,'qtmeslic'); ?>');
    $('#qtmaxren','#frmRegra').val('<?= getByTagName($regra->tags,'qtmaxren'); ?>');
    $('#qtdiaatr','#frmRegra').val('<?= getByTagName($regra->tags,'qtdiaatr'); ?>');
    $('#qtatracc','#frmRegra').val('<?= getByTagName($regra->tags,'qtatracc'); ?>');
    $('#pcliqdez','#frmRegra').val('<?= getByTagName($regra->tags,'pcliqdez'); ?>');
    $('#qtdialiq','#frmRegra').val('<?= getByTagName($regra->tags,'qtdialiq'); ?>');
	
	<?
	$aSituacao = explode(";", getByTagName($regra->tags,'dssitdop'));
	foreach ($aSituacao as $value){
		echo "$('#sit".$value."','#frmRegra').attr('checked', 'checked');";		
	}
	
	$aRisco = explode(";", getByTagName($regra->tags,'dsrisdop'));
	foreach ($aRisco as $value){
		echo "$('#ris".$value."','#frmRegra').attr('checked', 'checked');";		
	}
	?>
	
    controlaCampos($('#cddopcao', '#frmCab').val(), $('#tplimite', '#frmCab').val());
    $('#frmRegra').css('display','block');    
</script>
