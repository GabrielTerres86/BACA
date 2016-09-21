<? 
/*!
 * FONTE        : tab_linhaCred.php
 * CRIA��O      : J�ssica (DB1)						�ltima altera��o: 05/12/2014
 * DATA CRIA��O : 05/03/2014
 * OBJETIVO     : Tabela que apresenta os dados da linha de credito da op��o A da tela MOVTOS
 *
 Altera��es: 05/12/2014 - Ajustes para libera��o (Adriano)
 
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
						<th>Descri��o</th>
					</tr>			
				</thead>
				<tbody>
					<?
					foreach($registros1 as $i) {      
				
						// Recebo todos valores em vari�veis
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