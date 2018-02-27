<?php
/*!
* FONTE        : form_simulacao.php
* CRIAÇÃO      : Marcelo L. Pereira (GATI)
* DATA CRIAÇÃO : 26/06/2011 
* OBJETIVO     : Formulário de dados da simulação

ALTERACOES     : 30/03/2012 - Incluir campo %CET (Gabriel).
                 05/09/2012 - Mudar para layout padrao (Gabriel)	 
                 04/08/2014 - Ajustes referentes ao projeto CET (Lucas R./Gielow)
                 30/06/2015 - Ajustes referentes Projeto 215 DV 3 (Daniel)
                 03/02/2017 - Reposicionar a Linha de Credito. (Jaison/James - PRJ298)

                 20/09/2017 - Projeto 410 - Incluir campo Indicador de financiamento do IOF (Diogo - Mouts)
*/	

$retorno = array();

// Montar o xml de Requisicao
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PORTAB_CRED", "CAR_MODALI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    echo "<script>";
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
    echo "</script>";    
} else {
    $registros = $xmlObj->roottag->tags;
}
?>
<div id="divProcSimulacoesFormulario" style="display:none">
    <form name="frmSimulacao" id="frmSimulacao" class="formulario">
        <fieldset>
            <legend><? echo utf8ToHtml('Dados para a  S I M U L A Ç Ã O') ?></legend>

            <label for="vlemprst">Valor:</label>
            <input name="vlemprst" id="vlemprst" type="text" value="" />
            <br />

            <label for="cdfinemp"><? echo utf8ToHtml('Finalidade:') ?></label>
            <input name="cdfinemp" id="cdfinemp" type="text" value="" />
            <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
            <input name="dsfinemp" id="dsfinemp" type="text" value="" />
            <input name="tpfinali" id="tpfinali" type="hidden" value="" />
            <br />
            
            <label for="cdlcremp"><? echo utf8ToHtml('Linha Crédito:') ?></label>
            <input name="cdlcremp" id="cdlcremp" type="text" value="" />
            <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
            <input name="dslcremp" id="dslcremp" type="text" value="" />
            <br />
            
            <label for="cdmodali">Modalidade:</label>
            <select name="cdmodali" id="cdmodali" class="campo" >
                <option value="0">Selecione uma modalidade</option>
                <?php
                foreach ($registros as $registro) {
                    echo '<option value="' . $registro->tags[0]->cdata . '" >' . str_replace('?', "-", $registro->tags[1]->cdata) . '</option>';
                }
                ?>                
            </select>
            <br />

            <label for="qtparepr">Qtd Parcelas:</label>
            <input name="qtparepr" id="qtparepr" type="text" value="" />
            <br />


            <label for="dtlibera"><? echo utf8ToHtml('Data de Liberação:') ?></label>
            <input name="dtlibera" id="dtlibera" type="text" value="" />
            <br />

            <label for="dtdpagto"><? echo utf8ToHtml('Data do 1º Pagamento:') ?></label>
            <input name="dtdpagto" id="dtdpagto" type="text" value="" />
            <br />

            <label for="idfiniof">Financiar IOF e Tarifa:</label>
            <select name="idfiniof" id="idfiniof" class="campo" >
                <option value="1" selected="selected">Sim</option>
                <option value="0">N&atilde;o</option>
            </select>
            <br />

            <label for="percetop"> <? echo utf8ToHtml('CET(%a.a.):') ?> </label>
            <input name="percetop" id="percetop" type="text" value="" />
            <br />

            <label for="vliofepr">IOF:</label>
            <input name="vliofepr" id="vliofepr" type="text" value=""/>
            <br/>

            <label for="vlrtarif">Tarifa:</label>
            <input name="vlrtarif" id="vlrtarif" type="text" value=""/>
            <br/>

            <label for="vlrtotal">Valor Total:</label>
            <input name="vlrtotal" id="vlrtotal" type="text" value=""/>

			-->
        </fieldset>
    </form>
    <div id="divProcParcelasTabela" style="display:none">
        <div class="divRegistros">	
            <table>
                <thead>
                    <tr><th>Sequencial</th>
                        <th>Data Vencimento</th>
                        <th>Valor</th>
                </thead>		
                <tbody id="tBodyParcelas">

                </tbody>
            </table>
        </div>
    </div>
    <div id="divBotoesFormSimulacao" style="margin-top:5px; margin-bottom:5px;">
        <a href="#" class="botao" id="btVoltar" onClick="mostraTabelaSimulacao('TS');
                        return false;">Voltar</a>
        <a href="#" class="botao" id="btSalvar" >Concluir</a>
    </div>
</div>

<script>

    $(document).ready(function() {

        highlightObjFocus($('#frmSimulacao'));
    });

</script>