<?php
/* 
 * FONTE        : form_tab089.php
 * CRIAÇÃO      : Diego Simas/Reginaldo Silva/Letícia Terres - AMcom
 * DATA CRIAÇÃO : 12/01/2018
 * OBJETIVO     : Formulário de exibição da tela TAB089
 * ALTERAÇÕES   : 
 *                30/05/2018 - Inclusão de campo de taxa de juros remuneratório de prejuízo (pctaxpre)
 *                             PRJ 450 - Diego Simas (AMcom)
 *
 *                20/06/2018 - Inclusão do campo Prazo p/ transferência de valor da conta transitória para a CC	
 *							               PRJ 450 - Diego Simas (AMcom)	
 *
 *                10/07/2018 - PJ 438 - Agilidade nas Contratações de Crédito - Márcio (Mouts)
 *
 *				   14/09/2018 - Adicionado a div Desconto de Titulos - Estorno de Pagamentos (Cássia de Oliveira - GFT)
 *                 30/10/2018 - PJ 438 - Adicionado 2 novos parametros (avtperda e vlperavt) - Mateus Z (Mouts)
 *                 11/12/2018 - PRJ 470 - Adicionado 2 novos parametros (inpreapv e vlmincnt) - Mateus Z (Mouts)
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form name="frmTab089" id="frmTab089" class="formulario" style="display:block;">	
    <br style="clear:both" />
	<input type="hidden" id="dsdepart" name="dsdepart" value="<?php echo $glbvars["dsdepart"]; ?>" />
    <input type="hidden" id="idctrlab" name="idctrlaba" value="COOPER" />
	
	<fieldset>
		<legend>Par&acirc;metros</legend>
		
		<label for="prtlmult" class='labelPri' >Prazo de toler&acirc;ncia para incid&ecirc;ncia de multa e juros de mora:</label>
		<input type="text" id="prtlmult" name="prtlmult" value="<?php echo $prtlmult == 0 ? '' : $prtlmult ?>" />
		<br style="clear:both" />
		
		<label for="prestorn" class='labelPri' >Prazo m&aacute;ximo para estorno de contratos com aliena&ccedil;&atilde;o/hipoteca de im&oacute;veis:</label>
		<input type="text" id="prestorn" name="prestorn" value="<?php echo $prestorn == 0 ? '' : $prestorn ?>" />
		<br style="clear:both" />

		<label for="prpropos" class='labelPri'>Prazo m&aacute;ximo de validade da proposta:</label>
		<select id="prpropos" name="prpropos" style="width:100px;">
			<option value='DTLIBERA'> DTLIBERA </option>
			<option value='DTVENPAR'> DTVENPAR </option>
		</select>   
		<br style="clear:both" />
		
		<label for="vlempres" class='labelPri'>Valor m&iacute;nimo para cobran&ccedil;a de empr&eacute;stimo:</label>
		<input type="text" id="vlempres" name="vlempres" class="moeda" value="<?php echo $vlempres == 0 ? '' : $vlempres ?>" style="text-align:right;"/>
		<br style="clear:both" />

		<label for="pzmaxepr" class='labelPri'>Prazo m&aacute;ximo para libera&ccedil;&atilde;o do empr&eacute;stimo:</label>
		<input type="text" id="pzmaxepr" name="pzmaxepr" class="inteiro" value="<?php echo $pzmaxepr == 0 ? '' : $pzmaxepr ?>" maxlength="4" style="text-align:right;"/>			
		<br style="clear:both" />
		
		<label for="vlmaxest" class='labelPri'>Vl. m&aacute;x. de estorno perm. sem autoriza&ccedil;&atilde;o da coordena&ccedil;&atilde;o/ger&ecirc;ncia:</label>
		<input type="text" id="vlmaxest" name="vlmaxest" class="moeda" value="<?php echo $vlmaxest == 0 ? '' : $vlmaxest ?>" style="text-align:right;"/>			
		<br style="clear:both" />

		<label for="pcaltpar" class='labelPri'>Altera&ccedil;&atilde;o de parcela:</label>
		<input type="text" id="pcaltpar" name="pcaltpar" class="moeda" value="<?php echo $pcaltpar == 0 ? '' : $pcaltpar ?>" maxlength="6" style="text-align:right;"/>	
		<label>&nbsp;%</label>
		<br style="clear:both" />
		
		<label for="vltolemp" class='labelPri'>Toler&acirc;ncia por valor de empr&eacute;stimo:</label>
		<input type="text" id="vltolemp" name="vltolemp" class="moeda" value="<?php echo $vltolemp == 0 ? '' : $vltolemp ?>" style="text-align:right;"/>
		<br style="clear:both" />
		<!-- PRJ 438 - Sprint 5 - Mateus -->
		<label for="avtperda" class='labelPri'>Altera&ccedil;&atilde;o de avalista:</label>
		<select id="avtperda" name="avtperda" style="width:100px;">
			<option value='0'> Perde aprova&ccedil;&atilde;o </option>
			<option value='1'> N&atilde;o perde aprova&ccedil;&atilde;o </option>
		</select>
		<br style="clear:both" />

		<label for="vlperavt" class='labelPri'>Valor m&aacute;ximo para altera&ccedil;&atilde;o de avalista sem perda de aprova&ccedil;&atilde;o:</label>
		<input type="text" id="vlperavt" name="vlperavt" value="<?php echo $vlperavt == 0 ? '' : $vlperavt ?>" style="text-align:right;"/>
		<!-- FIM PRJ 438 - Sprint 5 - Mateus -->
    </fieldset>
	
	<fieldset>
		<legend>PA - Prazo de validade da an&aacute;lise para efetiva&ccedil;&atilde;o</legend>
		<label for="qtdpaimo" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Im&oacute;vel </label>
		<input type="text" id="qtdpaimo" name="qtdpaimo" value="<?php echo $qtdpaimo == 0 ? '' : $qtdpaimo ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtdpaaut" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Autom&oacute;vel</label>
		<input type="text" id="qtdpaaut" name="qtdpaaut" value="<?php echo $qtdpaaut == 0 ? '' : $qtdpaaut ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtdpaava" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Aval</label>
		<input type="text" id="qtdpaava" name="qtdpaava" value="<?php echo $qtdpaava == 0 ? '' : $qtdpaava ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtdpaapl" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Aplica&ccedil;&atilde;o</label>
		<input type="text" id="qtdpaapl" name="qtdpaapl" value="<?php echo $qtdpaapl == 0 ? '' : $qtdpaapl ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtdpasem" class='labelPri'>Opera&ccedil;&atilde;o sem garantia</label>
		<input type="text" id="qtdpasem" name="qtdpasem" value="<?php echo $qtdpasem == 0 ? '' : $qtdpasem ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />
		
		<!-- Início PJ438 - Márcio (Mouts)-->
		<label for="qtdpameq" class='labelPri'>Opera&ccedil;&atilde;o com garantia de M&aacute;quinas e Equipamentos</label>
		<input type="text" id="qtdpameq" name="qtdpameq" value="<?php echo $qtdpameq == 0 ? '' : $qtdpameq ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />
		<!-- Fim PJ438 - Márcio (Mouts)-->
	</fieldset>

	<fieldset>
		<legend>Mobile/IB/TAA - Prazo de validade da an&aacute;lise para efetiva&ccedil;&atilde;o</legend>
		
		<label for="qtdibaut" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Autom&oacute;vel</label>
		<input type="text" id="qtdibaut" name="qtdibaut" value="<?php echo $qtdibaut == 0 ? '' : $qtdibaut ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtdibapl" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Aplica&ccedil;&atilde;o</label>
		<input type="text" id="qtdibapl" name="qtdibapl" value="<?php echo $qtdibapl == 0 ? '' : $qtdibapl ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtdibsem" class='labelPri'>Opera&ccedil;&atilde;o sem garantia</label>
		<input type="text" id="qtdibsem" name="qtdibsem" value="<?php echo $qtdibsem == 0 ? '' : $qtdibsem ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />
	</fieldset>    
				 
    <!-- Início PJ438 - Márcio (Mouts)-->	
	<fieldset>
		<legend>Limite de Descontos de T&iacute;tulos - Prazo de validade da an&aacute;lise para efetiva&ccedil;&atilde;o</legend>
		
		<label for="qtditava" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Aval</label>
		<input type="text" id="qtditava" name="qtditava" value="<?php echo $qtditava == 0 ? '' : $qtditava ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtditapl" class='labelPri'>Opera&ccedil;&atilde;o com garantia de Aplica&ccedil;&atilde;o</label>
		<input type="text" id="qtditapl" name="qtditapl" value="<?php echo $qtditapl == 0 ? '' : $qtditapl ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

		<label for="qtditsem" class='labelPri'>Opera&ccedil;&atilde;o sem garantia</label>
		<input type="text" id="qtditsem" name="qtditsem" value="<?php echo $qtditsem == 0 ? '' : $qtditsem ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />
	</fieldset>    
    <!-- Fim PJ438 - Márcio (Mouts)-->	

	<fieldset>
		<legend>Preju&iacute;zo</legend>
		
		<label for="pctaxpre" class='labelPri'>Taxa de juros remunerat&oacute;rio de preju&iacute;zo:</label>
		<input type="text" id="pctaxpre" name="pctaxpre" class="moeda" value="<?php echo $pctaxpre == 0 ? '' : $pctaxpre ?>" maxlength="6" style="text-align:right;width:50px;"/>	
		<label>&nbsp;%</label>
		<br style="clear:both" />
		
		<label for="qtdictcc" class='labelPri'>Prazo p/ transfer&ecirc;ncia autom&aacute;tica de valor de preju&iacute;zo bloqueado para a CC:</label>
		<input type="text" id="qtdictcc" name="qtdictcc" value="<?php echo $qtdictcc == 0 ? '' : $qtdictcc ?>" maxlength="3" style="text-align:right;"/>	
		<label>&nbsp;dia(s)</label>
		<br style="clear:both" />

	</fieldset>	  

	<fieldset>
		<legend>Desconto de T&iacute;tulos - Estorno de Pagamentos</legend>
		
		<label for="vlmaxdst" class='labelPri'>Vl. m&aacute;x. de estorno perm. sem autoriza&ccedil;&atilde;o da coordena&ccedil;&atilde;o/ger&ecirc;ncia</label>
		<input type="text" id="vlmaxdst" name="vlmaxdst" class="moeda" value="<?php echo $vlmaxdst == 0 ? '' : $vlmaxdst ?>" style="text-align:right;"/>
		<br style="clear:both" />
	</fieldset> 


	<!-- Inicio PRJ 470 -->
	<?php if($glbvars['cdcooper'] != 3) { // Exibir Contratação de Crédito apenas se não for cooperativa 3 (Ailos) ?> 
	<fieldset>
			<!-- <legend>Contrata&ccedil;&atilde;o de Cr&eacute;dito</legend> -->
			<legend>Contrata&ccedil;&otilde;es de Cr&eacute;dito autorizados por senha</legend>
			
			<label for="inpreapv" class='labelPri'>Utilizar pr&eacute;-aprovado cooperado:</label>
			<select id="inpreapv" name="inpreapv" style="width:100px;">
				<!-- Bruno - prj 470 - ALteração Tab089 -->
				<option value='S'> Sim </option>
				<option value='N'> N&atilde;o </option>
			</select>   	
		<br style="clear:both" />
			
			<!-- <label for="vlmincnt" class='labelPri'>Valor m&iacute;nimo contrata&ccedil;&atilde;o:</label> -->
			<label for="vlmincnt"  class='labelPri'>Valor Limite Autorizado: </label>
			<input type="text" id="vlmincnt" name="vlmincnt" value="<?php echo $vlmincnt == 0 ? '' : $vlmincnt ?>" style="text-align:right;"/>
			<br style="clear:both" />

	</fieldset> 
	<?php } ?>
	<!-- Fim PRJ 470 -->
</form>

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onclick="estadoInicial();
	return false;">Voltar</a>
	<a href="#" class="botao" id="btContinuar"  onClick="confirmaOperacao();
	return false;">Alterar</a>
</div>
