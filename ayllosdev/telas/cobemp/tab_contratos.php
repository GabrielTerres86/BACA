<?php 
/*
 * FONTE        : tab_contratos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 14/08/2015
 * OBJETIVO     : Tabela que apresenta a consulta de contratos
 * --------------
 * ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *
 *                01/03/2017 - Inclusao de indicador se possui avalista e coluna de Saldo Prejuizo. (P210.2 - Jaison/Daniel)
 *                   04/2019 - Inclusão do campo tpdescto P437 Consignado JDB AMcom
 * --------------
 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nmdominio>TPEMPRST</nmdominio>";
$xml .= " </Dados>";
$xml .= "</Root>";
$xmlResult = mensageria($xml, "EMPR9999", "BUSCA_DOMINIO_EPR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDomini = $xmlObject->roottag->tags[0]->tags;
?>

<div id="divContratos" name="divContratos" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th>Lin</th>
                    <th>Fin</th>
                    <th>Contrato</th>
                    <th>Produto</th>
					<th>Cob</th>
                    <th>Data</th>
                    <th>Emprestado</th>
                    <th>Parcelas</th>
                    <th>Valor</th>
                    <th>Vl. IOF Atraso</th>
                    <th>Valor <br/> Atraso</th>
                    <th>Saldo</th>
                    <th>Saldo Preju&iacute;zo</th>
                </tr>
            </thead>

            <?php
            $conta = 0;
            foreach ($registros as $r) {
                $conta++;
				$tipo = '';
				foreach ($xmlDomini as $reg) {
                    if (getByTagName($reg->tags,'CDDOMINIO') == getByTagName($r->tags,'tpemprst')) {
                        $tipo = getByTagName($reg->tags,'DSCODIGO');
                    }
                }
				$valor = getByTagName($r->tags, 'vlemprst');
                if ($valor > 0) {
                    ?>
                    <tr>
                        <td><?php echo getByTagName($r->tags, 'cdlcremp') ?>
                            <input type="hidden" id="nrctremp" name="nrctremp" value="<?php echo getByTagName($r->tags,'nrctremp') ?>" />
                            <input type="hidden" id="inprejuz" name="inprejuz" value="<?php echo getByTagName($r->tags,'inprejuz') ?>" />
                            <input type="hidden" id="tplcremp" name="tplcremp" value="<?php echo getByTagName($r->tags,'tplcremp') ?>" />
                            <input type="hidden" id="nrdrecid" name="nrdrecid" value="<?php echo getByTagName($r->tags,'nrdrecid') ?>" />
                            <input type="hidden" id="qtpromis" name="qtpromis" value="<?php echo getByTagName($r->tags,'qtpromis') ?>" />
                            <input type="hidden" id="flgimppr" name="flgimppr" value="<?php echo getByTagName($r->tags,'flgimppr') ?>" />
                            <input type="hidden" id="flgimpnp" name="flgimpnp" value="<?php echo getByTagName($r->tags,'flgimpnp') ?>" />
                            <input type="hidden" id="tpemprst" name="tpemprst" value="<?php echo getByTagName($r->tags,'tpemprst') ?>" />
                            <input type="hidden" id="dsdavali" name="dsdavali" value="<?php echo getByTagName($r->tags,'dsdavali') ?>" />
                            <input type="hidden" id="cdorigem" name="cdorigem" value="<?php echo getByTagName($r->tags,'cdorigem') ?>" />
                            <input type="hidden" id="liquidia" name="liquidia" value="<?php echo getByTagName($r->tags,'liquidia') ?>" />
                            <input type="hidden" id="vlemprst" name="vlemprst" value="<?php echo number_format(str_replace(",",".",getByTagName($r->tags,'vlemprst')),2,",",".");?>" />
							<input type="hidden" id="nrcnvcob" name="nrcnvcob" value="<?php echo getByTagName($r->tags,'nrcnvcob') ?>" />
							<input type="hidden" id="nrctacob" name="nrctacob" value="<?php echo getByTagName($r->tags,'nrctacob') ?>" />
                            <input type="hidden" id="avalista" name="avalista" value="<?php echo getByTagName($r->tags,'avalista') ?>" />
                            <input type="hidden" id="tpdescto" name="tpdescto" value="<?php echo getByTagName($r->tags,'tpdescto') ?>" />
                            <input type="hidden" id="vlsdprej" name="vlsdprej" value="<?php echo number_format(str_replace(",",".",getByTagName($r->tags,'vlsdprej')),2,",",".");?>" />
                            <input type="hidden" id="vliofcpl" name="vliofcpl" value="<?php echo number_format(str_replace(",",".",getByTagName($r->tags,'vliofcpl')),2,",",".");?>" />
                        </td>
                        <td><?php echo getByTagName($r->tags, 'cdfinemp') ?></td>
                        <td><?php echo formataNumericos("z.zzz.zzz.zzz", getByTagName($r->tags, 'nrctremp'), "."); ?>
                            <input type="hidden" id="nrctremp" name="nrctremp" value="<? echo getByTagName($r->tags,'nrctremp') ; ?>" />
                        </td>
                        <td><?php echo stringTabela($tipo, 40, 'maiuscula'); ?></td> 
						<td><?php echo getByTagName($r->tags, 'dstipcob') ?></td>
                        <td><?php echo getByTagName($r->tags, 'dtmvtolt') ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vlemprst')), 2, ",", "."); ?></td>
                        <td><?php echo getByTagName($r->tags, 'qtpreemp') ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vlpreemp')), 2, ",", "."); ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vliofcpl')), 2, ",", "."); ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vltotpag')), 2, ",", "."); ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vlsdeved')), 2, ",", "."); ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vlsdprej')), 2, ",", "."); ?></td>
                    </tr>
                    <?php
                }
            }
            ?>

            </tbody>
        </table>
        <input type="hidden" id="qtdreg" name="qtdreg" value="<?php echo $conta; ?>" />
    </div>
</div>


<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>	
        <tr>
            <td>
                <?php

                if (isset($qtregist) and $qtregist == 0) {
                    $nriniseq = 0;
                }

                // Se a paginacao nao esta na primeira, exibe botao voltar
                if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnterior'><<< Anterior</a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>
            </td>
            <td>
                <?php
                if (isset($nriniseq)) {
                    ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                    if (($nriniseq + $nrregist) > $qtregist) {
                        echo $qtregist;
                    } else {
                        echo ($nriniseq + $nrregist - 1);
                    }
                    ?> de <?php echo $qtregist; ?><?php
                }
                ?>
            </td>
            <td>
                <?php
                // Se a paginacao nao esta na ultima pagina, exibe botao proximo
                if ($qtregist > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>			
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">

    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        buscaContratos(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaContratos(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>
