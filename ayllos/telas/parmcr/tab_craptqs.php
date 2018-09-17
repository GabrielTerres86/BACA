<? 
/*!
 * FONTE        : tab_craptqs.php
 * CRIAÇÃO      : Jonata - (RKAM)
 * DATA CRIAÇÃO : 08/12/2014 
 * OBJETIVO     : Tabela que apresenta os titulos das versoes
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

<form id="frmCraptqs" name="frmCraptqs" class="formulario">

	<input type="hidden" name="nrseqtit" id="nrseqtit" value="<? echo $inf[0]->nrseqtit ?>">

	<fieldset>

	<legend> T&iacute;tulos </legend>
	
	<div id="tabCraptqs">
		<div class="divRegistros">	
			<table class="tituloRegistros">
				<thead>
					<tr>
						<th style="width:29%"><? echo utf8ToHtml('Sequência'); ?></th>
						<th style="width:71%"><? echo utf8ToHtml('Título Principal');  ?></th>
					</tr>
				</thead>
				<tbody>
					<?php				
					for ($i = 0; $i < $qtregist; $i++) {
					
						$nrseqtit = $inf[$i]->nrseqtit;
						$nrordtit = $inf[$i]->nrordtit;
						$dstitulo = $inf[$i]->dstitulo; 
									
					?>
						<tr onclick="selecionaTitulo(<? echo $nrseqtit ?>);">
							<td style="width:30%"><? echo $nrordtit; ?></td>
							<td style="width:70%"><? echo $dstitulo; ?></td>
						</tr>
				<? } ?>	
				</tbody>
			</table>
		
		</div>	
	</div>

	<div id="divBotoes" style='margin-top:0px; margin-bottom :0px'>
		<a href="#" class="botao" id="btIncluir" onclick="rotina('I_craptqs_1');  return false;">Incluir</a>
		<a href="#" class="botao" id="btAlterar" onclick="rotina('A_craptqs_1');return false;">Alterar</a>
		<a href="#" class="botao" id="btExcluir" onclick="manter_rotina('E_craptqs_1'); return false;">Excluir</a>
	</div>

	</fieldset>

</form>


<script>
	formataTabelaTitulo();
	
	<? if ($inf[0]->nrseqtit != '' ) { ?>
		controlaOperacao('C3' , 0 , <? echo $inf[0]->nrseqtit ?>, 0, <? echo $flgbloqu ?>);
	<? } ?>
	
</script>
