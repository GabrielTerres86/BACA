<? 
/*! 
 * FONTE        : tab_contatos.php
 * CRIAÇÃO      : Lucas Ranghetti
 * DATA CRIAÇÃO : 01/08/2016
 * OBJETIVO     : Tabela que apresenda os CONTATOS
 *
 * ALTERACOES   : 
 */	
?>
<div id="tabTelefones"  >
		<div class="divRegistros"> 
			<table class="tituloRegistros">
				<thead>
					<tr><th>Titular</th>
						<th>DDD</th>
						<th>Telefone</th>
				</thead>		
				<tbody>
					<? foreach($telefones as $telefone) { ?>
						<tr>
							<td><? echo getByTagName($telefone->tags,'idseqttl'); ?></td>
							<td><? echo getByTagName($telefone->tags,'nrdddtfc'); ?></td>
							<td><? echo getByTagName($telefone->tags,'nrtelefo'); ?></td>
						</tr>
					<? } ?>			
				</tbody>
			</table>
		</div>
</div>

<div id="tabEmails"  >
		<div class="divRegistros"> 
			<table class="tituloRegistros">
				<thead>
					<tr><th>Titular</th>
						<th>E-mail</th>
				</thead>		
				<tbody>
					<? foreach( $emails as $email ) { ?>
						<tr>
							<td><? echo getByTagName($email->tags,'idseqttl'); ?></td>
							<td><? echo getByTagName($email->tags,'dsdemail'); ?></td>
						</tr>
					<? } ?>			
				</tbody>
			</table>
		</div>
</div>

<div id="divBotContatos" style='text-align:center; margin-bottom: 10px;' >
	<a href="#" class="botao" id="btVoltContatos" name="btVoltContatos" onClick="btVoltContatos();return false;" style="float:none;">Voltar</a>
</div>