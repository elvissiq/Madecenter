#Include "Protheus.ch"
#Include "rwmake.ch"
 
/*-------------------------------------------------------------------------------------*
 | P.E.:  LJ7023                                                                       |
 | Desc:  LJ7023 - Ponto de entrada � utilizado para inibir/desabilitar os bot�es de   |
 |                 forma de pagamento desejados da tela de defini��o de pagamentos (F7)|
 |                 na Venda Assistida.                                                 |
 | Link:  https://tdn.totvs.com/plugins/viewsource/viewpagesrc.action?pageId=6790895   |
 *-------------------------------------------------------------------------------------*/

User Function LJ7023()
        Local lRet := .F.
        Local cFormaPg := Upper(PARAMIXB[1])
        
        IF LjProfile(3)
                lRet := .T.
        ElseIF cFormaPg $("BOLETO BANCARIO")
                lRet := .T.  
        EndIF 

Return lRet
