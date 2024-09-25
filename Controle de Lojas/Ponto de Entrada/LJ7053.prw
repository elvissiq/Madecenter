#Include "Protheus.ch"
 
/*-------------------------------------------------------------------------------------*
 | P.E.:  LJ7053                                                                       |
 | Desc:  LJ7053 - Adição de opções em "Outras Ações" do Venda Assistida.              |
 | Link:  https://tdn.totvs.com/pages/viewpage.action?pageId=6791039                   |
 *-------------------------------------------------------------------------------------*/

User Function LJ7053()
        Local aDados := {}
        
        AAdd(aDados, { "NF-e Sefaz","SPEDNFE", 0, 1, NIL, .F.})
        AAdd(aDados, { "Nota Fiscal Servico","FISA022", 0, 1, NIL, .F.})
        AAdd(aDados, { "Hist. Cliente","U_MLJF01", 0, 1, NIL, .F.})
        AAdd(aDados, { "Crédito Correntista","U_MLJF06", 0, 1, NIL, .F.})
        AAdd(aDados, { "Imp. Orc. Completo","U_zROrcComp", 0, 1, NIL, .F.})
        AAdd(aDados, { "Imp. Orc. Simples" ,"U_zROrcSimp", 0, 1, NIL, .F.})
        AAdd(aDados, { "Confirmar Entrega","U_MLJF03", 0, 1, NIL, .F.})

Return aDados
