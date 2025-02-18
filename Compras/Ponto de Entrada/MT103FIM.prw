#Include "Protheus.ch"

/*/{Protheus.doc} MT103FIM
Ponto de entrada para excluir o apontamento da OP na devoluÃ§Ã£o da venda.
@author Felipe ValenÃ§a - Newsiga
@since 18/02/2025
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085406
/*/

User Function MT103FIM()

    Local nOpc      := PARAMIXB[1]
    Local nConfirm  := PARAMIXB[2] 
    Local aArea     := GetArea()

    Local cDocVenda := SD1->D1_NFORI
    Local cSerVenda := SD1->D1_SERIORI
    Local cNumOrc   := ""
    Local cNumOP    := ""

    Local aVetor    := {}
    Local lMsErroAuto  := .F.

    If nConfirm == 1
        If cTipo == "D" .And. nOpc == 3

            dbSelectArea("SL1")
            SL1->(dbSetOrder(2))
            If SL1->(dBSeek(xFilial("SL1") + cSerVenda + cDocVenda))
                cNumOrc := SL1->L1_NUMORIG
            Endif

            If !Empty(cNumOrc)
                dbSelectArea("SC2")
                SC2->(dbSetOrder(13)) //C2_XL1NUM
                SC2->(dbSeek(xFilial("SC2") + cNumOrc ))
                cNumOP := SC2->C2_XL1NUM
            Endif

            If !Empty(cNumOP)
                SD3->(DbSetOrder(1)) 
                If SD3->(DbSeek(xFilial("SD3") + cNumOP + "01" + "001"))
                    While !(SD3->(Eof())) .And. SD3->(D3_FILIAL + D3_OP ) == cNumOP + "01" + "001"    
                        If SD3->D3_ESTORNO == " "  
                            aVetor := { {"D3_FILIAL"        ,xFilial ("SD3")        ,NIL},;
                                        {"D3_TM"            ,"003"                  ,NIL},;
                                        {"D3_OP"            ,cNumOP + "01" + "001"  ,NIL}}

                            MSExecAuto({|x, y| mata250(x, y)},aVetor, 5 ) //Estorno

                            If lMsErroAuto
                                MsgAlert("Erro no estorno da Produção","ANTENCAO")
                                MostraErro()
                            Else
                                MsgInfo("Produção estornada com sucesso.","ESTORNO")
                            Endif                

                            Exit  
                        EndIf  
                        SD3->(DbSkip())  
                    EndDo 
                EndIf
            Endif

            RestArea(aArea)
        Endif
    Endif

Return
