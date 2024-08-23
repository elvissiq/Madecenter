#Include "Protheus.ch"
 
/*-------------------------------------------------------------------------------------*
 | P.E.:  LJ7053                                                                       |
 | Desc:  LJ7053 - Adi��o de op��es em "Outras A��es" do Venda Assistida.              |
 | Link:  https://tdn.totvs.com/pages/viewpage.action?pageId=6791039                   |
 *-------------------------------------------------------------------------------------*/

User Function LJ7053()
 
 Local aDados := {}
        
        AAdd(aDados, { "NF-e Sefaz","SPEDNFE", 0, 1, NIL, .F.})
        AAdd(aDados, { "Hist. Cliente","U_MLJF01", 0, 1, NIL, .F.})

Return aDados