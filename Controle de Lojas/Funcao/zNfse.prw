#INCLUDE 'topconn.ch'
#INCLUDE 'protheus.ch'
#INCLUDE 'totvs.ch'

/*/{Protheus.doc} zNfse
    Fun��o para chamar o link da NFS-e, de acordo com a RPS informada. 
    @type  Function
    @author Taiu� Nascimento | TOTVS Nordeste
    @since 09/01/2024
    @version 1.02
    Obs1: Necess�rio criar consulta padr�o da SF2 que retorne F2_DOC, F2_SERIE, F2_CLIENTE e F2_LOJA.
    Obs2: Criar campo na tabela CC2->CC2_XLINK, nesse campo ser� informado a estrutura da URL para
    Vizualiza��o da NFS-e emitida pela respectiva prefeitura.
/*/

User Function zNfse()

    Local cInscMun := AllTrim(SM0->M0_INSCM)
    Local cURLNFSe := SuperGetMV("MV_XURLNFS",.F.,"https://nfseteste.recife.pe.gov.br/nfse.aspx?")
    Local cNumNSf  := AllTrim(SF2->F2_NFELETR)
    Local cProtAut := StrTran(AllTrim(SF2->F2_CODNFE),"-","")
        
    IF (cNumNSf == "" .AND. cProtAut == "")
        MSGALERT("Nota ainda n�o foi autorizada. Verifique o status da NFS-e no monitor.")
    Else
        cURLNFSe := cURLNFSe + "ccm=" + cInscMun + "&nf=" + cNumNSf + "&cod=" + cProtAut
        ShellExecute("Open", cURLNFSe, "","", 1)
    EndIF

Return
