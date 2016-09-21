<? 
/*!
 * FONTE        : tab_avalista.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 21/01/2013 
 * OBJETIVO     : Tabela que apresenta os avalistas
 * --------------
 * ALTERAÇÕES   : 23/07/2015 - Incluído a chamada pas as includes de controle (Jéssica - DB1)
 * --------------
 */	
 
	session_start();
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');	
	isPostMethod();
 
?>

<div id="divContrato">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta/dv'); ?></th>
					<th><? echo utf8ToHtml('Nome Pesquisado');  ?></th>
					<th><? echo utf8ToHtml('CPF');  ?></th>					
				</tr>
			</thead>
			<tbody>			
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
							<? echo mascara(getByTagName($r->tags,'nrdconta'),'####.###.#') ?></td>						
						<td><? echo getByTagName($r->tags,'nmdavali') ?></td>
						<td><? echo getByTagName($r->tags,'nrcpfcgc') ?>
							<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($r->tags,'nrcpfcgc') ?>" /></td>						
					</tr>
				<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoesAvalista" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNrdconta.focus(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaAvalista(); return false;">Continuar</a>
</div>