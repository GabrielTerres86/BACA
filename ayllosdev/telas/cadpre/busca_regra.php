<?php
/*!
 * FONTE        : busca_regra.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 04/09/2014
 * OBJETIVO     : Rotina para busca da regra da tela CADPRE
 * --------------
 * ALTERAÇÕES   : 11/07/2016 - Adicionados novos campos para a fase 3 do projeto de Pre aprovado. (Lombardi)
 *
 *                27/04/2018 - Alteração  da situação de "1,2,3,4,5,6,8,9" para "1,2,3,4,5,7,8,9". 
 *                             Projeto 366. (Lombardi)
 *
 *                06/02/2019 - Petter - Envolti. Ajustar novos campos e refatorar funcionalidades para o projeto 442.
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
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADPRE", "BUSCA_CRAPPRE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos',"fechaRotina($('#divRotina')); estadoInicial();",true);
	}

	$regra = $xmlObjeto->roottag->tags[0];
	
    $arrsitua = array('1','2','3','4','5','7','8','9');
    $arrsitbd = explode(";", getByTagName($regra->tags,'dssitdop')); // Transforma em array
    $arrlsali = explode(";", getByTagName($regra->tags,'dslstali')); // Transforma em array
?>

<script type="text/javascript">
    $('#cdfinemp','#frmRegra').val('<? echo getByTagName($regra->tags,'cdfinemp'); ?>');
    $('#dsfinemp','#frmRegra').val('<? echo getByTagName($regra->tags,'dsfinemp'); ?>');

    <?php
        foreach ($arrsitbd as $flgsitua) {
            echo "$('#sit" . $flgsitua . "','#frmRegra').attr('checked', 'checked');";
        }
    ?>

    $('#vllimmin','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vllimmin')); ?>');
    $('#vllimctr','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vllimctr')); ?>');
    $('#vlmulpli','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vlmulpli')); ?>');
    $('#vllimman','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vllimman')); ?>');
    $('#vllimaut','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vllimaut')); ?>');
    $('#qtdiavig','#frmRegra').val('<? echo getByTagName($regra->tags,'qtdiavig'); ?>');

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
    $('#vldiaest','#frmRegra').val('<? echo getByTagName($regra->tags,'vldiaest') > 0 ? formataMoeda(getByTagName($regra->tags,'vldiaest')) : '0,00'; ?>');
    $('#vldiadev','#frmRegra').val('<? echo formataMoeda(getByTagName($regra->tags,'vldiadev')); ?>');
    $('#qtavlatr','#frmRegra').val('<? echo getByTagName($regra->tags,'qtavlatr'); ?>');
    $('#vlavlatr','#frmRegra').val('<? echo getByTagName($regra->tags,'vlavlatr') > 0 ? formataMoeda(getByTagName($regra->tags,'vlavlatr')) : '0,00'; ?>');
    $('#qtavlope','#frmRegra').val('<? echo getByTagName($regra->tags,'qtavlope'); ?>');
    $('#qtcjgatr','#frmRegra').val('<? echo getByTagName($regra->tags,'qtcjgatr'); ?>');
    $('#vlcjgatr','#frmRegra').val('<? echo getByTagName($regra->tags,'vlcjgatr') > 0 ? formataMoeda(getByTagName($regra->tags,'vlcjgatr')) : '0,00'; ?>');
    $('#qtcjgope','#frmRegra').val('<? echo getByTagName($regra->tags,'qtcjgope'); ?>');
    $('#vlctaatr','#frmRegra').val('<? echo getByTagName($regra->tags,'vlctaatr') > 0 ? formataMoeda(getByTagName($regra->tags,'vlctaatr')) : '0,00'; ?>');
    $('#vlepratr','#frmRegra').val('<? echo getByTagName($regra->tags,'vlepratr') > 0 ? formataMoeda(getByTagName($regra->tags,'vlepratr')) : '0,00'; ?>');
    $('#qtcarcre','#frmRegra').val('<? echo getByTagName($regra->tags,'qtcarcre'); ?>');
    $('#vlcarcre','#frmRegra').val('<? echo getByTagName($regra->tags,'vlcarcre') > 0 ? formataMoeda(getByTagName($regra->tags,'vlcarcre')) : '0,00'; ?>');
    $('#qtdtitul','#frmRegra').val('<? echo getByTagName($regra->tags,'qtdtitul'); ?>');
    $('#vltitulo','#frmRegra').val('<? echo getByTagName($regra->tags,'vltitulo') > 0 ? formataMoeda(getByTagName($regra->tags,'vltitulo')) : '0,00'; ?>');

    controlaCampos($('#cddopcao', '#frmCab').val());

</script>