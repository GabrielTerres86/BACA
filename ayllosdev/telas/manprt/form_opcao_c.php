<? 
/*!
 * FONTE        : form_opcao_c.php
 * CRIAÇÃO      : Helinton Steffens - (Supero)
 * DATA CRIAÇÃO : 13/03/2018 
 * OBJETIVO     : Formulario para filtrar as conciliacoes.
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

            <label for="inivlpro"><? echo utf8ToHtml('Valor inicial');  ?>:</label>
			<input type="text" id="inivlpro" name="inivlpro" value="<?php echo $inivlpro ?>"/>

			<label for="fimvlpro"><? echo utf8ToHtml('Valor fim:');  ?></label>
			<input type="text" id="fimvlpro" name="fimvlpro" value="<?php echo $fimvlpro ?>" />

			<br style="clear:both" />            
			<div id="divCooper">
                <label for="nmrescop"><? echo utf8ToHtml('Coop.:') ?></label>
                <select id="nmrescop" name="nmrescop">
                <? if ($glbvars["cdcooper"] == 3 ){ ?> 
                <option value="0"><? echo utf8ToHtml(' Todas') ?></option> <? } ?> 
                
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

            <label for="nrdconta">Conta:</label>
            <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
            <a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;">
            <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a> 

            <label for="dscartor"><? echo utf8ToHtml('Cart&oacuterio de origem');  ?>:</label>
            <input type="text" id="dscartor" name="dscartor" value="dscartor"/>
            <a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisaCartorio();return false;">
            <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		</div>
	</div>		
</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" ><? echo utf8ToHtml('Avan&ccedilar'); ?></a>
</div>





