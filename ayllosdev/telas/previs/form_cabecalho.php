<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 21/12/2011											ÚLTIMA ALTERAÇÃO: 03/10/2016
 * OBJETIVO     : Cabeçalho para a tela PREVIS
 * --------------
 * ALTERAÇÕES   : 01/08/2012 - Incluido as subopcoes(E,S,R) na opcao 'F' da tela PREVIS (Tiago).
 * -------------- 17/08/2012 - Alternado a posição do campo dtmvtolt para vir antes do campo cdcooper (Adriano).
 *                25/03/2013 - Padronização de novo layout (Daniel).
 *                05/09/2013 - Alteração da sigla PAC para PA (Carlos).
 *                03/10/2016 - Remocao das opcoes "F" e "L" para o PRJ313. (Jaison/Marcos SUPERO)
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Entre com a opcao desejada (A,C,F,I,L).">
	<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?> >A - Alterar previsoes financeiras.</option>
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Consultar previsoes financeiras.</option>
	<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?> >I - Incluir previsoes financeiras.</option>
	</select>

	
	<div id="divmovmto" name="divmovmto">
		<label for="cdmovmto"><? echo utf8ToHtml('Movimento:') ?></label>
		<select id="cdmovmto" name="cdmovmto" alt="<?php if($glbvars["cdcooper"] == 3){echo 'Entre com a opcao desejada (A,E,S,R).';}else{ echo 'Entre com a opcao desejada (E,S,R).';} ?>">
		<option value="E" <?php echo $cdmovmto == 'E' ? 'selected' : '' ?> >E - Entrada de Recursos</option>
		<option value="S" <?php echo $cdmovmto == 'S' ? 'selected' : '' ?> >S - Saida de Recursos</option>
		<option value="R" <?php echo $cdmovmto == 'R' ? 'selected' : '' ?> >R - Resultado</option>
		<?php if($glbvars["cdcooper"] == 3){ ?>
		<option value="A" class="removerI" <?php echo $cdmovmto == 'A' ? 'selected' : '' ?> >A</option>
		<?php } ?>
		</select>	
	</div>
	
	<label for="dtmvtolt"><? echo utf8ToHtml('Referência:') ?></label>
	<input name="dtmvtolt" id="dtmvtolt" type="text" value="<?php echo $dtmvtolx ?>" alt="Entre com a data a que se refere a previsao." />

	<div id="divcooper" name="divcooper">
		<br style="clear:both" />
		<label for="cdcooper">Cooperativa:</label>
		<select name="cdcooper" id="cdcooper" alt="Selecione a Cooperativa">
		</select>
	</div>
	
	<div id="divagenci" name="divagenci">
		<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
		<input name="cdagenci" id="cdagenci" type="text" value="<?php echo $cdagencx ?>" alt="Pressione 'F7' para Zoom ou '0' para Todos PAs."/>
		<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	</div>
	
	<br style="clear:both" />	

</form>

