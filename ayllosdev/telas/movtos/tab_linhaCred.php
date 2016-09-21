<? 
/*!
 * FONTE        : tab_linhaCred.php
 * CRIAÇÃO      : Jéssica (DB1)						Última alteração: 05/12/2014
 * DATA CRIAÇÃO : 05/03/2014
 * OBJETIVO     : Tabela que apresenta os dados da linha de credito da opção A da tela MOVTOS
 *
 Alterações: 05/12/2014 - Ajustes para liberação (Adriano)
 
 */	
?>

<?

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>
<form id="frmTabela2" class="formulario" >

	<fieldset>
	
		<legend align="center";><b>Escolha Linha Credito</b></legend>

		<div id="registrosLinhaCredito" class="divRegistros">
			<table id="linCred">
				<thead>
					<tr><th></th>
						<th>Cod</th>
						<th>Descrição</th>
					</tr>			
				</thead>
				<tbody>
					<?
					foreach($registros1 as $i) {      
				
						// Recebo todos valores em variáveis
						$cdcodigo	= getByTagName($i->tags,'cdcodigo');
						$dsdescri	= getByTagName($i->tags,'dsdescri');
																					
					?>			
						<tr>
							<td><span><? echo $flgmarca; ?></span>
								<input name="aplicacao" type="checkbox" class="flag" value="<? echo $cdcodigo; ?>" ></td>
									
							<td><span><? echo $cdcodigo ?></span>
								<? echo $cdcodigo; ?>

							</td>
												
							<td> <? echo $dsdescri ?> </td>
							
						</tr>	
					<? } ?>			
				</tbody>
			</table>
		</div>

	</fieldset>
	
</form>