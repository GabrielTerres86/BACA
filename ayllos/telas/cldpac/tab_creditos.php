<? 
/*!
 * FONTE        	: tab_cheque.php
 * CRIAÇÃO     		: Gabriel Capoia (DB1)
 * DATA CRIAÇÃO 	: 11/01/2013
 * OBJETIVO     	: Tabela que apresenda os cheques da tela PESQDP
 * ULTIMA ALTERAÇÃO : 08/07/2013
 * --------------
 * ALTERAÇÕES   	: 08/07/2013 - Alterado para receber o novo padrão de layout do Ayllos Web. (Reinert)
 *
 */	
?>
<form id="frmTabela" class="formulario" >
	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend>Justificativas</legend>
<div id="divRegistros" class="divRegistros">
	<table>
		<thead>
			<tr><th>Contas/DV</th>
				<th>Nome</th>
				<th>Tp.Pes</th>
				<th>Rendimento</th>
				<th>Credito</th>				
				<th>Just.</th>				
			</tr>			
		</thead>
		<tbody>

			<?
			foreach($registros as $i) {      
        
				// Recebo todos valores em variáveis
				$nrdconta = getByTagName($i->tags,'nrdconta');
				$nmprimtl = getByTagName($i->tags,'nmprimtl');
				$inpessoa = getByTagName($i->tags,'inpessoa');
				$vlrendim = getByTagName($i->tags,'vlrendim');
				$vltotcre = getByTagName($i->tags,'vltotcre');
				$flextjus = getByTagName($i->tags,'flextjus');
				$cddjusti = getByTagName($i->tags,'cddjusti');
				$dsobserv = getByTagName($i->tags,'dsobserv');
				$dsdjusti = getByTagName($i->tags,'dsdjusti');
				$nrdrowid = getByTagName($i->tags,'nrdrowid');
									
			?>			
				<tr>
					<td><span><? echo $nrdconta; ?></span><? echo $nrdconta; ?>
						<input type="hidden" id="cddjusti" name="cddjusti" value="<? echo $cddjusti; ?>" />
						<input type="hidden" id="dsdjusti" name="dsdjusti" value="<? echo $dsdjusti; ?>" />
						<input type="hidden" id="dsobserv" name="dsobserv" value="<? echo $dsobserv; ?>" />
						<input type="hidden" id="flextjus" name="flextjus" value="<? echo $flextjus; ?>" />
						<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo $nrdrowid; ?>" />
					</td>
				    <td><span><? echo $nmprimtl; ?></span><? echo $nmprimtl; ?></td>
				    <td><span><? echo $inpessoa; ?></span><? echo $inpessoa; ?></td>
				    <td><span><? echo formataMoeda($vlrendim) ?></span><? echo formataMoeda($vlrendim) ?></td>
				    <td><span><? echo formataMoeda($vltotcre) ?></span><? echo formataMoeda($vltotcre) ?></td>
				    <td><span><? echo $flextjus == 'no'? 'Não':'Sim'; ?></span><? echo $flextjus == 'no'? 'Não':'Sim'; ?></td>
				</tr>				
			<? } ?>			
		</tbody>
	</table>
</div>
