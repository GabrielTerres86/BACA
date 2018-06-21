<?php
/* !
 * FONTE        : tab_resultado.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2016 
 * OBJETIVO     : Tabela que apresenta resultado da consulta realizada
 * --------------
 * ALTERAÇÕES   : 
  ----------------
 */
if($tpproduto != 4)
{
    $search = array('.', '-');
    $tabela = "<fieldset id=\'tabConteudo\'>";
    $tabela .= "<legend>" . utf8ToHtml('Parâmetros da Esteira de Crédito') . "</legend>";

    $tabela .= "<div class=\'divRegistros\'>";
    $tabela .= "<table>";
    $tabela .= "<thead>";
    $tabela .= "<tr>";
    $tabela .= "<th>Coop.</th>";
    $tabela .= "<th>Conting.</th>";
    $tabela .= "<th>" . utf8ToHtml('Comitê') . "</th>";
    $tabela .= "<th>" . utf8ToHtml('Análise Aut.') . "</th>";
    $tabela .= "<th>Regra PF</th>";
    $tabela .= "<th>Regra PJ</th>";
    $tabela .= "</tr>";

    $tabela .= "</thead>";
    $tabela .= "<tbody>";


    foreach ($registros as $r) {
		
		echo "console.log('1--> ".getByTagName($r->tags, 'nmregmpj')."');";

        $tabela .= "<tr>";
        $tabela .= "<td>" . getByTagName($r->tags, 'nmrescop') . "</td>";
        $tabela .= "<td>" . getByTagName($r->tags, 'contigen') . "</td>";
        $tabela .= "<td>" . getByTagName($r->tags, 'incomite') . "</td>";
        $tabela .= "<td>" . getByTagName($r->tags, 'anlautom') . "</td>";
        $tabela .= "<td>" . getByTagName($r->tags, 'nmregmpf') . "</td>";
        $tabela .= "<td>" . getByTagName($r->tags, 'nmregmpj') . "</td>";
        $tabela .= "</tr>";
    }

    $tabela .= "</tbody>";
    $tabela .= "</table>";
    $tabela .= "</div>";

    $tabela .= "</fieldset>";

    // Monta tabela
    echo "$('#divConsulta').html('" . $tabela . "');";

    // Efetua formatação do layout da tabela
    echo 'formataResultado();';

    // Esconde botão Continuar
    echo '$("#btContinuar","#divBotoes").hide();';
} else if($tpproduto == 4){
    $tabela = "<fieldset id=\'tabConteudo\'>";
    $tabela .= "<legend>" . utf8ToHtml('Parâmetros da Esteira de Crédito - Cartão ') . "</legend>";

    $tabela .= "<div class=\'divRegistros\'>";
    $tabela .= "<table>";
    $tabela .= "<thead>";
    $tabela .= "<tr>";
    $tabela .= "<th class=\'coop04\'>Coop.</th>";
    $tabela .= "<th class=\'confME04\'>Contig.</th>";
    $tabela .= "<th class=\'coopBancoob04\'>Analise Aut.</th>";
    $tabela .= "<th class=\'Regras04\'>Regras PF</th>";
	$tabela .= "<th class=\'PJ04\'>Regras PJ</th>";
    $tabela .= "</tr>";
    $tabela .= "</thead>";
    $tabela .= "<tbody>";

   foreach ($registros as $r) {
	   
	   echo "console.log('2--> ".getByTagName($r->tags, 'nmregmpj')."');";
   
        $tabela .= "<tr>";

        $tabela .= "<td class=\'coop04\'>" . getByTagName($r->tags, 'nmrescop') . "</td>";
        $tabela .= "<td class=\'confME04\'>" . getByTagName($r->tags, 'contigen') . "</td>";
        $tabela .= "<td class=\'coopBancoob04\'>" . getByTagName($r->tags, 'anlautom') . "</td>";
        $tabela .= "<td class=\'Regras04\'>" . getByTagName($r->tags, 'nmregmpf') .  "</td>";
		$tabela .= "<td class=\'PJ04\'>" . getByTagName($r->tags, 'nmregmpj') .  "</td>";

        $tabela .= "</tr>";
    }

    $tabela .= "</tbody>";
    $tabela .= "</table>";
    $tabela .= "</div>";

    $tabela .= "</fieldset>";
    
    echo "$('#divConsulta').html('" . $tabela . "');";
    

    // Efetua formatação do layout da tabela
    echo 'formataResultado();';

    echo("$('.ordemInicial').css('width','10px');");
    echo("$('.coop04').css('width','80px');");
    echo("$('.confME04').css('width','40');");
    echo("$('.coopBancoob04').css('width','40');");
    echo("$('.Regras04').css('width','120px');");
	echo("$('.PJ04').css('width','120px');");
    // Esconde botão Continuar
    echo '$("#btContinuar","#divBotoes").hide();';
}