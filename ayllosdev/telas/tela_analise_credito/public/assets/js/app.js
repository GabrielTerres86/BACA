/* 
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
* 
*  Scripts para gerenciar filtros de personas e categorias, 
* 
*/

/* 
*  BACKDROP de carregamento
*/

loading(true);

$(document).ready(function(){

    /*
    *  Modo de exibição lado a lado
    */

	startSideBySide();

	/* 
	*  FILTRO DE BUSCA
	*/

    startFiltroBusca();

    /*
    *  AFFIX submenu personas
    */

    var target = $('.html_sub_filtro');
    target.after('<div class="affix" id="affix"></div>');

    var affix = $('.affix');
    // affix.append(target.clone(true));
    affix.html(target.clone(true));

    // Show affix on scroll
    var element = document.getElementById('affix');
    if (element !== null) {
        var position = target.position();
        window.addEventListener('scroll', function () {
            var height = $(window).scrollTop();
            if (height > 0) {
                target.css('visibility', 'hidden');
                affix.css('display', 'block');
            } else {
                affix.css('display', 'none');
                target.css('visibility', 'visible');
            }
        })
    }

    // // btn gerar PDF
    // $('body').on("click",".btn-gerar-pdf", function(e){

    //     // desativa link
    //     e.preventDefault();

    //     // pega o conteúdo do bloco onde ficou o HTML
    //     pdf_content = $('#clone-gerar-pdf').html();

        











        // ativa gerador de PDF
        // var doc = new jsPDF();
        // var doc = new jsPDF('portrait');

        // doc.addHTML(document.getElementById('clone-gerar-pdf'),function() {
        //     doc.save('pdfTable.pdf');
        // });

        // console.log(teste);
        // doc.html(teste, {
        //    callback: function (doc) {
        //      doc.save();
        //    }
        // });

//        doc.text('Hello world!', 10, 10);
//        doc.save('a4.pdf');

    // });

});














