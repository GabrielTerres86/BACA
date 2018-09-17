<?php 
/*!
 * FONTE        : tab_modalidade_vencimento.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 05/12/2011 
 * OBJETIVO     : Tabela que apresenta o VENCIMENTO da MODALIDADE da tela CONSCR
 * --------------
 * ALTERAÇÕES   : 
 * 002: 20/06/2012 - Incluido LIMITE CREDITO e reorganizado as colunas (Tiago).
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
	* 003: 01/08/2016 - Carlos R.(CECRED) : Corrigi o uso desnecessario da funcao session_start. SD 491672.
 * --------------
 */
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmModalidadeVencimento" class="formulario">
	
	<fieldset style="width:600px;">

	<legend>Vencimentos</legend>

	<label for="cdmodali">Modalidade Principal:</label>
	<input type="text" id="cdmodali" name="cdmodali" value="<?php echo $cdmodali ?>" />
	<input type="text" id="dsmodali" name="dsmodali" value="<?php echo $dsmodali ?>" />								  
	<br />
	</fieldset>	
</form>

<form name="frmFluxo" id="frmFluxo" class="formulario" onSubmit="return false;" >	
	<fieldset>
	<div>
	
<table style="width:600px;">
<tr>	
	<td><label for="avencer1">A VENCER:</label></td>
	<td><label for="valor111">VALOR</label></td>
	<td><label for="vencidos">LIMITE CR&Eacute;DITO:</label></td>
	<td><label for="valor222">VALOR</label></td>
</tr>	
	
	
<?php

	$column2 = 12;

	for ( $i = 0; $i <= 3; $i++ ) {		
?>	
<tr>
	<td><label for="dsvencto1"><?php echo getByTagName($registro[$i]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo $i ?>" name="vlvencto<?php echo $i ?>" type="text" class="vlvencto1" value="<?php echo formataMoeda(getByTagName($registro[$i]->tags,'vlvencto'));  ?>" tabindex="<?php echo $i+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $i ?>', '<?php echo getByTagName($registro[$i]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$i]->tags,'vlvencto') ?>', event)"/></td>
	<td><label for="dsvencto2"><?php echo getByTagName($registro[$column2+$i]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo $column2+$i ?>" name="vlvencto<?php echo $column2+$i ?>" type="text" class="vlvencto2" value="<?php echo formataMoeda(getByTagName($registro[$column2+$i]->tags,'vlvencto'));  ?>" tabindex="<?php echo $column2+$i+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $column2+$i ?>', '<?php echo getByTagName($registro[$column2+$i]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$column2+$i]->tags,'vlvencto') ?>', event)" /></td>
</tr>	


<?php
	}
?>
<tr>		
	<td><label for="dsvencto1"><?php echo getByTagName($registro[4]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo 4 ?>" name="vlvencto<?php echo 4 ?>" type="text" class="vlvencto1" value="<?php echo formataMoeda(getByTagName($registro[4]->tags,'vlvencto'));  ?>" tabindex="<?php echo 4+1 ?>" onKeyPress="return fluxoVencimento('<?php echo 4 ?>', '<?php echo getByTagName($registro[4]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[4]->tags,'vlvencto') ?>', event)"/></td>
	<td></td>
	<td></td>
</tr>
<tr>	
	<td><label for="dsvencto1"><?php echo getByTagName($registro[5]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo 5 ?>" name="vlvencto<?php echo 5 ?>" type="text" class="vlvencto1" value="<?php echo formataMoeda(getByTagName($registro[5]->tags,'vlvencto'));  ?>" tabindex="<?php echo 5+1 ?>" onKeyPress="return fluxoVencimento('<?php echo 5 ?>', '<?php echo getByTagName($registro[5]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[5]->tags,'vlvencto') ?>', event)"/></td>
	<td><label for="vencidos" style="text-align:left;"><? echo utf8ToHtml('VENCIDOS:') ?></label></td>
	<td><label for="valor222" style="text-align:left;"><? echo utf8ToHtml('VALOR') ?></label></td>		
</tr>	
		
<?php
	for ( $i = 6; $i <= 12; $i++ ) {		
?>	
<tr>
<?php if($i < 12){ ?>
	<td><label for="dsvencto1"><?php echo getByTagName($registro[$i]->tags,'dsvencto');  ?>:</label></td>	
	<td><input id="vlvencto<?php echo $i ?>" name="vlvencto<?php echo $i ?>" type="text" class="vlvencto1" value="<?php echo formataMoeda(getByTagName($registro[$i]->tags,'vlvencto'));  ?>" tabindex="<?php echo $i+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $i ?>', '<?php echo getByTagName($registro[$i]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$i]->tags,'vlvencto') ?>', event)"/></td>
<?php } else { ?>
    <td></td><td></td>
<?php } ?>	
	<td><label for="dsvencto2"><?php echo getByTagName($registro[$column2+$i]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo $column2+$i ?>" name="vlvencto<?php echo $column2+$i ?>" type="text" class="vlvencto2" value="<?php echo formataMoeda(getByTagName($registro[$column2+$i]->tags,'vlvencto'));  ?>" tabindex="<?php echo $column2+$i+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $column2+$i ?>', '<?php echo getByTagName($registro[$column2+$i]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$column2+$i]->tags,'vlvencto') ?>', event)" /></td>
</tr>

<?php
	}
?>		
<tr>
	<td></td><td></td>
	<td><label for="dsvencto2"><?php echo getByTagName($registro[$column2+13]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo $column2+13 ?>" name="vlvencto<?php echo $column2+13 ?>" type="text" class="vlvencto2" value="<?php echo formataMoeda(getByTagName($registro[$column2+13]->tags,'vlvencto'));  ?>" tabindex="<?php echo $column2+13+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $column2+13 ?>', '<?php echo getByTagName($registro[$column2+13]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$column2+13]->tags,'vlvencto') ?>', event)" /></td>
</tr>	
<tr>
	<td></td><td></td>
	<td><label for="dsvencto2"><?php echo getByTagName($registro[$column2+14]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo $column2+14 ?>" name="vlvencto<?php echo $column2+14 ?>" type="text" class="vlvencto2" value="<?php echo formataMoeda(getByTagName($registro[$column2+14]->tags,'vlvencto'));  ?>" tabindex="<?php echo $column2+14+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $column2+14 ?>', '<?php echo getByTagName($registro[$column2+14]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$column2+14]->tags,'vlvencto') ?>', event)" /></td>
</tr>	
<tr>
	<td></td><td></td>
	<td><label for="dsvencto2"><?php echo getByTagName($registro[$column2+15]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo $column2+15 ?>" name="vlvencto<?php echo $column2+15 ?>" type="text" class="vlvencto2" value="<?php echo formataMoeda(getByTagName($registro[$column2+15]->tags,'vlvencto'));  ?>" tabindex="<?php echo $column2+15+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $column2+15 ?>', '<?php echo getByTagName($registro[$column2+15]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$column2+15]->tags,'vlvencto') ?>', event)" /></td>
</tr>		
<!--
<tr>
	<td></td><td></td>
	<td><label for="dsvencto2"><?php echo getByTagName($registro[$column2+16]->tags,'dsvencto');  ?>:</label></td>
	<td><input id="vlvencto<?php echo $column2+16 ?>" name="vlvencto<?php echo $column2+16 ?>" type="text" class="vlvencto2" value="<?php echo formataMoeda(getByTagName($registro[$column2+16]->tags,'vlvencto'));  ?>" tabindex="<?php echo $column2+16+1 ?>" onKeyPress="return fluxoVencimento('<?php echo $column2+16 ?>', '<?php echo getByTagName($registro[$column2+16]->tags,'cdvencto') ?>', '<?php echo getByTagName($registro[$column2+16]->tags,'vlvencto') ?>', event)" /></td>
</tr>		-->
</table>
	</div>
	</fieldset>
	
</form>

<!-- <div id="divMsgAjuda" style="width:608px;">
	<span><? /* echo utf8ToHtml('Clique no botão VOLTAR para sair!.'); */?></span> -->

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar"onclick="operacao=voltapra; buscaOpcao(); return false;" >Voltar</a>
	</div>

<!-- </div>					-->												
