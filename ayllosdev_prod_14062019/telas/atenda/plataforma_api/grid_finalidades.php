<?php
	/*!
	* FONTE        : grid_finalidades.php
	* CRIAÇÃO      : André Clemer
	* DATA CRIAÇÃO : Fevereiro/2019
	* OBJETIVO     : Exibir grid de finalidades para Plataforma API.
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
    require_once("../../../class/xmlfile.php");

    $idservico_api = ((!empty($_POST['idservico_api'])) ? $_POST['idservico_api'] : '');
    $nrdconta  	   = ((!empty($_POST['nrdconta']))  	? $_POST['nrdconta']  	  : '');
    $cddopcao  	   = ((!empty($_POST['cddopcao']))  	? $_POST['cddopcao']  	  : 'C');
    
    $xml = new XmlMensageria();

    $xml->add('idservico_api', $idservico_api);

    $xmlResult = mensageria($xml, "TELA_CADAPI", "CONSULTA_FINALIDADES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    $finalidades = $xmlObj->roottag->tags[0]->tags;

    // 
    // Consulta as finalidades da conta
    // 
    $xml = new XmlMensageria();

    $xml->add('idservico_api', $idservico_api);
    $xml->add('nrdconta', $nrdconta);

    $xmlResult = mensageria($xml, "TELA_ATENDA_API", "CONSULTA_FINALIDADE_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    $registros = $xmlObj->roottag->tags[0]->tags;

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    $finalidades_selecionadas = array();

    foreach($registros as $r) {
        $cdfinalidade  = getByTagName($r->tags,"cdfinalidade");

        $finalidades_selecionadas[] = $cdfinalidade;
    }
?>
<fieldset style="padding:5px">
    <legend><? echo utf8ToHtml('Selecione a(s) finalidade(s) de uso da API pelo cooperado');?></legend>
    <div class="divRegistro" style="width:400px">
        <table class="tituloRegistros">
            <thead>
                <tr>
					<th width="20">&nbsp;</th>
                    <th>Descri&ccedil;&atilde;o</th>
                </tr>
            </thead>
        </table>
    </div>
    <div class="divRegistro" style="width:400px;height:85px;overflow-y:scroll">
        <table class="tituloRegistros" id="tbFinalidades">
            <tbody>
                <?php
                foreach ($finalidades as $f) {
                    $cdfinalidade  = getByTagName($f->tags,"cdfinalidade");
                    $dsfinalidade  = getByTagName($f->tags,"dsfinalidade");
                    $idsituacao    = getByTagName($f->tags,"idsituacao");

                    if (!$idsituacao){ continue; }
                    ?>
                    <tr>
                        <td width="30" style="text-align:center">
                            <input type="hidden" id="cdfinalidade" name="cdfinalidade" value="<?php echo $cdfinalidade; ?>" />
                            <input type="hidden" id="dsfinalidade" name="dsfinalidade" value="<?php echo $dsfinalidade; ?>" />
                            <? if ($cddopcao == 'A' || $cddopcao == 'C' || $cddopcao == 'I') { ?>
                            <input type="checkbox" id="idsituacao" value="<?php echo $cdfinalidade; ?>" <?php echo in_array($cdfinalidade, $finalidades_selecionadas) ? 'checked' : '';?> <?php echo $cddopcao == 'C' ? 'readonly disabled' : '';?> style="margin-left:auto;margin-right:auto;float:none" />
                            <? } else { ?>
                            <input type="checkbox" id="idsituacao" value="<?php echo $cdfinalidade; ?>" <?php echo $idsituacao ? 'checked' : '';?> <?php echo $cddopcao == 'C' ? 'readonly disabled' : '';?> style="margin-left:auto;margin-right:auto;float:none" />
                            <? } ?>
                        </td>
                        <td><?php echo $dsfinalidade; ?></td>
                    </tr>
                    <?php
                }
                ?>
            </tbody>
        </table>
    </div>
</fieldset>
<script>
    hideMsgAguardo();
    $('#divFinalidades').show();
    /*var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '35px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';

    $('#tbFinalidades').formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
	*/
    $('#tbFinalidades').zebraTabela();
</script>