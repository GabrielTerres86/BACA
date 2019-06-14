<? 
/*!
 * FONTE        : tab_crapvqs.php
 * CRIAÇÃO      : Jonata - (RKAM)
 * DATA CRIAÇÃO : 08/12/2014 
 * OBJETIVO     : Tabela que apresenta as versoes dos questionarios
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

<form id="frmCrapvqs" name="frmCrapvqs" class="formulario">

	<input type="hidden" name="nrversao" id="nrversao" value="<? echo $inf[0]->nrversao; ?>">
	<input type="hidden" name="dtinivig" id="dtinivig" value="<? echo $inf[0]->dtinivig; ?>">
	<input type="hidden" name="dtmvtolt" id="dtmvtolt" value="<? echo $glbvars['dtmvtolt'] ?>">

	<fieldset>
	
	<legend> Vers&otilde;es </legend>
	
	<div id="tabCrapvqs" style="width:750px">
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
					
						$nrversao = $inf[$i]->nrversao;
						$dsversao = $inf[$i]->dsversao;
						$dtinivig = $inf[$i]->dtinivig; 
						
									
					?>
						<tr onclick="selecionaVersao( <? echo $nrversao; ?> , '<? echo $dtinivig; ?>') ">
							<td style="width:53%"><? echo $dsversao; ?></td>
							<td style="width:47%"><? echo $dtinivig; ?></td>
						</tr>
				<? } ?>	
				</tbody>
			</table>
		
		</div>	
	</div>

	<div id="divBotoes" style='margin-top:0px; margin-bottom :0px'>
		<a href="#" class="botao" id="btIncluir" onclick="rotina('I_crapvqs_1'); return false;">Incluir</a>
		<a href="#" class="botao" id="btAlterar" onclick="rotina('A_crapvqs_1'); return false;">Alterar</a>
		<a href="#" class="botao" id="btExcluir" onclick="manter_rotina('E_crapvqs_1'); return false;">Excluir</a>
		<a href="#" class="botao" id="btDuplicar" onclick="rotina('D_crapvqs_1'); return false;">Duplicar vers&atilde;o</a>
		<a href="#" class="botao" id="btPerguntas" onclick="verificaTipoPessoa(); return false;">Exibir perguntas</a>
	</div>

	</fieldset>

</form>


<script>
	formataTabelaVersao();
	
	<? if ( $inf[0]->nrversao != '' ) { ?>
		controlaOperacao('C2' , <? echo $inf[0]->nrversao ?>, 0 , 0, <? echo $flgbloqu ?>);
	<? } ?>

</script>
