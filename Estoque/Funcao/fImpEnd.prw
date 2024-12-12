#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'

User Function fImpEnd()
    Local aArea  := FWGetArea()
    
    Private cArq := TFileDialog( "CSV Files (*.csv) | Arquivo texto (*.txt)",,,, .F., /*GETF_MULTISELECT*/ )
    Private oTabTMP := FWTemporaryTable():New("TMP")
    Private aFields := {}
    Private aDados := {}

    If !File(cArq)
        Return
    EndIf
    
    Processa({|| fnLerArq()}, "Processando...")
    Processa({|| fMta265I()}, "Processando...")

    FWAlertSuccess("Processamento finalizado!","Endereçar Saldo")

    FWRestArea(aArea)
Return

Static Function fnLerArq()
    Local nAtual := 0
    Local nTotal := 0

    aAdd(aFields, {"TP_FILIAL" ,"C",FWTamSX3("DA_FILIAL")[1] ,FWTamSX3("DA_FILIAL")[2] ,"Filial","",""})
    aAdd(aFields, {"TP_PRODUTO","C",FWTamSX3("DA_PRODUTO")[1],FWTamSX3("DA_PRODUTO")[2],"Produto","",""})
    aAdd(aFields, {"TP_NUMSEQ" ,"C",FWTamSX3("DA_NUMSEQ")[1] ,FWTamSX3("DA_NUMSEQ")[2] ,"Sequencial","",""})
    aAdd(aFields, {"TP_LOCALIZ","C",FWTamSX3("DB_LOCALIZ")[1],FWTamSX3("DB_LOCALIZ")[2],"Endereco","",""})
    aAdd(aFields, {"TP_QUANT"  ,"N",FWTamSX3("DB_QUANT")[1]  ,FWTamSX3("DB_QUANT")[2]  ,"Quantidade","",""})
    oTabTMP:SetFields(aFields)
    oTabTMP:Create()
    
    DBSelectArea("TMP")
    
    FT_FUSE(cArq)

    nTotal := FT_FLASTREC()
    ProcRegua(nTotal)
	FT_FGOTOP()

    While !FT_FEOF()
        
        nAtual++

        IncProc("Lendo arquivo, linha " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        
        If Empty(FT_FREADLN())
            FT_FSKIP()
        Else
            aDados := Strtokarr(FT_FREADLN(),";")
            RecLock("TMP",.T.)
                TMP->TP_FILIAL  := AllTrim(aDados[1])
                TMP->TP_PRODUTO := AllTrim(aDados[2])
                TMP->TP_NUMSEQ  := AllTrim(aDados[3])
                TMP->TP_LOCALIZ := AllTrim(aDados[4])
                IF Len(aDados) == 5
                TMP->TP_QUANT   := Val(aDados[5])
                EndIF
            TMP->(MsUnlock())
        FT_FSKIP()
        EndIF 
    End

Return
Static Function fMta265I()
    Local aCab    := {}
    Local aItem   := {}
    Local aLinha  := {}
    Local cFilAux := cFilAnt
    Local nAtual  := 0
    Local nTotal  := 0

    Private lMSHelpAuto := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto := .F.

    DBSelectArea("TMP")
    Count To nTotal
    ProcRegua(nTotal)
    TMP->(DbGoTop())
    
    While TMP->(!Eof())

        nAtual++

        IncProc("Integrando dados, registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

        aCab   := {}
        aLinha := {}
        aItem  := {}

        cFilAnt := AllTrim(TMP->TP_FILIAL)

        aAdd(aCab, {"DA_PRODUTO", AllTrim(TMP->TP_PRODUTO),Nil})
        aAdd(aCab, {"DA_NUMSEQ" , AllTrim(TMP->TP_NUMSEQ) ,Nil})

        aAdd(aLinha, {"DB_ITEM"   ,"001"                   ,Nil })
        aAdd(aLinha, {"DB_ESTORNO"," "                     ,Nil })
        aAdd(aLinha, {"DB_LOCALIZ",AllTrim(TMP->TP_LOCALIZ),Nil })
        aAdd(aLinha, {"DB_DATA"   ,dDataBase               ,Nil })
        If !Empty(TMP->TP_QUANT)
        aAdd(aLinha, {"DB_QUANT"  ,TMP->TP_QUANT           ,Nil })
        EndIF
        aAdd(aItem,aLinha)

        lMsErroAuto := .F.
        
        MATA265( aCab, aItem, 3)
        
        /*
        If lMsErroAuto
            MostraErro()
        Endif
        */
        
        cFilAnt := cFilAux
    TMP->(DBSkip())
    End 

    oTabTMP:Delete()

Return

User Function fMata220()
    Local aVetor  := {}
    Local cQry    := {}
    Local _cAlias := GetNextAlias()
    Local nAtual  := 0
    Local nTotal  := 0

    Private lMSHelpAuto := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto := .F.

    cQry := " SELECT SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_LOCAL, SB2.B2_QFIM FROM "+RetSQLName("SB2")+" SB2 "
    cQry += " INNER JOIN "+RetSQLName("SDA")+" SDA ON SDA.DA_PRODUTO = SB2.B2_COD "
    cQry += " WHERE SB2.D_E_L_E_T_ <> '*' "
    cQry += " AND SB2.B2_FILIAL = '"+ xFilial("SB2") + "' "
    cQry += " AND SB2.B2_QFIM = SDA.DA_SALDO "
    cQry += " AND SDA.D_E_L_E_T_ <> '*' "
    cQry += " AND SDA.DA_FILIAL = '"+ xFilial("SDA") + "' "
    cQry += " AND SDA.DA_SALDO > 0 "
    cQry := ChangeQuery(cQry)
    TCQuery cQry ALIAS (_cAlias) NEW

    Count To nTotal
    ProcRegua(nTotal)
    (_cAlias)->(DbGoTop())
    
    While (_cAlias)->(!Eof())

        nAtual++

        IncProc("Integrando dados, registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

        aVetor := {}
        aAdd(aVetor,{"B9_FILIAL", (_cAlias)->B2_FILIAL, Nil})
        aAdd(aVetor,{"B9_COD"   , (_cAlias)->B2_COD   , Nil})
        aAdd(aVetor,{"B9_LOCAL" , (_cAlias)->B2_LOCAL , Nil})
        aAdd(aVetor,{"B9_QINI"  , (_cAlias)->B2_QFIM  , Nil})
        
        lMsErroAuto := .F. 
        
        Begin Transaction
            MSExecAuto({|x, y| Mata220(x, y)}, aVetor, 5)
            
            If lMsErroAuto
                MostraErro()
                DisarmTransaction()
            EndIf
        End Transaction
        
    (_cAlias)->(DBSkip())
    End 

    (_cAlias)->(DBCloseArea())

Return
