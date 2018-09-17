<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2011
 * OBJETIVO     : Cabeçalho para a tela PESQSR
 * --------------
 * ALTERAÇÕES   : 08/08/2013 - Alterações de Layout da tela e adicionado nova
							   opção (R) para geração de relatórios.
							   Inibição dos campos :
							   - Código de Pesquisa
							   - Sequencia
							   - Valor de CPMF

	              15/08/2013 - Alteração da sigla PAC para PA (Carlos)
				  
				  19/08/2015 - Retirar campo secao (Gabriel-RKAM)
				  
02/06/2016  #412556
			- Não estava mostrando os dados do cheque;
			- Inclusão dos campos Coop, cód de pesquisa, sequência e vlr cpmf;
			- Inclusão de máscaras de moeda, inteiro, conta e outras;
			- nrctabb vazio;
			- Correção do botão Voltar, que estava deixando as opções quase invisíveis (fade);
			- Ajuste dos campos, pois estavam com alinhamentos e tamanhos desproporcionais aos seus conteúdos;
			- Correção da sequência dos focos dos campos ao pressionar enter;
			- Correção da ordenação das validações;
			- Campos não estavam sendo limpos quando era trocada a opção da tela;
			- Comentados os códigos que envolviam a geração de relatório, pois esta opção não existe na tela 
			atual do ambiente caracter;
			- Ajustes de css que estavam sendo feitos em js sem necessidade e em alguns casos com redundância.
			(Carlos)
 * --------------
 */
?>
<form id="frmFiltro" name="frmFiltro" class="formulario">
	<fieldset>
		<legend>Filtros</legend>
		
		<label for="nrdocmto"><? echo utf8ToHtml('Documento:') ?></label>
		<input id="nrdocmto" name="nrdocmto" type="text"  />
        
		<label for="nrdctabb"><? echo utf8ToHtml('Cta.Chq/Base:') ?></label>
		<input id="nrdctabb" name="nrdctabb" type="text" />
        
		<label for="cdbaninf" style="margin-left:3px"><? echo utf8ToHtml('Bco Chq/Coop:') ?></label>
		<input id="cdbaninf" name="cdbaninf" type="text" /><input id="cdagechq" name="cdagechq" type="text" />		
		
		<br />
		
		<label for="dtmvtolt"><? echo utf8ToHtml('Data:') ?></label>
		<input id="dtmvtolt" name="dtmvtolt" type="text"/>
        
		<label for="nrdconta" ><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input id="nrdconta" name="nrdconta" type="text"/>
		
		<label for="cdbccxlt" ><? echo utf8ToHtml('Bco/Cxa:') ?></label>
		<input id="cdbccxlt" name="cdbccxlt" type="text" />
		
		<br />
		
		<label for="nrdolote" ><? echo utf8ToHtml('Lote:') ?></label>
		<input id="nrdolote" name="nrdolote" type="text" />
		
		<label for="cdagenci" ><? echo utf8ToHtml('PA:') ?></label>
		<input id="cdagenci" name="cdagenci" type="text" />
		
		<label for="vllanmto" ><? echo utf8ToHtml('Vlr do Docto:') ?></label>
		<input id="vllanmto" name="vllanmto" type="text" />
		
		<div id="divOpcaoD">
			<label for="nrseqimp" ><? echo utf8ToHtml('Sequencia:') ?></label>
			<input id="nrseqimp" name="nrseqimp" type="text" />
			
			<label for="cdpesqbb" style="margin-left:3px"><? echo utf8ToHtml('Pesquisa:') ?></label>
			<input id="cdpesqbb" name="cdpesqbb" type="text" />
			
			<label for="vldoipmf" ><? echo utf8ToHtml('Vlr CPMF:') ?></label>
			<input id="vldoipmf" name="vldoipmf" type="text" />
		</div>
	</fieldset>

	<fieldset>
		<label for="nmprimtl" ><? echo utf8ToHtml('Titular:') ?></label>
		<input id="nmprimtl" name="nmprimtl" type="text"/>
		
		<label for="dsagenci" style="margin-left:3px"><? echo utf8ToHtml('PA:') ?></label>
		<input id="dsagenci" name="dsagenci" type="text" />

		<br />
		
		<label for="cdturnos" ><? echo utf8ToHtml('Tu:') ?></label>
		<input id="cdturnos" name="cdturnos" type="text" />
		
		<label for="nrfonemp" ><? echo utf8ToHtml('Fone:') ?></label>
		<input id="nrfonemp" name="nrfonemp" type="text"/>
		
		<label for="nrramemp" style="margin-left:3px"><? echo utf8ToHtml('Ramal:') ?></label>
		<input id="nrramemp" name="nrramemp" type="text" />

	</fieldset>
	<fieldset>
		<legend><? echo utf8ToHtml('Origem do Lançamento') ?></legend>
		<!-- 01/07/2014 - Incluir campo "Age.Acl." na "ORIGEM DO LANCAMENTO". (Reinert)
		[ Corrigir a informação abaixo para mostrar os dados do banco/age do beneficiário do cheque ]
		-->
		<label for="cdbanchq"><? echo utf8ToHtml('Bco/Age:') ?></label>
		<input id="cdbanchq" name="cdbanchq" type="text" />

		<label for="cdcmpchq"><? echo utf8ToHtml('Comp:') ?></label>
		<input id="cdcmpchq" name="cdcmpchq" type="text" />

		<label for="nrlotchq"><? echo utf8ToHtml('Lote:') ?></label>
		<input id="nrlotchq" name="nrlotchq" type="text" />

		<label for="sqlotchq"><? echo utf8ToHtml('Sq:') ?></label>
		<input id="sqlotchq" name="sqlotchq" type="text" />

		<label for="nrctachq"><? echo utf8ToHtml('Conta:') ?></label>
		<input id="nrctachq" name="nrctachq" type="text"/>
	</fieldset>
</form>
