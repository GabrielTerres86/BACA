<? 
/*!
 * FONTE        : tabela_atacor.php
 * CRIAÇÃO      : Reginaldo (AMcom)
 * DATA CRIAÇÃO : 06/02/2018
 * OBJETIVO     : Tabela que apresenda os contratos e conta vinculados com um acordo de cobrança
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 */	
?>

<form class="formulario" onSubmit="return false;">
<fieldset style="padding-top: 15px;">
<legend>Informações do acordo</legend>
<div class='divRegistros'>	
	<table>
        <thead>
            <tr>
                <th><span title="Produto">Produto</span></th>
                <th><span title="Contrato">Contrato</span></th>
                <th><span title="Linha de crédito">Linha de Crédito</span></th>
                <th><span title="Pagar (S/N)">Pagar (S/N)</span></th>
            </tr>
        </thead>
        <tbody>
	<?
        foreach($contratos as $contrato) {
            $nrctremp = getByTagName($contrato->tags,'nrctremp');
            $dsorigem = getByTagName($contrato->tags,'dsorigem');
            $cdlcremp = getByTagName($contrato->tags,'cdlcremp');
            $indpagar = getByTagName($contrato->tags,'indpagar');
            $cdoperad = getByTagName($contrato->tags,'cdoperad');
            $cdorigem = getByTagName($contrato->tags,'cdorigem');
    ?>
            <tr>
                <td><input type="hidden" name="cdoperad" value="<? echo $cdoperad; ?>"> <? echo $dsorigem; ?></td>
                <td><input type="hidden" name="nrctremp" value="<? echo $nrctremp; ?>"><? echo number_format($nrctremp, 0, '', '.'); ?></td>
                <td><input type="hidden" name="cdlcremp" value="<? echo $cdlcremp; ?>"><? echo $cdlcremp; ?></td>
                <td><input type="checkbox" name="pagar" <? echo $indpagar == 'S' ? 'checked="checked"' : '';  echo !($cdorigem == 1 || $cdlcremp == 100) ? ' disabled="true"' : ''; ?> style="float: none;" onchange="atualizarContrato(this)"></td>
            </tr>					
    <?
    }
    ?>
		</tbody>
	</table>
</div>
<div id="botoes" style="text-align: center; width: 100%;">
<a href="javascript:;" class="botao FluxoNavega" style="float: none;" onclick="incluirContrato()">Incluir contrato</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:;" id="botaoExcluirContrato" class="botao FluxoNavega" style="float: none;" onclick="processarExclusao()">Remover contrato</a>
</div>
</fieldset>
</form>
