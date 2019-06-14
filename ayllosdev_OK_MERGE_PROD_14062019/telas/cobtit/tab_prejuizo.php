<?php 
/*
 * FONTE        : tab_titulos.php
 * CRIAÇÃO      : Cássia de Oliveira (GFT)
 * DATA CRIAÇÃO : 05/10/2018
 * OBJETIVO     : Mostrar campos para gerar boleto de bordero em prejuizo
 * --------------
 */
$vlpagar = 0;
// Se o operador nao possuir permissao para conceder desconto
if($dados->vldsctmx == '0'){
    $inperdct = 0;
    echo "<script>";
    echo "$('#vldescto', '#divValoresTR').val('0,00').desabilitaCampo();";
    echo "</script>";
}else{
    $inperdct = 1;
}


$tpvlpgto = $dados->vltpagar->cdata+$dados->vldacordo->cdata;
?>
<script type="text/javascript">habilitaValorParcialPrejuizo('1','<?php echo $inperdct; ?>');</script>
<form class="formulario" onSubmit="return false;">
    <input type="hidden" id="inperdct" name="inperdct" value="<?php echo $inperdct; ?> "/>
    <input type="hidden" id="descprej" name="descprej" value="<?=formataMoeda($dados->vldsctmx)?> "/>

    <input type="radio" id="tpvlpgto1" class="campo" name="tpvlpgto" value="1" checked="true" onclick="habilitaValorParcialPrejuizo('1','<?php echo $inperdct; ?>')"/> 
    <label style="margin-left:10px">Total do border&ocirc; em preju&iacute;zo:</label>
    <input type="text" id="vlrpgto1" class="campo moeda" name="vlrpgto1" disabled value="<?=formataMoeda($tpvlpgto)?> "/>
    <br style="clear:both" />

    <input type="radio" id="tpvlpgto2" class="campo" name="tpvlpgto" value="2" onclick="habilitaValorParcialPrejuizo('2','<?php echo $inperdct; ?>')" /> 
    <label style="margin-left:10px">Valor parcial do preju&iacute;zo:</label>
    <input style="margin-left:29px" type="text" id="vlrpgto2" class="campo moeda" name="vlrpgto2" onblur="exibeValorPrejuizo('P')" />
    <br style="clear:both" />

    <label style="margin-left:26px">Valor em acordo:</label>
    <input style="margin-left:74px" type="text" id="vlacordo" class="campo moeda" name="vlacordo" disabled value="<?=formataMoeda($dados->vldacordo)?>" />
    <br style="clear:both" />
    
    <label style="margin-left:26px">Desconto para quita&ccedil;&atilde;o (%):</label>
    <input style="margin-left:10px" type="text" id="vldescto" class="campo porcento" name="vldescto" value="0,00" onblur="exibeValorPrejuizo('D')" />
    <br style="clear:both" />

    <label style="margin-left:26px">Valor do boleto:</label>
    <input style="margin-left:81px" type="text" id="totpagto" class="campo moeda" name="totpagto" disabled value="<?php echo $vlsdprej; ?> "/>
</form>
<div id="divBotoes" style="margin-bottom: 15px; text-align:center;">
    <a href="#" class="botao" id="btVoltar"     onClick="<?php echo 'voltarTitulos(); '; ?> return false;">Voltar</a>
    <a href="#" class="botao" id="btGerar"      onClick="finalizarBoleto(); return false;">Gerar Boleto</a>
</div>
