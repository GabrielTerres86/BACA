<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : Marco/2016
 * OBJETIVO     : Mostrar opcao Principal da rotina de Reciprocidade
 * --------------
 * ALTERAÇÕES   :				 
 * --------------
 */	
    session_start();
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');
    require_once("../../class/xmlfile.php");
    isPostMethod();

    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
    $nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : '';
    $nmrotina = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : '';

    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml, "TELA_RECIPR", "REC_BUSCA_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $xmlDados  = $xmlObjeto->roottag->tags[0];
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));',false);
    }
    $nmprimtl = getByTagName($xmlDados->tags,"NMPRIMTL");

    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrconven>".$nrconven."</nrconven>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml, "TELA_RECIPR", "REC_BUSCA_APURACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $xmlApurac = $xmlObjeto->roottag->tags[0]->tags;
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));',false);
    }
?>
<table width="100%" border="0" cellspacing="3" cellpadding="0">
   <tr>
        <td width="105" align="right" class="txtNormalBold">Conta:&nbsp;</td>
        <td><?php echo formataContaDVsimples($nrdconta); ?></td>
        <td><?php echo $nmprimtl; ?></td>	
   </tr>
</table>

<fieldset style="border:1px solid #949EAD; padding:5px;">
    <legend align="left" style="margin-left:15px; font-size:10px; color:#6B7984; padding:5px;">Per&iacute;odos de apura&ccedil;&atilde;o de Reciprocidade</legend>
    
    <div id="divReciprocidadePrincipal">
        <div class="divRegistros">
            <table>
                <thead>
                    <tr>
                        <th>Produto</th>
                        <th>Contrato / Conv&ecirc;nio</th>
                        <th>Prazo(M)</th>
                        <th>In&iacute;cio</th>
                        <th>Fim</th>
                        <th>Decorrido</th>
                        <th>Situa&ccedil;&atilde;o</th>
                        <th>Reciprocidade Cumprida?</th>
                        <th>Tarifa Revertida?</th>
                        <th>Tarifa Aplicada?</th>
                    </tr>			
                </thead>
                <tbody>
                    <?php
                        foreach ($xmlApurac as $apu) {
                            $perc_decorrido = (getByTagName($apu->tags,'QTDIAS_DECORRIDO') * 100) / getByTagName($apu->tags,'QTDIAS_PREVISTO');
                            ?>
                            <tr>
                                <td width="70">
                                    <input type="hidden" id="hd_nrdconta" value="<?php echo $nrdconta; ?>" />
                                    <input type="hidden" id="hd_idapuracao_reciproci" value="<?php echo getByTagName($apu->tags,'idapuracao_reciproci'); ?>" />
                                    <?php echo getByTagName($apu->tags,'DSPRODUTO'); ?>
                                </td>
                                <td width="70"><?php echo formataNumericos("zzz.zzz.zzz",getByTagName($apu->tags,'NRCONTR_CONVEN'),"."); ?></td>
                                <td width="40"><?php echo getByTagName($apu->tags,'QTDMES_RETORNO_RECIPROCI'); ?></td>
                                <td width="50"><?php echo getByTagName($apu->tags,'DTINICIO_APURACAO'); ?></td>
                                <td width="50"><?php echo getByTagName($apu->tags,'DTTERMINO_APURACAO'); ?></td>
                                <td width="70"><?php echo getByTagName($apu->tags,'QTDIAS_DECORRIDO').' ('.formataMoeda($perc_decorrido).'%)'; ?></td>
                                <td width="70"><?php echo getByTagName($apu->tags,'DSSITUACAO'); ?></td>
                                <td width="90"><?php echo getByTagName($apu->tags,'DESRECIPRO_ATINGIDA').(getByTagName($apu->tags,'DESRECIPRO_ATINGIDA') != '-' ? '%' : ''); ?></td>
                                <td><?php echo getByTagName($apu->tags,'DESTARIFA_REVERTIDA'); ?></td>
                                <td><?php echo getByTagName($apu->tags,'DESTARIFA_DEBITADA'); ?></td>
                            </tr>
                            <?php
                        }
                    ?>
                </tbody>
            </table>
        </div>
    </div>

    <div id="divReciprIndicadores"></div>
    <div id="divReciprTarifas"></div>

</fieldset>
<br />
<a class="botao" onclick="fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;" href="#">Voltar</a>
<script >
    controlaLayoutTabelaReciprocidade();
</script>