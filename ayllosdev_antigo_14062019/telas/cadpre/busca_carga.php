<? 
/*!
 * FONTE        : busca_carga.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 15/10/2014
 * OBJETIVO     : Rotina para buscar os dados da carga do pre-aprovado
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'G')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADPRE", "CONSULTAR_CARGA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	
	include("form_gerar.php");
?>

<script type="text/javascript">
	formataRegra();	
    $('#dtcalcul','#frmGerar').val('<?= getByTagName($regra->tags,'dtcalcul'); ?>');
    $('#insitcar','#frmGerar').val('<?= getByTagName($regra->tags,'insitcar'); ?>');
    controlaCampos($('#cddopcao', '#frmCab').val());
    $('#frmGerar').css('display','block');
    
</script>