<? 
/*!
 * FONTE        : tab_crapvac.php
 * CRIAÇÃO      : Jonata - (RKAM)
 * DATA CRIAÇÃO : 29/01/2015 
 * OBJETIVO     : Tabela que apresenta as versoes da PARRAC
 * --------------
 * ALTERAÇÕES   : 
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCrapvac" name="frmCrapvac" class="formulario">

	<input type="hidden" name="nrseqvac" id="nrseqvac" value="<? echo $inf[0]->nrseqvac; ?>">
	<input type="hidden" name="dsversao" id="dsversao" value="<? echo $inf[0]->dsversao; ?>">
	<input type="hidden" name="dtinivig" id="dtinivig" value="<? echo $inf[0]->dtinivig; ?>">
	<input type="hidden" name="dtmvtolt" id="dtmvtolt" value="<? echo $glbvars['dtmvtolt']; ?>">
	
	<fieldset>

		<legend> Vers&otilde;es </legend>
		
		<div id="tabCrapvac">
			<div class="divRegistros">	
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th style="width:52%"><? echo utf8ToHtml('Versão'); ?></th>
							<th style="width:48%"><? echo utf8ToHtml('In&iacute;cio Vig&ecirc;ncia');  ?></th>
						</tr>
					</thead>
					<tbody>
						<?php				
						for ($i = 0; $i < $qtregist; $i++) {
						
							$nrseqvac = $inf[$i]->nrseqvac;
							$dsversao = $inf[$i]->dsversao;
							$dtinivig = $inf[$i]->dtinivig;							
						?>
							<tr onclick="selecionaVersao(<? echo $nrseqvac; ?>,'<? echo $dsversao; ?>' , '<? echo $dtinivig; ?>');">
														  
								<td style="width:53%"><? echo $dsversao; ?></td>
								<td style="width:47%"><? echo $dtinivig; ?></td>							
							</tr>
					<? } ?>	
					</tbody>
				</table>
			
			</div>	
		</div>

		<div id="divBotoes" style='margin-top:0px; margin-bottom :0px'>
			<a href="#" class="botao" id="btIncluir" onclick="rotina('I_crapvac_1'); return false;">Incluir</a>
			<a href="#" class="botao" id="btAlterar" onclick="rotina('A_crapvac_1'); return false;">Alterar</a>
			<a href="#" class="botao" id="btnExcluir" onclick="manter_rotina('E_crapvac_1'); return false;">Excluir</a> 
			<a href="#" class="botao" id="btDuplicarCoop" onclick="rotina('D_crapvac_1'); return false;">Duplicar vers&atilde;o</a>
			<a href="#" class="botao" id="btDuplicar" onclick="rotina('D_crapvac_4'); return false;">Multiplicar Vers&atilde;o (outras coop.)</a>
			<a href="#" class="botao" id="btDuplicar" onclick="manter_rotina('V_questionario'); return false;">Validar Questionario</a>
		</div>
		
		<div style="margin:15px;" >
			<label for ="inparece"> Desabilitar Parecer Credito: </label>	
			<input style="margin-left:10px;margin-top:5px;" name="inparece" id="inparece_1" type="radio" class="radio" value="yes" />
			<label class="radio" >Sim</label>
			<input style="margin-left:10px;margin-top:5px;" name="inparece" id="inparece_2" type="radio" class="radio" value="no" />
			<label class="radio"><? echo utf8ToHtml('Não') ?></label>
			<a style="margin-left:10px;" href="#" class="botao" id="btAlterarParecer" onclick="manter_rotina('A_parecer_1'); return false;">Alterar</a>
		</div>
	
	</fieldset>
	

</form>


<script>
	formataTabelaVersao();
	
	<? if ($inparece == 'S') { ?>
		$("#inparece_1","#frmCrapvac").prop('checked',true);
	<? } else { ?>
		$("#inparece_2","#frmCrapvac").prop('checked',true);
	<? } ?>
	
	<? if ( $inf[0]->nrseqvac != '' ) { ?>
		controlaOperacao('C2' ,'<? echo $inf[0]->nrseqvac; ?>');
	<? } ?>
	
</script>
