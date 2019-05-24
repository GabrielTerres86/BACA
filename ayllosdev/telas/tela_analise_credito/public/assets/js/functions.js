/* 
*
*  @author Mout's - Anderson Schloegel
*  @author Mout's - Bruno Luiz Katzjarowski
*  Ailos - Projeto 438 - Sprint 9+ - Tela Única de Análise de Crédito
*  fev+ 2019
* 
*/

/* 
*  backdrop de carregamento
*/

function loading(stats) {

    if (typeof stats === "undefined") {
        stats = true;
    }

	// backdrop de carregamento de tela
	if (stats == true) {
		// mostra
		$('#loading').fadeIn(50);
	} else {
		// oculta
		$('#loading').fadeOut(1000);
	}
}

/*
* gera um alerta para avisar o usuário que um bloco já está selecionado
*/

function alertSelecionado(sbsClicado, sbsClicadoReal) {
    $('#alert-selecionado-backdrop').fadeIn(100);
}

/*
* oculta bloco da função acima
*/

function alertSelecionadoOut() {
    $('#alert-selecionado-backdrop').fadeOut(100);
}

/* 
*  Erro no carregamento do XML ou Filtro de Busca
*/

function showLoadingError(response){

    var text = '';

    if(response['responseText'] == "filtroTela"){
        text = 'XML com filtros inconsistentes';
    } else if(response['responseText'] !== ""){
        text = response['responseText'];
    }else{
        text = "";
    }

	var contentError  = ''; 
		contentError += '<p class="loadingError"><span><i class="fas fa-times-circle"></i></span> <br> Não foi possível carregar os dados!<br><small>'+text+'</small></p>'; 

	$('#loading').html(contentError);
}


/* 
*  REMOVER item do vetor
*/

function arrayRemove(arr, value) {

   return arr.filter(function(ele){
       return ele != value;
   });
}

/* 
*  Se não for vetor, transforma em um
*/

function makeArray(index){
    var arrayReturn = Array();

    if(typeof index === 'undefined'){
        arrayReturn.push(index);
        return arrayReturn;
    }

    for(var i =0; i < index.length; i++){
        arrayReturn.push(index[i]);
    }
    return arrayReturn;
}

/* 
*  transforma uma string em um texto plano
*/

function slugify(text){
    return text.toString().toLowerCase()
        .replace(/\s+/g, '-')           // Replace spaces with -
        .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
        .replace(/\-\-+/g, '-')         // Replace multiple - with single -
        .replace(/^-+/, '')             // Trim - from start of text
        .replace(/-+$/, '');            // Trim - from end of text
}