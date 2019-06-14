<? 
 /*!
 * FONTE        : detalhe_darf_41.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : Junho/2014 
 * OBJETIVO     : Formulário de exibição de datalhes de DARF arrecadadas na Rot.41 SD. 75897
 * --------------
 * ALTERAÇÕES   : 22/06/2015 - Ajuste decorrente a melhoria no layout da tela
							   (Adriano).
 * --------------
 */	
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
		
?>
<form name="form_detalhe_darf_41" id="form_detalhe_darf_41" class="formulario" >	
	<fieldset>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td align="center">
				
					<label for="dtapurac"><? echo utf8ToHtml('Periodo de apuracao:') ?></label>
					<input name="dtapurac" id="dtapurac" type="text" />
						
					<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
					<input name="nrcpfcgc" id="nrcpfcgc" type="text" />
							
					<br/>
					<label for="cdtribut"><? echo utf8ToHtml('Cod. Receita:') ?></label>
					<input name="cdtribut" id="cdtribut" type="text" />
					
					<label for="nrrefere"><? echo utf8ToHtml('Referencia:  ') ?></label>
					<input name="nrrefere" id="nrrefere" type="text" />
					
					<br/>
					<label for="dtlimite"><? echo utf8ToHtml('Dt. Vencimento:') ?></label>
					<input name="dtlimite" id="dtlimite" type="text" />
					
					&nbsp;
					<br><br>
					<label for="vllanmto"><? echo utf8ToHtml('Vlr. Principal:') ?></label>
					<input name="vllanmto" id="vllanmto" type="text" />
						
					<label for="vlrmulta"><? echo utf8ToHtml('Vlr. Multa:') ?></label>
					<input name="vlrmulta" id="vlrmulta" type="text" />		
							
					<br/>
					<label for="vlrjuros"><? echo utf8ToHtml('Valor Juros:') ?></label>
					<input name="vlrjuros" id="vlrjuros" type="text" />		
					
					<label for="vlrtotal"><? echo utf8ToHtml('Vlr. Total:') ?></label>
					<input name="vlrtotal" id="vlrtotal" type="text" />		
					
					<br/>
					<label for="vlrecbru"><? echo utf8ToHtml('Receita Bruta Acumulada:') ?></label>
					<input name="vlrecbru" id="vlrecbru" type="text" />		
					
					<label for="vlpercen"><? echo utf8ToHtml('Percentual:') ?></label>
					<input name="vlpercen" id="vlpercen" type="text" />		
							
				
				</td>
			</tr>
		</table>
	</fieldset>				
</form>

<div id="divBotoesDarf" style="margin-top:5px; margin-bottom :10px; text-align: center;">
																							
	<a href="#" class="botao" id="btVoltar" onClick="escondeDivRotina(); return false;">Voltar</a>
		
</div>
