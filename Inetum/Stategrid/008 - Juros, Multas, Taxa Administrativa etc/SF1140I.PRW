User function SF1140I()
 
    IF UPPER(PROCNAME(12)) == "IMPXMLNFE"
        IF EMPTY(SD1->D1_PEDIDO) 
        Reclock("SF1",.F.)
            SF1->F1_XHOLD := "S"
        SF1->(MsUnlock())
        ENDIF 
    ENDIF 
    SC7->(DbSelectArea("SC7"))
    SC7->(DBSetOrder(1))

    RecLock("SF1", .F.)	
        If SC7->(DBSeek(SD1->D1_FILIAL+SD1->D1_PEDIDO))
            SF1->F1_XMULTA := SC7->C7_XMULTA
            SF1->F1_XJUROS := SC7->C7_XJUROS
        EndIf
        SF1->F1_XSOLIC := RetCodUsr()
    SF1->(MsUnLock())

    If SF1->F1_STATUS == "B"  
        
        EnvEmailFis(SF1->(RECNO()))

    Endif

Return

Static Function EnvEmailFis(nreg)
Local aFiles := {}

  if GetEnvServer() == 'STATEGRID'
    cEmailAprov := "classificacao.sgbh@stategrid.com.br"        
  ELSE
    cEmailAprov := "rodrigo.miras@stategrid.com.br"		
  endif

  DbSelectArea("SF1")
  DbSetOrder(1)
  DbGoto(nreg)

  cHisAnt := SF1->F1_XHISREJ
    RECLOCK("SF1", .F.)
        SF1->F1_XHISREJ := cHisAnt+" - "+DTOC(date())+" - "+"O solicitante: "+UsrFullName(retcodusr())+" realizou uma alteração no documento."+Chr(13)+Chr(10)+Chr(13)+Chr(10)
        SF1->F1_STATUS := ""
    MSUNLOCK()


  cTitle	:= OEMTOANSI("INFORMATIVO - Documento Corrigido / Corrected Document " + LTRIM(SF1->F1_DOC) )

  aMsg := {}

  AADD(aMsg, '<font font size="7" color="green">Documento Corrigido</font>' )
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, "Prezado(a), classificador ")
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, "O documento abaixo foi corrigido pelo solicitante, favor seguir com a classificação do mesmo.")         
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, "Solicitante............................... " + UsrFullName(retcodusr()) )
  AADD(aMsg, "Empresa.................................. " + SF1->F1_FILIAL)
  AADD(aMsg, "Número do Documento........... " + LTRIM(SF1->F1_DOC))
  AADD(aMsg, "Série......................................... " + LTRIM(SF1->F1_SERIE))
  AADD(aMsg, "Código do Fornecedor............. " + LTRIM(SF1->F1_FORNECE))
  AADD(aMsg, "Data de entrega para o fiscal... "+ DTOC(SF1->F1_RECBMTO))
  AADD(aMsg, "Vencimento............................. "+ DTOC(SF1->F1_XDTVENC))
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, '<font font size="7" color="green">Corrected Document</font>' )
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, "Dear, classifier ")
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, "The document below was corrected by requester, plese go ahead on document classification.")           
  AADD(aMsg, '<br />')
  AADD(aMsg, '<br />')
  AADD(aMsg, "Requester............................ " + UsrFullName(retcodusr()) )
  AADD(aMsg, "Company.............................. " + SF1->F1_FILIAL)
  AADD(aMsg, "Document number............... " + LTRIM(SF1->F1_DOC))
  AADD(aMsg, "Serie...................................... " + LTRIM(SF1->F1_SERIE))
  AADD(aMsg, "Supplier code........................ " + LTRIM(SF1->F1_FORNECE))
  AADD(aMsg, "Delivery Date to TAX............. "+ DTOC(SF1->F1_RECBMTO))
  AADD(aMsg, "Due Date............................... "+ DTOC(SF1->F1_XDTVENC))

  U_STAAX11(cEmailAprov, cTitle, aMsg, aFiles)					

  MSGINFO( "O documento foi atualizado e desbloqueado com sucesso" , "Totvs" )

  Return
