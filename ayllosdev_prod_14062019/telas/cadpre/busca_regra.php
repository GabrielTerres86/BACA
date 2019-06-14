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
	$riscos = $xmlObjeto->roottag->tags[1]->tags;
	
    $arrsitua = array('1','2','3','4','5','7','8','9');
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
            echo "$('#sit" . $flgsitua . "','#frmRegra').attr('checked', 'checked');";
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
	$('#qtdiaver','#frmRegra').val('<? echo getByTagName($regra->tags,'qtdiaver') > 0 ?getByTagName($regra->tags,'qtdiaver') : '';?>');
    $('#vlmaxleg','#frmRegra').val('<? echo getByTagName($regra->tags,'vlmaxleg'); ?>');
	$('#qtmesblq','#frmRegra').val('<? echo getByTagName($regra->tags,'qtmesblq') > 0 ? getByTagName($regra->tags,'qtmesblq') : ''?>');

	<?php 
	foreach( $riscos as $risco ) {
	?>	
		$('#dsrisco_<? echo getByTagName($risco->tags,'dsrisco'); ?>','#frmRegra').text('<? echo getByTagName($risco->tags,'dsrisco'); ?>');
		$('#vllimite_<? echo getByTagName($risco->tags,'dsrisco'); ?>','#frmRegra').val('<? echo getByTagName($risco->tags,'vllimite') > 0 ? formataMoeda(getByTagName($risco->tags,'vllimite')) : ''; ?>');
		$('#cdlcremp_<? echo getByTagName($risco->tags,'dsrisco'); ?>','#frmRegra').val('<? echo getByTagName($risco->tags,'cdlcremp') > 0 ? getByTagName($risco->tags,'cdlcremp') : ''; ?>');
		$('#dslcremp_<? echo getByTagName($risco->tags,'dsrisco'); ?>','#frmRegra').val('<? echo getByTagName($risco->tags,'dslcremp'); ?>');
		$('#txmensal_<? echo getByTagName($risco->tags,'dsrisco'); ?>','#frmRegra').text('<? echo getByTagName($risco->tags,'txmensal') > 0 ? formataMoeda(getByTagName($risco->tags,'txmensal')) : ''; ?>');

	<?}?>

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
    $('#qtavlatr','#frmRegra').val('<? echo getByTagName($regra->tags,'qtavlatr'); ?>');
    $('#vlavlatr','#frmRegra').val('<? echo getByTagName($regra->tags,'vlavlatr') > 0 ? formataMoeda(getByTagName($regra->tags,'vlavlatr')) : '0,00'; ?>');
    $('#qtavlope','#frmRegra').val('<? echo getByTagName($regra->tags,'qtavlope'); ?>');
    $('#qtcjgatr','#frmRegra').val('<? echo getByTagName($regra->tags,'qtcjgatr'); ?>');
    $('#vlcjgatr','#frmRegra').val('<? echo getByTagName($regra->tags,'vlcjgatr') > 0 ? formataMoeda(getByTagName($regra->tags,'vlcjgatr')) : '0,00'; ?>');
    $('#qtcjgope','#frmRegra').val('<? echo getByTagName($regra->tags,'qtcjgope'); ?>');

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
