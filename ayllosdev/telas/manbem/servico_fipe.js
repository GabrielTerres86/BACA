var idElementTpVeiulo = "dscatbem";
var idElementMarca = "dsmarbem";
var idElementModelo = "dsbemfin";
var idElementAno = "nrmodbem";
var idElementValor = "vlfipbem";

$(function(){
    
    $("#"+idElementTpVeiulo).change(function(){
        trataCamposFipe($(this));       
        if(validaValorCombo($(this)))
        {
            var urlPagina= "telas/manbem/fipe/busca_marcas.php";
            var tipoVeiculo = trataTipoVeiculo($(this).val());
            var data = jQuery.param({ idelhtml:idElementMarca, tipveicu: tipoVeiculo, redirect: 'script_ajax'});
            buscaFipeServico(urlPagina,data);				
        }
    });
    $("#"+idElementMarca).change(function(){
        trataCamposFipe($(this)); 
        if(validaValorCombo($(this)))
        {
            var urlPagina= "telas/manbem/fipe/busca_modelos.php";
            var cdMarcaFipe = $(this).val();
            var data = jQuery.param({ idelhtml:idElementModelo, cdmarfip: cdMarcaFipe , redirect: 'script_ajax'});
            buscaFipeServico(urlPagina,data);	
        }		
    });
    $("#"+idElementModelo).change(function(){
        trataCamposFipe($(this)); 
        if(validaValorCombo($(this)))
        {
            var urlPagina= "telas/manbem/fipe/busca_anos.php";
            var cdMarcaFipe = $("#"+idElementMarca).val();	
            var cdModeloFipe = $(this).val();        
            var data = jQuery.param({ idelhtml:idElementAno, cdmarfip: cdMarcaFipe ,cdmodfip: cdModeloFipe, redirect: 'script_ajax'});
            buscaFipeServico(urlPagina,data);	
        }
    });
    $("#"+idElementAno).change(function(){
        trataCamposFipe($(this)); 
        if(validaValorCombo($(this)))
        {
            var urlPagina= "telas/manbem/fipe/busca_valor.php";
            var cdMarcaFipe = $("#"+idElementMarca).val();
            var cdModeloFipe = $("#"+idElementModelo).val();
            var cdAnoFipe = $(this).val();		            
            var data = jQuery.param({idelhtml:idElementValor, cdmarfip: cdMarcaFipe, cdmodfip: cdModeloFipe, cdanofip: cdAnoFipe, redirect: 'script_ajax'});
            buscaFipeServico(urlPagina,data);
        }
    });
});
function trataCamposFipe(obj)
{
    switch(obj.attr('id')) {
        case idElementTpVeiulo:
            $("#"+idElementMarca).empty();  
            $("#"+idElementModelo).empty();  
            $("#"+idElementAno).empty();  
            $("#"+idElementValor).val(null); 
        break;
        case idElementMarca:
            $("#"+idElementModelo).empty();  
            $("#"+idElementAno).empty();  
            $("#"+idElementValor).val(null); 
        break;
        case idElementModelo:
            $("#"+idElementAno).empty();  
            $("#"+idElementValor).val(null); 
        break;
        case idElementAno:
            $("#"+idElementValor).val(null); 
        break;
    }
}
function trataTipoVeiculo(value)
{
    var tipoVeiculo=0;
    switch(value)
    {
        case "AUTOMOVEL":
             tipoVeiculo =1;
        break;
        case "CAMINHAO":
            tipoVeiculo = 3;
        break;
        case "MOTO":
            tipoVeiculo = 2;
        break;
    }
    return tipoVeiculo;
}
function validaValorCombo(obj){
    if(obj.val()==='-1')
    {
        return false;
    }
    return true;
}
function buscaFipeServico(urlPagina,dataParameters)
{
	$.ajax({
		type  : 'POST',
		url   : UrlSite + urlPagina,
        data: dataParameters,
        error: function(objAjax, responseError, objExcept) {			
            //showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            eval(response);
        }
    });	
}