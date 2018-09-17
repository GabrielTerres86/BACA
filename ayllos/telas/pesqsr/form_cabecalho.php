<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)						Última alteração: 24/06/2016
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

				  24/062016 - Ajustes referente a homologação da tela para liberação 
                              (Adriano - SD 412556).


 * --------------
 */
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="C" selected ><? echo utf8ToHtml('C - Pelo número do cheque') ?> </option>
		<option value="D" ><? echo utf8ToHtml('D - Créditos(DOC/TED)')?> </option>		
	</select>

	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
	
	<br style="clear:both" />
</form>
