<?php
/*!
 * FONTE        : detalhes.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : Marco/2016
 * OBJETIVO     : Mostrar rotina com os detalhes da Reciprocidade.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();

    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
    $idapuracao_reciproci = (isset($_POST['idapuracao_reciproci'])) ? $_POST['idapuracao_reciproci'] : '';
    $tipo_tabela = (isset($_POST['tipo_tabela'])) ? $_POST['tipo_tabela'] : '';

    if ($tipo_tabela == 'andamento_indicadores') {
        $nmdeacao = 'REC_BUSCA_INDICADOR';
        $nmlegend = 'Andamento dos Indicadores';
    } else {
        $nmdeacao = 'REC_BUSCA_TARIFA';
        $nmlegend = 'Acompanhamento das Tarifas';
    }

    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <idapuracao_reciproci>".$idapuracao_reciproci."</idapuracao_reciproci>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_RECIPR", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $xmlDetail = $xmlObjeto->roottag->tags[0]->tags;

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));',false);
    }
?>
<fieldset style="border:1px solid #949EAD; padding:5px;">
    <legend align="left" style="margin-left:15px; font-size:10px; color:#6B7984; padding:5px;"><?php echo $nmlegend; ?></legend>
    <div class="divRegistros">
        <table>
            <thead>
                <?php
                    if ($tipo_tabela == 'andamento_indicadores') {
                        ?>
                        <tr>
                            <th>Indicador</th>
                            <th>Contratado</th>
                            <th>Realizado</th>
                            <th>%</th>
                            <th>%Toler&acirc;ncia</th>
                            <th>Atingido?</th>
                        </tr>
                        <?php
                    } else {
                        ?>
                        <tr>
                            <th>Tarifa</th>
                            <th>Ocorr&ecirc;ncias</th>
                            <th>Valor Original</th>
                            <th>%Desconto</th>
                            <th>Desconto Acumulado</th>
                        </tr>
                        <?php
                    }
                ?>
            </thead>
            <tbody>
                <?php
                    $tot_qtdocorre = 0;
                    $tot_perdesconto = 0;
                    $tot_vltarifa_original = 0;
                    $tot_vldesconto_acumulado = 0;

                    foreach ($xmlDetail as $det) {

                        if ($tipo_tabela == 'andamento_indicadores') {
                            // Se for Q-Quantidade ou M-Moeda
                            if (getByTagName($det->tags,'TPINDICADOR') == 'Q' || getByTagName($det->tags,'TPINDICADOR') == 'M') {
                                $percentual = formataMoeda((converteFloat(getByTagName($det->tags,'VLRREALIZADO')) * 100) / converteFloat(getByTagName($det->tags,'VLCONTRATA')));
                            } else { // Se for A-Adesao
                                $percentual = (getByTagName($det->tags,'VLRREALIZADO') == 1 ? '100' : '0');
                            }
                            ?>
                            <tr>
                                <td width="300"><?php echo getByTagName($det->tags,'NMINDICADOR'); ?></td>
                                <td width="75"><?php echo getByTagName($det->tags,'VLCONTRATA'); ?></td>
                                <td width="75"><?php echo getByTagName($det->tags,'VLRREALIZADO'); ?></td>
                                <td width="70"><?php echo $percentual; ?>%</td>
                                <td width="80"><?php echo formataMoeda(getByTagName($det->tags,'PERTOLERA')); ?></td>
                                <td><?php echo getByTagName($det->tags,'DESATINGIDO'); ?></td>
                            </tr>
                            <?php
                        } else {
                            $tot_qtdocorre = $tot_qtdocorre + getByTagName($det->tags,'QTDOCORRE');
                            $tot_perdesconto = $tot_perdesconto + getByTagName($det->tags,'PERDESCONTO');
                            $tot_vltarifa_original = $tot_vltarifa_original + getByTagName($det->tags,'VLTARIFA_ORIGINAL');
                            $tot_vldesconto_acumulado = $tot_vldesconto_acumulado + getByTagName($det->tags,'VLDESCONTO_ACUMULADO');
                            ?>
                            <tr>
                                <td width="300"><?php echo getByTagName($det->tags,'DSTARIFA'); ?></td>
                                <td width="80"><?php echo getByTagName($det->tags,'QTDOCORRE'); ?></td>
                                <td width="90"><?php echo formataMoeda(getByTagName($det->tags,'VLTARIFA_ORIGINAL')); ?></td>
                                <td width="80"><?php echo formataMoeda(getByTagName($det->tags,'PERDESCONTO')); ?></td>
                                <td><?php echo formataMoeda(getByTagName($det->tags,'VLDESCONTO_ACUMULADO')); ?></td>
                            </tr>
                            <?php
                        }
                    }

                    if ($tipo_tabela == 'acompanhamento_tarifas') {
                        ?>
                        <tr>
                            <td><div style="text-align: right; font-size: 11px; font-weight: bold;">Total</div></td>
                            <td><?php echo $tot_qtdocorre; ?></td>
                            <td><?php echo formataMoeda($tot_vltarifa_original); ?></td>
                            <td><?php echo formataMoeda($tot_perdesconto / COUNT($xmlDetail)); ?></td>
                            <td><?php echo formataMoeda($tot_vldesconto_acumulado); ?></td>
                        </tr>
                        <?php
                    }
                ?>
            </tbody>
        </table>
    </div>
</fieldset>