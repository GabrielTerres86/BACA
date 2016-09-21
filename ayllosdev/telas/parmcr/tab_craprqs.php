<? 
/*!
 * FONTE        : tab_craprqs.php
 * CRIAÇÃO      : Jonata - (RKAM)
 * DATA CRIAÇÃO : 08/12/2014 
 * OBJETIVO     : Tabela que apresenta as respostas dos questionarios
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

<form id="frmCraprqs" name="frmCraprqs" class="formulario">

	<input type="hidden" name="nrseqres" id="nrseqres" value="<? echo $inf[0]->nrseqres; ?>">

	<fieldset>

	<legend> Respostas </legend>
	
	<div id="tabCraprqs">
		<div class="divRegistros">	
			<table class="tituloRegistros">
				<thead>
					<tr>
						<th style="width:50px;"> <? echo utf8ToHtml('Sequência');            ?> </th>
						<th style="width:120px;"><? echo utf8ToHtml('Respostas Possíveis'); ?> </th>
					</tr>
				</thead>
				<tbody>
					<?php				
					for ($i = 0; $i < $qtregist; $i++) {
					
						$nrseqres = $inf[$i]->nrseqres;
						$nrordres = $inf[$i]->nrordres;
						$dsrespos = $inf[$i]->dsrespos; 
									
					?>
						<tr onclick="selecionaResposta(<? echo $nrseqres; ?>)">
							<td><? echo $nrordres; ?></td>
							<td><? echo $dsrespos; ?></td>
						</tr>
				<? } ?>	
				</tbody>
			</table>
		
		</div>	
	</div>

	<div id="divBotoes" style='margin-top:0px; margin-bottom :0px'>
		<a href="#" class="botao" id="btIncluir" onclick="rotina('I_craprqs_1'); return false;">Incluir</a>
		<a href="#" class="botao" id="btAlterar" onclick="rotina('A_craprqs_1'); return false;">Alterar</a>
		<a href="#" class="botao" id="btExcluir" onclick="manter_rotina('E_craprqs_1'); return false;">Excluir</a>
	</div>

	</fieldset>

</form>


<script>
	formataTabelaResposta();
</script>