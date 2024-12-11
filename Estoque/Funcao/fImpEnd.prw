#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"

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
                TMP->TP_QUANT   := Val(aDados[5])
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
        aAdd(aLinha, {"DB_QUANT"  ,TMP->TP_QUANT           ,Nil })
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
