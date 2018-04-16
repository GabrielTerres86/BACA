<? 
/*!
 * FONTE        : form_opcao_i.php
 * CRIAÇÃO      : Helinton Steffens - (Supero)
 * DATA CRIAÇÃO : 13/03/2018 
 * OBJETIVO     : Formulario para conciliar uma ted.
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	include('form_cabecalho.php');

    // Buscar nome das cooperativas
    $xml = "<Root>";
    $xml .= " <Dados>";
    //Apenas carregar todas se for coop 3 - cecred
    if ($glbvars["cdcooper"] == 3){
        $xml .= "   <cdcooper>0</cdcooper>";
    }else{
        $xml .= '   <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
    }
    $xml .= "   <flgativo>1</flgativo>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;
    
    function exibeErroNew($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
        exit();
    }
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<div id="divFiltro">
		<div>
			<label for="inidtpro"><? echo utf8ToHtml('Data inicial');  ?>:</label>
			<input type="text" id="inidtpro" name="inidtpro" value="<?php echo $inidtpro ?>"/>

			<label for="fimdtpro"><? echo utf8ToHtml('Data fim:');  ?></label>
			<input type="text" id="fimdtpro" name="fimdtpro" value="<?php echo $fimdtpro ?>" />

			<div id="divCooper">
                <label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
                <select id="nmrescop" name="nmrescop">
                                
                <?php
                foreach ($registros as $r) {
                    
                    if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
                ?>
                    <option value="<?= getByTagName($r->tags, 'cdcooper');?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
                    
                    <?php
                    }
                }
                ?>
                </select>
            </div>
			<br style="clear:both" />
            <label for="nrdconta">Conta:</label>
            <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
            <a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;">
            <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a> 

            <label for='cduflogr'> Estado:</label>
            <input id="cduflogr" name="cduflogr" alt="Sigla do estado.">


            <label for="dscartor"><? echo utf8ToHtml('Cart&oacuterio de origem');  ?>:</label>
            <input type="text" id="dscartor" name="dscartor" value="dscartor"/>
            <a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisaCartorio();return false;">
            <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		</div>
	</div>		
</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="exportarConsultaPDF(); return false;" ><? echo utf8ToHtml('Exportar PDF'); ?></a>
    <a href="#" class="botao" onclick="exportarConsultaCSV(); return false;" ><? echo utf8ToHtml('Exportar CSV'); ?></a>
</div>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_custas_csv.php" method="post" id="frmExportarCSV" name="frmExportarCSV">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="cdcooper" id="cdcooper" value="<?php echo $nmrescop; ?>">
	<input type="hidden" name="nrdconta" id="nrdconta" value="<?php echo $nrdconta; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_consulta_custas_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">
	<input type="hidden" name="inidtpro" id="inidtpro" value="<?php echo $inidtpro; ?>">
	<input type="hidden" name="fimdtpro" id="fimdtpro" value="<?php echo $fimdtpro; ?>">
	<input type="hidden" name="cdcooper" id="cdcooper" value="<?php echo $nmrescop; ?>">
	<input type="hidden" name="nrdconta" id="nrdconta" value="<?php echo $nrdconta; ?>">
	<input type="hidden" name="dscartor" id="dscartor" value="<?php echo $dscartor; ?>">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>





