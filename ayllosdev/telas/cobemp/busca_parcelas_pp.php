<?php
/* !
 * FONTE        : busca_parcelas_pp.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 03/09/2015
 * OBJETIVO     : Rotina para busca parcelas pp.
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

$procedure = 'busca_pagamentos_parcelas_cobemp';

$xml = "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0084a.p</Bo>";
$xml .= "		<Proc>" . $procedure . "</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "               <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xml .= "		<cdagenci>" . $glbvars["cdagenci"] . "</cdagenci>";
$xml .= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
$xml .= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xml .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
$xml .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
$xml .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "		<idseqttl>" . $idseqttl . "</idseqttl>";
$xml .= "		<nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "		<nrparepr>" . $nrparepr . "</nrparepr>";
$xml .= "		<vlpagpar>" . $vlpagpar . "</vlpagpar>";
$xml .= "		<dtcobemp>" . $dtcobemp . "</dtcobemp>";
$xml .= "		<flgerlog>TRUE</flgerlog>";
$xml .= "	</Dados>";
$xml .= "</Root>";

$xmlResult = getDataXML($xml);

$xmlObjeto = getObjectXML($xmlResult);

if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    exibirErro('error', $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Ayllos', "controlaOperacao('')", false);
}

$prestacoes = $xmlObjeto->roottag->tags[0]->tags;
$calculado = $xmlObjeto->roottag->tags[1]->tags;
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
                    <th><label for="vljinpar" class="txtNormalBold">Jr. Norm.</label></th>
                    <th><label for="vlmrapar" class="txtNormalBold">Jr. Mora</label></th>
                    <th><label for="vldespar" class="txtNormalBold">Desc.</label></th>
                    <th><label for="vliofcpl" class="txtNormalBold">Vl. IOF Atr</label></th>
                    <th><label for="vlatupar" class="txtNormalBold">Vl. Atual</label></th>
                    <th style="width:96px;"><label for="vlpagpar" class="txtNormalBold" >Vl. a Pagar</label></th>


                </tr>
            </thead>
            <tbody>
                <?php
                $parcela = 1;
                $vlatupar = 0.00;
                $total = count($prestacoes);

                foreach ($prestacoes as $registro) {

                    $vlparepr = number_format(str_replace(",", ".", getByTagName($registro->tags, 'vlparepr')), 2, ",", ".");
                    $vlatupar = number_format(str_replace(",", ".", getByTagName($registro->tags, 'vlatupar')), 2, ",", ".");
                    $nrparepr = getByTagName($registro->tags, 'nrparepr');
                    $flgantec = getByTagName($registro->tags, 'flgantec');
					
					$dtmvtolt = implode('', array_reverse(explode('/', $dtcobemp )));
					$dtvencto  = implode('', array_reverse(explode('/', getByTagName($registro->tags, 'dtvencto'))));

					if ($dtvencto < $dtmvtolt) {
               //     if (number_format(str_replace(",", ".", getByTagName($registro->tags, 'vlmtapar')), 2, ",", ".") > 0) {
                        $vlatraso = number_format(str_replace(",", ".", getByTagName($registro->tags, 'vlatupar')), 2, ",", ".");
                    } else {
                        $vlatraso = 0.00;
                    }
                    ?>
            
                <tr>		
                        <td>  						
                            <input type="checkbox" id="check_<?php echo $nrparepr; ?>" name="checkParcelas[]"  > 
                        </td>						
                        <td><?php echo $nrparepr; ?></td>
                        <td><?php echo getByTagName($registro->tags, 'dtvencto'); ?></td>
                        <td><?php echo $vlparepr; ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($registro->tags, 'vlpagpar')), 2, ",", "."); ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($registro->tags, 'vlmtapar')), 2, ",", "."); ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($registro->tags, 'vljinpar')), 2, ",", "."); ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($registro->tags, 'vlmrapar')), 2, ",", "."); ?></td>
                        <td id="vldespar_<?php echo $nrparepr; ?>" ><?php echo "0,00"; /* number_format(str_replace(",",".",getByTagName($registro->tags,'vldespar')),2,",","."); */ ?></td>
                        <td><?php echo number_format(str_replace(",", ".", getByTagName($registro->tags, 'vliofcpl')), 2, ",", "."); ?></td>
                        <td><?php echo $vlatupar; ?></td>			
                        <td style="width:70px;"><input type="text" id="vlpagpar_<?php echo $nrparepr; ?>" name="vlpagpar[]" size="10" onblur="verificaDesconto( $(this) , '<?php echo $flgantec; ?>' , <?php echo $nrparepr; ?>); return false;" value = "<?php echo number_format(0); ?>" >
									
						<?php /*if ($flgantec == 'yes')*/ { ?>						
							<td style="width:10px;"><input type="image" id="btDesconto" src="<?php echo $UrlImagens; ?>geral/refresh.png" onClick="desconto(<?php echo $nrparepr ?> ); return false;" /> </td>
						<?php } ?>

                <input type="hidden" id="vlmtapar_<?php echo $nrparepr; ?>" name="vlmtapar[]" value="<?php echo getByTagName($registro->tags, 'vlmtapar'); ?>">
                <input type="hidden" id="vlmrapar_<?php echo $nrparepr; ?>" name="vlmrapar[]" value="<?php echo getByTagName($registro->tags, 'vlmrapar'); ?>">
                <input type="hidden" id="vlatupar_<?php echo $nrparepr; ?>" name="vlatupar[]" value="<?php echo $vlatupar; ?>">
                <input type="hidden" id="cdcooper_<?php echo $nrparepr; ?>" name="cdcooper[]" value="<?php echo getByTagName($registro->tags, 'cdcooper'); ?>">
                <input type="hidden" id="nrdconta_<?php echo $nrparepr; ?>" name="nrdconta[]" value="<?php echo getByTagName($registro->tags, 'nrdconta'); ?>">
                <input type="hidden" id="nrctremp_<?php echo $nrparepr; ?>" name="nrctremp[]" value="<?php echo getByTagName($registro->tags, 'nrctremp'); ?>">
                <input type="hidden" id="nrparepr_<?php echo $nrparepr; ?>" name="nrparepr[]" value="<?php echo $nrparepr; ?>">
                <input type="hidden" id="parcela_<?php echo $parcela ?>" name="parcela[]" value="<?php echo $nrparepr; ?>">	
                <input type="hidden" id="dtvencto_<?php echo $nrparepr ?>" name="dtvencto[]" value="<?php echo getByTagName($registro->tags, 'dtvencto'); ?>">						
                <input type="hidden" id="vliofcpl_<?php echo $nrparepr ?>" name="vliofcpl[]" value="<?php echo getByTagName($registro->tags, 'vliofcpl'); ?>">
                <input type="hidden" id="vlpagan_<?php echo $nrparepr ?>" name="vlpagan[]" value = "<?php echo number_format(0); ?>">

                <input type="hidden" id="vlatraso_<?php echo $nrparepr; ?>" name="vlatraso[]" value="<?php echo $vlatraso; ?>">

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
    <a href="#" class="botao" id="btGerar"  	onClick="confirmaGeracaoBoletoPP(); return false;">Gerar Boleto</a>
</div>
