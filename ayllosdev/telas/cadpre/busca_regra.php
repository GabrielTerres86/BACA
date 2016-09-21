<?php
/*!
 * FONTE        : busca_regra.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 04/09/2014
 * OBJETIVO     : Rotina para busca da regra da tela CADPRE
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
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : ''  ; 	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= "   <flgconsu>1</flgconsu>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADPRE", "CADPRE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos',"fechaRotina($('#divRotina')); estadoInicial();",true);
	}

	$regra = $xmlObjeto->roottag->tags[0];

    $arrsitua = array('1','2','3','4','5','6','8','9');
    $arrsitbd = explode(";", getByTagName($regra->tags,'dssitdop')); // Transforma em array
    $arrlsali = explode(";", getByTagName($regra->tags,'dslstali')); // Transforma em array
?>

<script type="text/javascript">
		
    $('#cdfinemp','#frmRegra').val('<? echo getByTagName($regra->tags,'cdfinemp'); ?>');
    $('#dsfinemp','#frmRegra').val('<? echo getByTagName($regra->tags,'dsfinemp'); ?>');
    $('#cdlcremp','#frmRegra').val('<? echo getByTagName($regra->tags,'cdlcremp'); ?>');
    $('#dslcremp','#frmRegra').val('<? echo getByTagName($regra->tags,'dslcremp'); ?>');
    $('#nrmcotas','#frmRegra').val('<? echo getByTagName($regra->tags,'nrmcotas'); ?>');

    <?php
        foreach ($arrsitbd as $flgsitua) {
            $codsitua = array_search($flgsitua, $arrsitua); // Verifica o indice do array atravez do valor passado
            echo "$('#sit" . $codsitua . "','#frmRegra').attr('checked', 'checked');";
        }
    ?>

    $("#qtmescta","#frmRegra").val('<? echo getByTagName($regra->tags,'qtmescta'); ?>');
    $("#qtmesadm","#frmRegra").val('<? echo getByTagName($regra->tags,'qtmesadm'); ?>');
    $("#qtmesemp","#frmRegra").val('<? echo getByTagName($regra->tags,'qtmesemp'); ?>');
    $('#nrrevcad','#frmRegra').val('<? echo getByTagName($regra->tags,'nrrevcad'); ?>');
    $('#vllimmin','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vllimmin')); ?>');
    $('#vllimctr','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vllimctr')); ?>');
    $('#vlmulpli','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vlmulpli')); ?>');
    $('#vlpercom','#frmRegra').val('<? echo getByTagName($regra->tags,'vlpercom'); ?>');
    $('#vlmaxleg','#frmRegra').val('<? echo getByTagName($regra->tags,'vlmaxleg'); ?>');

    $('#vllimcra','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcra') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcra')) : ''; ?>');
    $('#vllimcrb','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcrb') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcrb')) : ''; ?>');
    $('#vllimcrc','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcrc') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcrc')) : ''; ?>');
    $('#vllimcrd','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcrd') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcrd')) : ''; ?>');
    $('#vllimcre','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcre') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcre')) : ''; ?>');
    $('#vllimcrf','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcrf') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcrf')) : ''; ?>');
    $('#vllimcrg','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcrg') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcrg')) : ''; ?>');
    $('#vllimcrh','#frmRegra').val('<? echo getByTagName($regra->tags,'vllimcrh') > 0 ? formataMoeda(getByTagName($regra->tags,'vllimcrh')) : ''; ?>');

    <?php
        foreach ($arrlsali as $cdalinea) {
            echo "$('#ali" . $cdalinea . "','#frmRegra').attr('checked', 'checked');";
        }
    ?>

    $('#qtdevolu','#frmRegra').val('<? echo getByTagName($regra->tags,'qtdevolu'); ?>');
    $('#qtdiadev','#frmRegra').val('<? echo getByTagName($regra->tags,'qtdiadev'); ?>');

    $('#qtctaatr','#frmRegra').val('<? echo getByTagName($regra->tags,'qtctaatr'); ?>');
    $('#qtepratr','#frmRegra').val('<? echo getByTagName($regra->tags,'qtepratr'); ?>');
    $('#qtestour','#frmRegra').val('<? echo getByTagName($regra->tags,'qtestour'); ?>');
    $('#qtdiaest','#frmRegra').val('<? echo getByTagName($regra->tags,'qtdiaest'); ?>');

    $("#divLimiteCoop").css({"color":"#000"}).html("<? echo  utf8ToHtml('Valor Máximo Legal: R$ ') . formataMoeda(getByTagName($regra->tags,'vlmaximo')); ?>");

    <?php
        // Se o Total de Credito for maior que Valor Maximo Legal coloca a fonte vermelha e mostra uma sugestao
        if (getByTagName($regra->tags,'vlsomado') > getByTagName($regra->tags,'vlmaximo')) {
            $nrsugcot = (int) ((getByTagName($regra->tags,'vlmaximo') * getByTagName($regra->tags,'nrmcotas')) / getByTagName($regra->tags,'vlsomado'));
            echo '$("#divLimiteCoop").css({"color":"red"}).append("<br />' . utf8ToHtml('Sugestão de Multiplicação de Cotas: ') . $nrsugcot . ' vezes");';
        }
    ?>

    controlaCampos($('#cddopcao', '#frmCab').val());
    
</script>