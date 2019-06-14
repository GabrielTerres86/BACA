<? 
/*!
 * FONTE        : tab_registros.php						Última alteração:  
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Novembro/2018
 * OBJETIVO     : Tabela que apresenta inconsistencias na importação do arquivo, opção "I".
 * --------------
 * ALTERAÇÕES   :  
                    
 * --------------
 */

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmInconsistencias" name="frmInconsistencias" class="formulario">

	<fieldset id="fsetInconsistencias" name="fsetInconsistencias" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Inconsist&ecirc;ncias"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th><?php echo utf8ToHtml("Linha"); ?></th>
						<th><?php echo utf8ToHtml("Erro"); ?></th>
						<th><?php echo utf8ToHtml("Descrição dos erros do arquivo"); ?></th>
					</tr>
				</thead>
				<tbody>
					<?  for($i = 0; $i < count($inconsistencias); $i++){
						
							for($j = 0; $j < count($inconsistencias[$i]->tags); $j++){?> 
								<tr>	
								    <td><span><? echo $i + 1; ?></span> <? echo $i + 1; ?> </td>
									<td><span><? echo $j + 1; ?></span> <? echo $j + 1; ?> </td>
									<td><span><? echo $inconsistencias[$i]->tags[$j]->cdata; ?></span> <? echo $inconsistencias[$i]->tags[$j]->cdata; ?> </td>
																
								</tr>	
					<? 		} 
						}
					?>
				</tbody>	
			</table>
		</div>
		<div id="divRegistrosRodape" class="divRegistrosRodape">
			<table>	
				<tr>
					<td>
						 
					</td>
					<td>
						 
					   Total: <? echo $qtregist; ?> 
							 
					</td>
					<td>
						 
					</td>
				</tr>
			</table>
		</div>	
	</fieldset>
</form>

<div id="divBotoestInconsistencias" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('3'); return false;">Voltar</a>		
	   																			
</div>



<script type="text/javascript">
	
	$('#divRegistrosRodape','#divInconsistencias').formataRodapePesquisa();
	
	formataTabelaInconsistencias();	
	
				
</script>