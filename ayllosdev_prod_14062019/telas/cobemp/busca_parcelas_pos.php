<?php
/* !
 * FONTE        : busca_parcelas_pos.php
 * CRIAÇÃO      : Anderson-Alan (Supero)
 * DATA CRIAÇÃO : 15/01/2019
 * OBJETIVO     : Rotina para busca parcelas pos.
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis	
$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
$idseqttl = $_POST['idseqttl'] == '' ? 1 : $_POST['idseqttl'];
$nrparepr = (isset($_POST['nrparepr'])) ? $_POST['nrparepr'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$dtcobemp = (isset($_POST['dtvencto'])) ? $_POST['dtvencto'] : '';

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= "   <Dados>";
$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "       <dtmvtolt>".$dtcobemp."</dtmvtolt>";
$xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "       <nrctremp>".$nrctremp."</nrctremp>";
$xml .= "       <cdlcremp>".$cdlcremp."</cdlcremp>";
$xml .= "       <qttolatr>".$qttolatr."</qttolatr>";
$xml .= "   </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "EMPR0011", "EMPR0011_BUSCA_PARC_POS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObject->roottag->tags[0]->name == 'ERRO')){   
    $msgErro = $xmlObject->roottag->tags[0]->cdata;
    if($msgErro == null || $msgErro == ''){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
        exibirErro('error',$msgErro,'Alerta - Aimaro',"controlaOperacao('')",false);
}

$registros = $xmlObject->roottag->tags[0]->tags;

?>

<div id="divVlPagar "align="right">
    <form id="frmVlPagar" name="frmVlPagar">
        <label for="vlpagmto"><!--Valor a Pagar:-->&nbsp;</label>
        <input type="hidden" id="vlpagmto" name="vlpagmto"/></br>
    </form>
</div>
<div id="divTabela">	
    <div class="divRegistros">	
        <table>
            <thead>
                <tr>			
                    <th> <input type="checkbox" id="'checkTodos" name="checkTodos"> </th>
                    <th><label for="nrparepr" class="txtNormalBold">Nr. Parc.</label></th>
                    <th><label for="dtvencto" class="txtNormalBold">Dt. Venc.</label></th>
                    <th><label for="vlparepr" class="txtNormalBold">Vl. Parc.</label></th>
                    <th><label for="vlpagpar" class="txtNormalBold">Vl. Pago</label></th>
                    <th><label for="vlmtapar" class="txtNormalBold">Multa</label></th>
                    <th><label for="vlmrapar" class="txtNormalBold">Jr. Mora</label></th>
                    <th><label for="vliofcpl" class="txtNormalBold">IOF atraso</label></th>
                    <th><label for="vldespar" class="txtNormalBold">Desc.</label></th>
                    <th><label for="vlatupar" class="txtNormalBold">Vl. Atual</label></th>
                    <th style="width:96px;"><label for="vlpagpar" class="txtNormalBold" >Vl. a Pagar</label></th>
                </tr>
            </thead>
            <tbody>
                <?php
                $parcela = 1;
                $vlatupar = 0.00;
                $total = count($prestacoes);

                foreach ($registros as $registro) {
                    
                    $nrparepr = getByTagName($registro->tags,'nrparepr');
                    $dtvencto = getByTagName($registro->tags,'dtvencto');
                    $vlparepr = getByTagName($registro->tags,'vlparepr');
                    $vlpagpar = getByTagName($registro->tags,'vlpagpar');
                    $vlmtapar = getByTagName($registro->tags,'vlmtapar');
                    $vlmrapar = getByTagName($registro->tags,'vlmrapar');
                    $vliofcpl = getByTagName($registro->tags,'vliofcpl');
                    $vliofcpl = empty($vliofcpl) ? '0' : $vliofcpl;
                    $vldescto = getByTagName($registro->tags,'vldescto');
                    $vlatupar = getByTagName($registro->tags,'vlatupar');
                    $insitpar = getByTagName($registro->tags,'insitpar'); // (1 - Em dia, 2 - Vencida, 3 - A Vencer)

                    $dtmvtolt = implode('', array_reverse(explode('/', $dtcobemp )));
                    $dtvencto = implode('', array_reverse(explode('/', $dtvencto)));

                    if ($insitpar == 2) {
                        //$vlatraso = number_format(str_replace(",", ".", $vlatupar), 2, ",", ".");
						$vlatraso = $vlatupar;
                    } else {
                        $vlatraso = 0.00;
                    }

                    ?>
            
                    <tr>
                        <td><input type="checkbox" id="check_<? echo $nrparepr; ?>" vldescto="<? echo $vldescto; ?>" name="checkParcelas[]" /></td>
                        <td><? echo $nrparepr; ?></td>
                        <td><? echo getByTagName($registro->tags, 'dtvencto'); ?></td>
                        <td><? echo $vlparepr; ?></td>
                        <td><? echo $vlpagpar; ?></td>
                        <td><? echo $vlmtapar; ?></td>
                        <td><? echo $vlmrapar; ?></td>
                        <td><? echo number_format(str_replace(",",".",$vliofcpl),2,",","."); ?></td>
                        <td id="vldespar_<? echo $nrparepr; ?>">0,00</td>
                        <td><? echo $vlatupar; ?></td>
                        <td style="width:70px;"><input type="text" id="vlpagpar_<? echo $nrparepr; ?>" name="vlpagpar[]" size="10" onblur="verificaDescontoPos( $(this) ,<?= $insitpar ?>, <?= $nrparepr; ?>); return false;" value = "<?= number_format(0); ?>" >
                        
                        <td style="width:10px;"><input type="image" id="btDesconto" src="<?php echo $UrlImagens; ?>geral/refresh.png" onClick="descontoPos('<? echo $nrparepr ?>','<? echo $vldescto; ?>'); return false;" /></td>

                        <input type="hidden" id="vlmtapar_<? echo $nrparepr; ?>" name="vlmtapar[]" value="<? echo $vlmtapar; ?>">
                        <input type="hidden" id="vlmrapar_<? echo $nrparepr; ?>" name="vlmrapar[]" value="<? echo $vlmrapar; ?>">
                        <input type="hidden" id="vliofcpl_<? echo $nrparepr; ?>" name="vliofcpl[]" value="<? echo $vliofcpl; ?>">
                        <input type="hidden" id="vlatupar_<? echo $nrparepr; ?>" name="vlatupar[]" value="<? echo $vlatupar; ?>">
                        <input type="hidden" id="cdcooper_<? echo $nrparepr; ?>" name="cdcooper[]" value="<? echo $glbvars["cdcooper"]; ?>">
                        <input type="hidden" id="nrdconta_<? echo $nrparepr; ?>" name="nrdconta[]" value="<? echo $nrdconta; ?>">
                        <input type="hidden" id="nrctremp_<? echo $nrparepr; ?>" name="nrctremp[]" value="<? echo $nrctremp; ?>">
                        <input type="hidden" id="nrparepr_<? echo $nrparepr; ?>" name="nrparepr[]" value="<? echo $nrparepr; ?>">
                        <input type="hidden" id="parcela_<?  echo $parcela ?>" name="parcela[]" value="<? echo $nrparepr; ?>">
                        <input type="hidden" id="dtvencto_<? echo $nrparepr ?>" name="dtvencto[]" value="<? echo $dtvencto; ?>">
                        <input type="hidden" id="vlpagan_<?  echo $nrparepr ?>" name="vlpagan[]" value="0,00">

                        <input type="hidden" id="vlatraso_<? echo $nrparepr; ?>" name="vlatraso[]" value="<? echo $vlatraso; ?>">

                    </td>
                    </tr>
                <?php
                $parcela++;
            }
            ?>
            </tbody>
        </table>
    </div>
</div>
<div id="divVlParc " align="left" >
    <form id="frmVlParc" name="frmVlParc" >
        <label for="totatual">Total Valor Atual:</label><input type="text" id="totatual" name="totatual" value="" />
        <label for="totpagto">Total a Pagar:</label><input type="text" id="totpagto" name="totpagto"/></br>
        <br style="clear:both" />
        <label for="totatras" style="margin-left:25px">Total Atraso:</label><input type="text" id="totatras" name="totatras"/></br>
    </form>
</div>
<div id="divBotoes" style="margin-bottom: 15px; text-align:center;">
    <a href="#" class="botao" id="btVoltar"  	onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
    <a href="#" class="botao" id="btGerar"  	onClick="confirmaGeracaoBoletoPOS(); return false;">Gerar Boleto</a>
</div>
